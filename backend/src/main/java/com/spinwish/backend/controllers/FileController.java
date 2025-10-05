package com.spinwish.backend.controllers;

import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@RestController
@RequestMapping("/uploads")
public class FileController {

    private final Path profileImagesLocation = Paths.get("uploads/profile-images");
    private final Path artistImagesLocation = Paths.get("uploads/artists-images");
    private final Path sessionImagesLocation = Paths.get("uploads/session-images");

    @GetMapping("/profile-images/{filename:.+}")
    public ResponseEntity<Resource> serveProfileImage(@PathVariable String filename) {
        return serveFile(profileImagesLocation, filename);
    }

    @GetMapping("/artists-images/{filename:.+}")
    public ResponseEntity<Resource> serveArtistImage(@PathVariable String filename) {
        return serveFile(artistImagesLocation, filename);
    }

    @GetMapping("/session-images/{filename:.+}")
    public ResponseEntity<Resource> serveSessionImage(@PathVariable String filename) {
        return serveFile(sessionImagesLocation, filename);
    }

    private ResponseEntity<Resource> serveFile(Path location, String filename) {
        try {
            Path file = location.resolve(filename);
            Resource resource = new UrlResource(file.toUri());

            if (resource.exists() || resource.isReadable()) {
                // Determine content type
                String contentType = determineContentType(file);
                
                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(contentType))
                        .header(HttpHeaders.CACHE_CONTROL, "max-age=3600") // Cache for 1 hour
                        .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (MalformedURLException ex) {
            return ResponseEntity.badRequest().build();
        }
    }

    private String determineContentType(Path file) {
        try {
            String contentType = Files.probeContentType(file);
            if (contentType != null) {
                return contentType;
            }
        } catch (IOException ex) {
            // Fall back to default
        }

        // Fallback based on file extension
        String filename = file.getFileName().toString().toLowerCase();
        if (filename.endsWith(".png")) {
            return "image/png";
        } else if (filename.endsWith(".jpg") || filename.endsWith(".jpeg")) {
            return "image/jpeg";
        } else if (filename.endsWith(".gif")) {
            return "image/gif";
        } else if (filename.endsWith(".webp")) {
            return "image/webp";
        } else {
            return "application/octet-stream";
        }
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleException(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Error serving file: " + ex.getMessage());
    }
}
