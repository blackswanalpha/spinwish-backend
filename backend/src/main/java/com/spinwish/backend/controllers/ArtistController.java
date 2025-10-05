package com.spinwish.backend.controllers;

import com.spinwish.backend.models.requests.songs.ArtistRequest;
import com.spinwish.backend.models.responses.songs.ArtistResponse;
import com.spinwish.backend.services.ArtistService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/artists")
public class ArtistController {

    @Autowired
    private ArtistService artistService;

    @PostMapping
    public ResponseEntity<ArtistResponse> createArtist(
            @ModelAttribute @Valid ArtistRequest artistRequest) throws IOException {
        ArtistResponse response = artistService.createArtist(artistRequest);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<List<ArtistResponse>> getAllArtists() {
        return ResponseEntity.ok(artistService.getAllArtists());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ArtistResponse> getArtistById(@PathVariable UUID id) {
        return ResponseEntity.ok(artistService.getArtistById(id));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteArtist(@PathVariable UUID id) {
        artistService.deleteArtist(id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<ArtistResponse> updateArtist(
            @PathVariable UUID id,
            @ModelAttribute @Valid ArtistRequest artistRequest) throws IOException {
        ArtistResponse response = artistService.updateArtist(id, artistRequest);
        return ResponseEntity.ok(response);
    }
}
