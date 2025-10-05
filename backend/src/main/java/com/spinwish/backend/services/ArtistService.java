package com.spinwish.backend.services;

import com.spinwish.backend.entities.Artists;
import com.spinwish.backend.entities.Profile;
import com.spinwish.backend.entities.Users;
import com.spinwish.backend.exceptions.UserAlreadyExistsException;
import com.spinwish.backend.exceptions.UserNotExistingException;
import com.spinwish.backend.models.requests.songs.ArtistRequest;
import com.spinwish.backend.models.requests.users.ProfileRequest;
import com.spinwish.backend.models.responses.songs.ArtistResponse;
import com.spinwish.backend.models.responses.users.ProfileResponse;
import com.spinwish.backend.repositories.ArtistRepository;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@Slf4j
public class ArtistService {
    @Autowired
    private ArtistRepository artistRepository;

    private final Path rootLocation = Paths.get("uploads/artists-images");

    @PostConstruct
    public void init() {
        try {
            Files.createDirectories(rootLocation);
        } catch (IOException e) {
            throw new RuntimeException("Could not initialize folder for upload!");
        }
    }

    @Transactional
    public ArtistResponse createArtist(ArtistRequest artistRequest) throws IOException {
        // Check if an artist with the same name already exists
        Optional<Artists> existingArtist = artistRepository.findByName(artistRequest.getName());
        if (existingArtist.isPresent()) {
            throw new UserAlreadyExistsException("An artist with this name already exists.");
        }

        Artists artist = new Artists();
        artist.setName(artistRequest.getName());
        artist.setBio(artistRequest.getBio());
        artist.setCreatedAt(LocalDateTime.now());
        artist.setUpdatedAt(LocalDateTime.now());

        if (artistRequest.getImage() != null && !artistRequest.getImage().isEmpty()) {
            String originalFilename = artistRequest.getImage().getOriginalFilename();
            assert originalFilename != null;
            String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            String newFileName = UUID.randomUUID() + fileExtension;

            Path destinationFile = this.rootLocation.resolve(Paths.get(newFileName)).normalize().toAbsolutePath();
            Files.copy(artistRequest.getImage().getInputStream(), destinationFile, StandardCopyOption.REPLACE_EXISTING);

            artist.setImageUrl("/uploads/artists-images/" + newFileName);
        }

        artistRepository.save(artist);
        return convertArtistResponse(artist);
    }

    public List<ArtistResponse> getAllArtists() {
        return artistRepository.findAll()
                .stream()
                .map(this::convertArtistResponse)
                .toList();
    }

    public ArtistResponse getArtistById(UUID id) {
        Artists artist = artistRepository.findById(id)
                .orElseThrow(() -> new UserNotExistingException("Artist not found."));
        return convertArtistResponse(artist);
    }

    public void deleteArtist(UUID id) {
        artistRepository.deleteById(id);
    }

    @Transactional
    public ArtistResponse updateArtist(UUID id, ArtistRequest request) throws IOException {
        Artists artist = artistRepository.findById(id)
                .orElseThrow(() -> new UserNotExistingException("Artist not found."));

        artist.setName(request.getName());
        artist.setBio(request.getBio());
        artist.setUpdatedAt(LocalDateTime.now());

        if (request.getImage() != null && !request.getImage().isEmpty()) {
            String originalFilename = request.getImage().getOriginalFilename();
            String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            String newFileName = UUID.randomUUID() + extension;

            Path destination = rootLocation.resolve(Paths.get(newFileName)).normalize().toAbsolutePath();
            Files.copy(request.getImage().getInputStream(), destination, StandardCopyOption.REPLACE_EXISTING);

            artist.setImageUrl("/uploads/artists-images/" + newFileName);
        }

        artistRepository.save(artist);
        return convertArtistResponse(artist);
    }


    private ArtistResponse convertArtistResponse(Artists artist) {
        ArtistResponse artistResponse = new ArtistResponse();
        artistResponse.setBio(artist.getBio());
        artistResponse.setId(artist.getId());
        artistResponse.setName(artist.getName());
        artistResponse.setImageUrl(artist.getImageUrl());
        artistResponse.setCreatedAt(artist.getCreatedAt());
        return artistResponse;
    }
}
