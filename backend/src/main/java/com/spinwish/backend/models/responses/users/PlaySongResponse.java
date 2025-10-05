package com.spinwish.backend.models.responses.users;

import com.spinwish.backend.models.responses.songs.SongResponse;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;
import java.util.List;

@Data
public class PlaySongResponse {
    private UUID id;
    private String clientName;
    private String djName;
    private Boolean status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private List<SongResponse> songResponse;
    private Double amount;
    private String message;
    private Integer queuePosition;
    private UUID sessionId;
}
