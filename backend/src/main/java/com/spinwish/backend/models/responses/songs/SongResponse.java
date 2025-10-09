package com.spinwish.backend.models.responses.songs;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class SongResponse {
    private UUID id;
    private String name;
    private String title; // For Flutter compatibility
    private String album;
    private String genre;
    private Integer duration;
    private String artworkUrl;
    private Double baseRequestPrice;
    private Integer popularity;
    private Boolean isExplicit;
    private UUID artistId;
    private String artistName;
    private String artist; // For Flutter compatibility
    private String spotifyUrl;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
