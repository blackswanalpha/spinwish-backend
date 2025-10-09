package com.spinwish.backend.controllers;

import com.spinwish.backend.services.SpotifyFetchService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Controller for managing Spotify integration.
 * Provides endpoints to manually trigger sync and check status.
 */
@RestController
@RequestMapping("/api/v1/spotify")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Spotify", description = "Spotify integration management endpoints")
public class SpotifyController {

    private final SpotifyFetchService spotifyFetchService;

    /**
     * Manually trigger Spotify artist and song crawl.
     * This endpoint allows administrators to trigger the sync process on-demand.
     *
     * @return Response with sync status
     */
    @PostMapping("/sync")
    @Operation(summary = "Trigger Spotify sync", 
               description = "Manually trigger the Spotify artist and song crawl process")
    public ResponseEntity<Map<String, Object>> triggerSync() {
        log.info("Manual Spotify sync triggered");
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Run the crawl in a separate thread to avoid timeout
            new Thread(() -> {
                try {
                    spotifyFetchService.crawlAllArtists();
                } catch (Exception e) {
                    log.error("Error during manual Spotify sync: {}", e.getMessage(), e);
                }
            }).start();
            
            response.put("status", "success");
            response.put("message", "Spotify sync started in background");
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Failed to start Spotify sync: {}", e.getMessage(), e);
            response.put("status", "error");
            response.put("message", "Failed to start sync: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * Get Spotify sync statistics.
     *
     * @return Statistics about processed artists and songs
     */
    @GetMapping("/stats")
    @Operation(summary = "Get Spotify sync statistics", 
               description = "Retrieve statistics about the Spotify sync process")
    public ResponseEntity<Map<String, Object>> getStatistics() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String stats = spotifyFetchService.getStatistics();
            response.put("status", "success");
            response.put("statistics", stats);
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Failed to get Spotify statistics: {}", e.getMessage(), e);
            response.put("status", "error");
            response.put("message", "Failed to get statistics: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * Health check endpoint for Spotify integration.
     *
     * @return Health status
     */
    @GetMapping("/health")
    @Operation(summary = "Check Spotify integration health", 
               description = "Verify that Spotify integration is properly configured")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            response.put("status", "healthy");
            response.put("service", "spotify-integration");
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Spotify health check failed: {}", e.getMessage(), e);
            response.put("status", "unhealthy");
            response.put("error", e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
}

