package com.spinwish.backend.services;

import com.spinwish.backend.entities.Artists;
import com.spinwish.backend.entities.Roles;
import com.spinwish.backend.entities.Songs;
import com.spinwish.backend.entities.Users;
import com.spinwish.backend.repositories.ArtistRepository;
import com.spinwish.backend.repositories.RoleRepository;
import com.spinwish.backend.repositories.SongRepository;
import com.spinwish.backend.repositories.UsersRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@Slf4j
public class DataPopulationService {

    @Autowired
    private UsersRepository usersRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private ArtistRepository artistRepository;

    @Autowired
    private SongRepository songRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Transactional
    public void populateTestData() {
        log.info("Starting test data population...");
        
        try {
            // Ensure DJ role exists
            ensureDJRoleExists();
            
            // Create artists first
            createSampleArtists();
            
            // Create DJ users
            createSampleDJs();
            
            // Create songs
            createSampleSongs();
            
            log.info("Test data population completed successfully!");
        } catch (Exception e) {
            log.error("Error during test data population: ", e);
            throw new RuntimeException("Failed to populate test data", e);
        }
    }

    private void ensureDJRoleExists() {
        Roles djRole = roleRepository.findByRoleName("DJ");
        if (djRole == null) {
            Roles role = new Roles();
            role.setRoleName("DJ");
            role.setCreatedAt(LocalDateTime.now());
            role.setUpdatedAt(LocalDateTime.now());
            roleRepository.save(role);
            log.info("Created DJ role");
        }
    }

    private void createSampleArtists() {
        String[][] artistsData = {
            {"Stellar Waves", "Afro-Electronic music collective from Nairobi", "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop"},
            {"Rhythm Collective", "High-energy Afrobeats group", "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&h=400&fit=crop"},
            {"Urban Pulse", "Contemporary African hip-hop artists", "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop"},
            {"Savanna Sounds", "Traditional meets modern fusion", "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&h=400&fit=crop"},
            {"Neon Nights", "Electronic dance music producers", "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&h=500&fit=crop"}
        };

        for (String[] artistData : artistsData) {
            Optional<Artists> existingArtist = artistRepository.findByName(artistData[0]);
            if (existingArtist.isEmpty()) {
                Artists artist = new Artists();
                artist.setName(artistData[0]);
                artist.setBio(artistData[1]);
                artist.setImageUrl(artistData[2]);
                artist.setCreatedAt(LocalDateTime.now());
                artist.setUpdatedAt(LocalDateTime.now());
                artistRepository.save(artist);
                log.info("Created artist: {}", artistData[0]);
            }
        }
    }

    private void createSampleDJs() {
        Roles djRole = roleRepository.findByRoleName("DJ");
        
        Object[][] djsData = {
            {"dj_nexus", "dj.nexus@spinwish.com", "Electronic music producer and DJ with 8+ years of experience. Specializing in progressive house, techno, and ambient soundscapes.", 
             "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop&crop=face", 4.8, 2847, true, "@dj_nexus_official", 
             Arrays.asList("Electronic", "House", "Techno", "Progressive", "Ambient")},
            {"rhythm_queen", "rhythm.queen@spinwish.com", "Afrobeats sensation bringing the heat from Lagos to the world. Known for infectious rhythms and crowd-moving performances.", 
             "https://images.unsplash.com/photo-1494790108755-2616c0763c5e?w=400&h=400&fit=crop&crop=face", 4.9, 3521, false, "@rhythm_queen_ke", 
             Arrays.asList("Afrobeats", "Dancehall", "Reggae", "Amapiano")},
            {"bass_master", "bass.master@spinwish.com", "Deep house and bass music specialist. Creating underground vibes that make you move.", 
             "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face", 4.7, 1892, true, "@bass_master_ke", 
             Arrays.asList("Deep House", "Bass", "Underground", "Minimal")},
            {"afro_fusion", "afro.fusion@spinwish.com", "Blending traditional African sounds with modern electronic beats. Cultural ambassador through music.", 
             "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face", 4.6, 2156, false, "@afro_fusion_dj", 
             Arrays.asList("Afro-Fusion", "World Music", "Traditional", "Electronic")},
            {"urban_vibes", "urban.vibes@spinwish.com", "Hip-hop and R&B curator with a passion for discovering new talent. Known for seamless mixing.", 
             "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop&crop=face", 4.5, 1743, true, "@urban_vibes_dj", 
             Arrays.asList("Hip-Hop", "R&B", "Urban", "Trap")}
        };

        for (Object[] djData : djsData) {
            Users existingUser = usersRepository.findByEmailAddress((String) djData[1]);
            if (existingUser == null) {
                Users dj = new Users();
                dj.setActualUsername((String) djData[0]);
                dj.setEmailAddress((String) djData[1]);
                dj.setPassword(passwordEncoder.encode("password123")); // Default password
                dj.setBio((String) djData[2]);
                dj.setProfileImage((String) djData[3]);
                dj.setRating((Double) djData[4]);
                dj.setFollowers((Integer) djData[5]);
                dj.setIsLive((Boolean) djData[6]);
                dj.setInstagramHandle((String) djData[7]);
                dj.setGenres((List<String>) djData[8]);
                dj.setRole(djRole);
                dj.setIsActive(true);
                dj.setEmailVerified(true);
                dj.setPhoneVerified(true);
                dj.setCreatedAt(LocalDateTime.now());
                dj.setUpdatedAt(LocalDateTime.now());
                
                usersRepository.save(dj);
                log.info("Created DJ: {}", djData[0]);
            }
        }
    }

    private void createSampleSongs() {
        // Get artists for song creation
        List<Artists> artists = artistRepository.findAll();
        if (artists.isEmpty()) {
            log.warn("No artists found, cannot create songs");
            return;
        }

        // Sample songs data (first 10 for brevity)
        Object[][] songsData = {
            {"Midnight Safari", "African Frequencies", "Afro-Electronic", 247, "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&h=500&fit=crop", 25.0, 87, false},
            {"Fire on the Dance Floor", "Lagos Nights", "Afrobeats", 203, "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&h=500&fit=crop", 30.0, 94, false},
            {"Urban Dreams", "City Lights", "Hip-Hop", 189, "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&h=500&fit=crop", 20.0, 76, false},
            {"Savanna Sunrise", "Heritage Sounds", "World Music", 234, "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&h=500&fit=crop", 22.0, 82, false},
            {"Neon Pulse", "Electric Dreams", "Electronic", 198, "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&h=500&fit=crop", 28.0, 91, false},
            {"Rhythm of the Heart", "Lagos Nights", "Afrobeats", 215, "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&h=500&fit=crop", 25.0, 88, false},
            {"Digital Waves", "African Frequencies", "Electronic", 267, "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&h=500&fit=crop", 32.0, 79, false},
            {"Street Symphony", "City Lights", "Hip-Hop", 201, "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&h=500&fit=crop", 18.0, 85, false},
            {"Ancient Echoes", "Heritage Sounds", "Traditional", 289, "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&h=500&fit=crop", 24.0, 73, false},
            {"Bass Drop Revolution", "Electric Dreams", "Bass", 178, "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&h=500&fit=crop", 35.0, 96, false}
        };

        for (int i = 0; i < songsData.length; i++) {
            Object[] songData = songsData[i];
            Artists artist = artists.get(i % artists.size()); // Cycle through artists
            
            // Check if song already exists
            boolean exists = songRepository.existsByNameAndArtistIdAndAlbum(
                (String) songData[0], artist.getId(), (String) songData[1]);
            
            if (!exists) {
                Songs song = new Songs();
                song.setName((String) songData[0]);
                song.setAlbum((String) songData[1]);
                song.setGenre((String) songData[2]);
                song.setDuration((Integer) songData[3]);
                song.setArtworkUrl((String) songData[4]);
                song.setBaseRequestPrice((Double) songData[5]);
                song.setPopularity((Integer) songData[6]);
                song.setIsExplicit((Boolean) songData[7]);
                song.setArtistId(artist.getId());
                song.setCreatedAt(LocalDateTime.now());
                song.setUpdatedAt(LocalDateTime.now());
                
                songRepository.save(song);
                log.info("Created song: {}", songData[0]);
            }
        }
    }

    public long getDJCount() {
        Roles djRole = roleRepository.findByRoleName("DJ");
        if (djRole == null) return 0;
        
        return usersRepository.findAll().stream()
            .filter(user -> user.getRole() != null && "DJ".equals(user.getRole().getRoleName()))
            .count();
    }

    public long getSongCount() {
        return songRepository.count();
    }

    public long getArtistCount() {
        return artistRepository.count();
    }
}
