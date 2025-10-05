package com.spinwish.backend.models.requests.songs;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;

@Data
public class ArtistRequest {
    private String name;
    private String bio;
    private String imageUrl;
    private MultipartFile image;
    private LocalDateTime createdAt;
}
