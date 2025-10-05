package com.spinwish.backend.models.responses.songs;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class PlaybackHistoryResponse {
    private UUID id;
    private String clientId;
    private String djId;
    private String songId;
    private Boolean status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
