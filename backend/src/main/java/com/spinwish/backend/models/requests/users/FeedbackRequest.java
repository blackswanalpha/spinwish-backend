package com.spinwish.backend.models.requests.users;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class FeedbackRequest {
    private UUID id;
    private String message;
    private String userId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
