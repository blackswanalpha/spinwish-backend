package com.spinwish.backend.models.responses.requests;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Detailed response for song requests including user and song information
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RequestDetailResponse {
    // Request info
    private UUID requestId;
    private String status;
    private Double amount;
    private String message;
    private Integer queuePosition;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Requester info
    private UUID requesterId;
    private String requesterName;
    private String requesterEmail;
    private String requesterProfileImage;
    
    // Song info
    private UUID songId;
    private String songTitle;
    private String songArtist;
    private String songAlbum;
    private String songImageUrl;
    private Integer songDuration;
    
    // Session info
    private UUID sessionId;
    private String sessionTitle;
    
    // DJ info
    private UUID djId;
    private String djName;
}

