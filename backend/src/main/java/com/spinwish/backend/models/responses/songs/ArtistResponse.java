package com.spinwish.backend.models.responses.songs;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class ArtistResponse {
    private UUID id;
    private String name;
    private String bio;
    private String imageUrl;
    private LocalDateTime createdAt;
}
