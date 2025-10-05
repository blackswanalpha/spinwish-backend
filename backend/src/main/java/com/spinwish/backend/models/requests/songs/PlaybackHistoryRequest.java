package com.spinwish.backend.models.requests.songs;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class PlaybackHistoryRequest {
    private UUID id;
    private String requestId;
    private String clientId;
    private Boolean status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
