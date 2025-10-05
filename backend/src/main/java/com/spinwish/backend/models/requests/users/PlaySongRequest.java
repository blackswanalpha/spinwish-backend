package com.spinwish.backend.models.requests.users;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
public class PlaySongRequest {
    private String djId; // Changed from djEmailAddress to djId
    private String djEmailAddress; // Keep for backward compatibility
    private String songId;
    private List<String> songIds;
    private String sessionId; // Session ID for the request
    private String message; // Optional message from user
    private Double amount; // Tip/payment amount
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    /**
     * Get DJ ID as UUID, handling string conversion
     */
    public UUID getDjIdAsUuid() {
        if (djId == null || djId.trim().isEmpty()) {
            return null;
        }
        try {
            return UUID.fromString(djId);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    /**
     * Get Session ID as UUID, handling string conversion
     */
    public UUID getSessionIdAsUuid() {
        if (sessionId == null || sessionId.trim().isEmpty()) {
            return null;
        }
        try {
            return UUID.fromString(sessionId);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
