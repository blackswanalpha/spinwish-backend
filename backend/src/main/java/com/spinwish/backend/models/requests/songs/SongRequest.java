package com.spinwish.backend.models.requests.songs;

import lombok.Data;

import java.util.UUID;

@Data
public class SongRequest {
    private String name;
    private String album;
    private UUID artistId;
}
