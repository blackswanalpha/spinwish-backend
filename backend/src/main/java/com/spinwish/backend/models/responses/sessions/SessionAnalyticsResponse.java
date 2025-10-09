package com.spinwish.backend.models.responses.sessions;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Response DTO for session analytics data
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SessionAnalyticsResponse {
    private UUID sessionId;
    private String title;
    private String status;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    
    // Listener metrics
    private Integer activeListeners;
    private Integer peakListeners;
    
    // Request metrics
    private Integer totalRequests;
    private Integer pendingRequests;
    private Integer acceptedRequests;
    private Integer rejectedRequests;
    
    // Earnings metrics
    private Double totalEarnings;
    private Double totalTips;
    private Double totalRequestPayments;
    private Double averageTipAmount;
    private Double averageRequestAmount;
    
    // Performance metrics
    private Double acceptanceRate; // Percentage of accepted requests
    private Long sessionDurationMinutes;
    private Double earningsPerHour;
    private Double requestsPerHour;
}

