package com.spinwish.backend.models.responses.songs;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class FeedbackResponse {
    private UUID id;
    private String message;
    private String userId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
