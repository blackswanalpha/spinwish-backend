package com.spinwish.backend.services;

import com.neovisionaries.i18n.CountryCode;
import com.spinwish.backend.entities.Artists;
import com.spinwish.backend.entities.Songs;
import com.spinwish.backend.repositories.ArtistRepository;
import com.spinwish.backend.repositories.SongRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import se.michaelthelin.spotify.SpotifyApi;
import se.michaelthelin.spotify.model_objects.credentials.ClientCredentials;
import se.michaelthelin.spotify.model_objects.specification.Artist;
import se.michaelthelin.spotify.model_objects.specification.Paging;
import se.michaelthelin.spotify.model_objects.specification.Track;
import se.michaelthelin.spotify.requests.authorization.client_credentials.ClientCredentialsRequest;
import se.michaelthelin.spotify.requests.data.artists.GetArtistsTopTracksRequest;
import se.michaelthelin.spotify.requests.data.search.simplified.SearchArtistsRequest;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Service for fetching artists and songs from Spotify API.
 * Runs scheduled tasks to crawl Spotify data and populate the database.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class SpotifyFetchService {

    private final SpotifyApi spotifyApi;
    private final ArtistRepository artistRepository;
    private final SongRepository songRepository;

    @Value("${spotify.fetch.enabled:true}")
    private boolean fetchEnabled;

    @Value("${spotify.fetch.rate-limit-delay-ms:300}")
    private long rateLimitDelayMs;

    private final AtomicInteger artistsProcessed = new AtomicInteger(0);
    private final AtomicInteger songsProcessed = new AtomicInteger(0);

    /**
     * Authenticates with Spotify API using client credentials flow.
     * Must be called before making any API requests.
     */
    private void authenticate() throws Exception {
        try {
            ClientCredentialsRequest clientCredentialsRequest = spotifyApi.clientCredentials().build();
            ClientCredentials clientCredentials = clientCredentialsRequest.execute();
            spotifyApi.setAccessToken(clientCredentials.getAccessToken());
            log.info("Successfully authenticated with Spotify API");
        } catch (Exception e) {
            log.error("Failed to authenticate with Spotify API: {}", e.getMessage());
            throw e;
        }
    }

    /**
     * Scheduled task to crawl all artists from Spotify.
     * Runs every 66 seconds (approximately 1 minute).
     * Searches for artists using alphabetic and numeric queries.
     */
    @Scheduled(fixedRate = 66000)
    public void crawlAllArtists() {
        if (!fetchEnabled) {
            log.debug("Spotify fetch is disabled");
            return;
        }

        try {
            log.info("Starting Spotify artist crawl...");
            authenticate();

            String[] queries = {
                    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
                    "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
                    "w", "x", "y", "z",
                    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
            };

            int totalArtists = 0;
            int totalSongs = 0;

            for (String q : queries) {
                int offset = 0;
                int limit = 50;

                while (true) {
                    try {
                        SearchArtistsRequest searchArtistsRequest = spotifyApi.searchArtists(q)
                                .limit(limit)
                                .offset(offset)
                                .build();

                        Paging<Artist> artistPaging = searchArtistsRequest.execute();
                        Artist[] artists = artistPaging.getItems();

                        if (artists.length == 0) break;

                        for (Artist artist : artists) {
                            try {
                                Artists saved = saveArtistIfNotExists(artist);

                                if (saved != null) {
                                    totalArtists++;
                                    int songsAdded = fetchAndSaveTopSongsAllMarkets(saved, artist.getId());
                                    totalSongs += songsAdded;
                                }
                            } catch (Exception e) {
                                log.error("Error processing artist {}: {}", artist.getName(), e.getMessage());
                            }
                        }

                        offset += limit;
                        if (offset >= artistPaging.getTotal()) break;
                        
                        // Rate limiting
                        Thread.sleep(rateLimitDelayMs);
                        
                    } catch (Exception e) {
                        log.error("Error searching artists with query '{}': {}", q, e.getMessage());
                        break;
                    }
                }
            }

            log.info("Spotify crawl completed. Artists processed: {}, Songs processed: {}", 
                    totalArtists, totalSongs);

        } catch (Exception e) {
            log.error("Error during Spotify artist crawl: {}", e.getMessage(), e);
        }
    }

    /**
     * Saves an artist to the database if it doesn't already exist.
     *
     * @param artist Spotify Artist object
     * @return Saved Artists entity or existing entity if already present
     */
    private Artists saveArtistIfNotExists(Artist artist) {
        try {
            Optional<Artists> existing = artistRepository.findByName(artist.getName());

            if (existing.isPresent()) {
                log.debug("Artist already exists: {}", artist.getName());
                return existing.get();
            }

            Artists newArtist = new Artists();
            newArtist.setName(artist.getName());

            if (artist.getImages() != null && artist.getImages().length > 0) {
                newArtist.setImageUrl(artist.getImages()[0].getUrl());
            }

            // Spotify doesn't provide bio, so we leave it empty or could add genres
            String bio = "";
            if (artist.getGenres() != null && artist.getGenres().length > 0) {
                bio = "Genres: " + String.join(", ", artist.getGenres());
            }
            newArtist.setBio(bio);
            
            newArtist.setCreatedAt(LocalDateTime.now());
            newArtist.setUpdatedAt(LocalDateTime.now());

            Artists saved = artistRepository.save(newArtist);
            log.info("Saved new artist: {}", artist.getName());
            artistsProcessed.incrementAndGet();
            
            return saved;
            
        } catch (Exception e) {
            log.error("Error saving artist {}: {}", artist.getName(), e.getMessage());
            return null;
        }
    }

    /**
     * Fetches and saves top tracks for an artist across all markets.
     *
     * @param artistEntity The Artists entity from our database
     * @param spotifyArtistId The Spotify artist ID
     * @return Number of songs added
     */
    private int fetchAndSaveTopSongsAllMarkets(Artists artistEntity, String spotifyArtistId) {
        int songsAdded = 0;
        
        // Limit to major markets to avoid excessive API calls
        CountryCode[] majorMarkets = {
                CountryCode.US, CountryCode.GB, CountryCode.CA, CountryCode.AU,
                CountryCode.DE, CountryCode.FR, CountryCode.ES, CountryCode.IT,
                CountryCode.BR, CountryCode.MX, CountryCode.JP, CountryCode.KR,
                CountryCode.IN, CountryCode.ZA, CountryCode.KE, CountryCode.NG
        };
        
        for (CountryCode country : majorMarkets) {
            try {
                GetArtistsTopTracksRequest topTracksRequest =
                        spotifyApi.getArtistsTopTracks(spotifyArtistId, country)
                                .build();

                Track[] tracks = topTracksRequest.execute();

                for (Track track : tracks) {
                    try {
                        String albumName = track.getAlbum() != null ? track.getAlbum().getName() : "";
                        String spotifyUrl = track.getExternalUrls() != null ? 
                                track.getExternalUrls().get("spotify") : null;

                        // Check if song already exists by Spotify URL or name+artist+album
                        boolean exists = (spotifyUrl != null && songRepository.existsBySpotifyUrl(spotifyUrl)) ||
                                songRepository.existsByNameAndArtistIdAndAlbum(
                                        track.getName(), artistEntity.getId(), albumName);

                        if (!exists) {
                            Songs newSong = new Songs();
                            newSong.setName(track.getName());
                            newSong.setArtistId(artistEntity.getId());
                            newSong.setAlbum(albumName);
                            newSong.setDuration(track.getDurationMs() / 1000); // Convert ms to seconds
                            newSong.setSpotifyUrl(spotifyUrl);
                            newSong.setPopularity(track.getPopularity());
                            newSong.setIsExplicit(track.getIsExplicit());
                            
                            // Set artwork from album
                            if (track.getAlbum() != null && track.getAlbum().getImages() != null 
                                    && track.getAlbum().getImages().length > 0) {
                                newSong.setArtworkUrl(track.getAlbum().getImages()[0].getUrl());
                            }
                            
                            // Set genre from artist bio or default
                            newSong.setGenre(extractGenreFromArtist(artistEntity));
                            
                            // Set base request price based on popularity
                            newSong.setBaseRequestPrice(calculateBasePrice(track.getPopularity()));
                            
                            newSong.setCreatedAt(LocalDateTime.now());
                            newSong.setUpdatedAt(LocalDateTime.now());

                            songRepository.save(newSong);
                            songsProcessed.incrementAndGet();
                            songsAdded++;
                            
                            log.debug("Saved new song: {} by {}", track.getName(), artistEntity.getName());
                        }
                    } catch (Exception e) {
                        log.error("Error saving track {}: {}", track.getName(), e.getMessage());
                    }
                }

                // Rate limiting between market requests
                Thread.sleep(rateLimitDelayMs);

            } catch (Exception e) {
                log.error("Error fetching top tracks for artist {} in {}: {}", 
                        artistEntity.getName(), country, e.getMessage());
            }
        }
        
        return songsAdded;
    }

    /**
     * Extracts genre from artist bio or returns default.
     */
    private String extractGenreFromArtist(Artists artist) {
        if (artist.getBio() != null && artist.getBio().startsWith("Genres: ")) {
            String genres = artist.getBio().substring(8);
            String[] genreArray = genres.split(", ");
            return genreArray.length > 0 ? genreArray[0] : "Pop";
        }
        return "Pop"; // Default genre
    }

    /**
     * Calculates base request price based on song popularity.
     * More popular songs have higher base prices.
     */
    private double calculateBasePrice(int popularity) {
        if (popularity >= 80) return 50.0;
        if (popularity >= 60) return 30.0;
        if (popularity >= 40) return 20.0;
        if (popularity >= 20) return 15.0;
        return 10.0;
    }

    /**
     * Get statistics about the fetch service.
     */
    public String getStatistics() {
        return String.format("Artists processed: %d, Songs processed: %d", 
                artistsProcessed.get(), songsProcessed.get());
    }
}

