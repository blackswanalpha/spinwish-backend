package com.spinwish.backend.services;

import com.spinwish.backend.entities.Artists;
import com.spinwish.backend.entities.Songs;
import com.spinwish.backend.exceptions.UserNotExistingException;
import com.spinwish.backend.models.requests.songs.SongRequest;
import com.spinwish.backend.models.responses.songs.SongResponse;
import com.spinwish.backend.repositories.ArtistRepository;
import com.spinwish.backend.repositories.SongRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class SongService {

    @Autowired
    private SongRepository songRepository;

    @Autowired
    private ArtistRepository artistRepository;

    @Transactional
    public SongResponse create(SongRequest request) {
        boolean exists = songRepository.existsByNameAndArtistIdAndAlbum(
                request.getName(),
                request.getArtistId(),
                request.getAlbum()
        );
        if (exists) {
            throw new IllegalArgumentException("A song with the same name, artist, and album already exists.");
        }
        Songs song = new Songs();
        song.setName(request.getName());
        song.setAlbum(request.getAlbum());
        song.setArtistId(request.getArtistId());
        song.setCreatedAt(LocalDateTime.now());
        song.setUpdatedAt(LocalDateTime.now());
        songRepository.save(song);
        artistRepository.findById(request.getArtistId()).ifPresent(song::setArtist);

        return convert(song);
    }

    public List<SongResponse> getAll() {
        return songRepository.findAll().stream()
                .map(this::convert)
                .collect(Collectors.toList());
    }

    public SongResponse getById(UUID id) {
        Songs song = songRepository.findById(id)
                .orElseThrow(() -> new UserNotExistingException("Song not found"));
        return convert(song);
    }

    public void delete(UUID id) {
        songRepository.deleteById(id);
    }

    @Transactional
    public SongResponse update(UUID id, SongRequest request) {
        Songs song = songRepository.findById(id)
                .orElseThrow(() -> new UserNotExistingException("Song not found"));

        song.setName(request.getName());
        song.setAlbum(request.getAlbum());
        song.setArtistId(request.getArtistId());
        song.setUpdatedAt(LocalDateTime.now());

        songRepository.save(song);
        return convert(song);
    }

    private SongResponse convert(Songs song) {
        SongResponse response = new SongResponse();
        response.setId(song.getId());
        response.setName(song.getName());
        response.setTitle(song.getName()); // For Flutter compatibility
        response.setAlbum(song.getAlbum());
        response.setGenre(song.getGenre());
        response.setDuration(song.getDuration());
        response.setArtworkUrl(song.getArtworkUrl());
        response.setBaseRequestPrice(song.getBaseRequestPrice());
        response.setPopularity(song.getPopularity());
        response.setIsExplicit(song.getIsExplicit());
        response.setArtistId(song.getArtistId());

        // Set artist name from relationship if available
        if (song.getArtist() != null) {
            response.setArtistName(song.getArtist().getName());
            response.setArtist(song.getArtist().getName()); // For Flutter compatibility
        }

        response.setCreatedAt(song.getCreatedAt());
        response.setUpdatedAt(song.getUpdatedAt());
        return response;
    }
}
