package com.spinwish.backend.controllers;

import com.spinwish.backend.entities.Session;
import com.spinwish.backend.models.responses.sessions.SessionAnalyticsResponse;
import com.spinwish.backend.services.SessionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import jakarta.transaction.Transactional;

@RestController
@RequestMapping(path = "api/v1/sessions")
@Tag(name = "Session Management", description = "APIs for managing DJ sessions")
@Slf4j
public class SessionController {

    @Autowired
    private SessionService sessionService;

    /**
     * Helper method to convert Session entity to clean Map to avoid Hibernate proxy issues
     */
    private Map<String, Object> sessionToMap(Session session) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", session.getId().toString());
        map.put("djId", session.getDjId().toString());
        map.put("clubId", session.getClubId() != null ? session.getClubId().toString() : null);
        map.put("type", session.getType().name());
        map.put("status", session.getStatus().name());
        map.put("title", session.getTitle());
        map.put("description", session.getDescription());
        map.put("startTime", session.getStartTime());
        map.put("endTime", session.getEndTime());
        map.put("listenerCount", session.getListenerCount());
        map.put("totalEarnings", session.getTotalEarnings());
        map.put("totalTips", session.getTotalTips());
        map.put("totalRequests", session.getTotalRequests());
        map.put("acceptedRequests", session.getAcceptedRequests());
        map.put("rejectedRequests", session.getRejectedRequests());
        map.put("isAcceptingRequests", session.getIsAcceptingRequests());
        map.put("minTipAmount", session.getMinTipAmount());
        map.put("genres", session.getGenres());
        map.put("shareableLink", session.getShareableLink());
        map.put("imageUrl", session.getImageUrl());
        map.put("thumbnailUrl", session.getThumbnailUrl());
        return map;
    }

    @Operation(
            summary = "Create a new session",
            description = "Create a new DJ session",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "201",
                    description = "Session created successfully",
                    content = @Content(schema = @Schema(implementation = Session.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid session data"
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            )
    })
    @PostMapping
    @Transactional
    public ResponseEntity<?> createSession(
            @Parameter(description = "Session details", required = true)
            @RequestBody Session session) {
        try {
            Session createdSession = sessionService.createSession(session);
            return new ResponseEntity<>(sessionToMap(createdSession), HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to create session: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Get all sessions",
            description = "Retrieve all sessions",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Sessions retrieved successfully",
                    content = @Content(schema = @Schema(implementation = Session.class))
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            )
    })
    @GetMapping
    public ResponseEntity<List<Session>> getAllSessions() {
        List<Session> sessions = sessionService.getAllSessions();
        return new ResponseEntity<>(sessions, HttpStatus.OK);
    }

    @Operation(
            summary = "Get session by ID",
            description = "Retrieve a specific session by its ID",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Session found",
                    content = @Content(schema = @Schema(implementation = Session.class))
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Session not found"
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            )
    })
    @GetMapping("/{sessionId}")
    @Transactional
    public ResponseEntity<?> getSessionById(
            @Parameter(description = "Session ID", required = true)
            @PathVariable UUID sessionId) {
        Optional<Session> session = sessionService.getSessionById(sessionId);
        if (session.isPresent()) {
            return new ResponseEntity<>(sessionToMap(session.get()), HttpStatus.OK);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Session not found with id: " + sessionId);
        }
    }

    @Operation(
            summary = "Get active sessions",
            description = "Retrieve all active sessions (LIVE or PREPARING status)",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/active")
    public ResponseEntity<List<Session>> getActiveSessions() {
        List<Session> sessions = sessionService.getActiveSessions();
        return new ResponseEntity<>(sessions, HttpStatus.OK);
    }

    @Operation(
            summary = "Get live sessions",
            description = "Retrieve all live sessions",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/live")
    public ResponseEntity<List<Session>> getLiveSessions() {
        List<Session> sessions = sessionService.getLiveSessions();
        return new ResponseEntity<>(sessions, HttpStatus.OK);
    }

    @Operation(
            summary = "Get sessions by DJ",
            description = "Retrieve all sessions for a specific DJ",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/dj/{djId}")
    public ResponseEntity<List<Session>> getSessionsByDj(
            @Parameter(description = "DJ ID", required = true)
            @PathVariable UUID djId) {
        List<Session> sessions = sessionService.getSessionsByDj(djId);
        return new ResponseEntity<>(sessions, HttpStatus.OK);
    }

    @Operation(
            summary = "Get sessions by club",
            description = "Retrieve all sessions for a specific club",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/club/{clubId}")
    public ResponseEntity<List<Session>> getSessionsByClub(
            @Parameter(description = "Club ID", required = true)
            @PathVariable UUID clubId) {
        List<Session> sessions = sessionService.getSessionsByClub(clubId);
        return new ResponseEntity<>(sessions, HttpStatus.OK);
    }

    @Operation(
            summary = "Get sessions by genre",
            description = "Retrieve sessions that include a specific genre",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/genre/{genre}")
    public ResponseEntity<List<Session>> getSessionsByGenre(
            @Parameter(description = "Genre name", required = true)
            @PathVariable String genre) {
        List<Session> sessions = sessionService.getSessionsByGenre(genre);
        return new ResponseEntity<>(sessions, HttpStatus.OK);
    }

    @Operation(
            summary = "Get sessions accepting requests",
            description = "Retrieve sessions that are currently accepting song requests",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/accepting-requests")
    public ResponseEntity<List<Session>> getSessionsAcceptingRequests() {
        List<Session> sessions = sessionService.getSessionsAcceptingRequests();
        return new ResponseEntity<>(sessions, HttpStatus.OK);
    }

    @Operation(
            summary = "Get sessions by status",
            description = "Retrieve sessions with a specific status",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/status/{status}")
    public ResponseEntity<List<Session>> getSessionsByStatus(
            @Parameter(description = "Session status", required = true)
            @PathVariable Session.SessionStatus status) {
        List<Session> sessions = sessionService.getSessionsByStatus(status);
        return new ResponseEntity<>(sessions, HttpStatus.OK);
    }

    @Operation(
            summary = "Get sessions by type",
            description = "Retrieve sessions with a specific type",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/type/{type}")
    public ResponseEntity<List<Session>> getSessionsByType(
            @Parameter(description = "Session type", required = true)
            @PathVariable Session.SessionType type) {
        List<Session> sessions = sessionService.getSessionsByType(type);
        return new ResponseEntity<>(sessions, HttpStatus.OK);
    }

    @Operation(
            summary = "Start session",
            description = "Change session status to LIVE",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @PutMapping("/{sessionId}/start")
    @Transactional
    public ResponseEntity<?> startSession(
            @Parameter(description = "Session ID", required = true)
            @PathVariable UUID sessionId) {
        try {
            Session session = sessionService.startSession(sessionId);
            return new ResponseEntity<>(sessionToMap(session), HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to start session: " + e.getMessage());
        }
    }

    @Operation(
            summary = "End session",
            description = "Change session status to ENDED",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @PutMapping("/{sessionId}/end")
    @Transactional
    public ResponseEntity<?> endSession(
            @Parameter(description = "Session ID", required = true)
            @PathVariable UUID sessionId) {
        try {
            Session session = sessionService.endSession(sessionId);
            return new ResponseEntity<>(sessionToMap(session), HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to end session: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Pause session",
            description = "Change session status to PAUSED",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @PutMapping("/{sessionId}/pause")
    @Transactional
    public ResponseEntity<?> pauseSession(
            @Parameter(description = "Session ID", required = true)
            @PathVariable UUID sessionId) {
        try {
            Session session = sessionService.pauseSession(sessionId);
            return new ResponseEntity<>(sessionToMap(session), HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to pause session: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Update session",
            description = "Update session details",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @PutMapping("/{sessionId}")
    @Transactional
    public ResponseEntity<?> updateSession(
            @Parameter(description = "Session ID", required = true)
            @PathVariable UUID sessionId,
            @Parameter(description = "Updated session details", required = true)
            @RequestBody Session updatedSession) {
        try {
            Session session = sessionService.updateSession(sessionId, updatedSession);
            return new ResponseEntity<>(sessionToMap(session), HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to update session: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Update listener count",
            description = "Update the number of listeners for a session",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @PutMapping("/{sessionId}/listeners/{count}")
    public ResponseEntity<?> updateListenerCount(
            @Parameter(description = "Session ID", required = true)
            @PathVariable UUID sessionId,
            @Parameter(description = "Listener count", required = true)
            @PathVariable Integer count) {
        try {
            Session session = sessionService.updateListenerCount(sessionId, count);
            return new ResponseEntity<>(session, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to update listener count: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Get sessions by date range",
            description = "Retrieve sessions within a specific date range",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/date-range")
    public ResponseEntity<List<Session>> getSessionsByDateRange(
            @Parameter(description = "Start date (ISO format: yyyy-MM-dd)", required = true)
            @RequestParam String startDate,
            @Parameter(description = "End date (ISO format: yyyy-MM-dd)", required = true)
            @RequestParam String endDate) {
        try {
            List<Session> sessions = sessionService.getSessionsByDateRange(startDate, endDate);
            return new ResponseEntity<>(sessions, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
        }
    }

    @Operation(
            summary = "Get today's live sessions",
            description = "Retrieve all live sessions for today",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/today/live")
    public ResponseEntity<List<Session>> getTodaysLiveSessions() {
        List<Session> sessions = sessionService.getTodaysLiveSessions();
        return new ResponseEntity<>(sessions, HttpStatus.OK);
    }

    @Operation(
            summary = "Delete session",
            description = "Delete a session",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @DeleteMapping("/{sessionId}")
    public ResponseEntity<?> deleteSession(
            @Parameter(description = "Session ID", required = true)
            @PathVariable UUID sessionId) {
        try {
            sessionService.deleteSession(sessionId);
            return ResponseEntity.ok("Session deleted successfully");
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to delete session: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Upload session image",
            description = "Upload an image for a DJ session. Only the DJ who owns the session can upload images.",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Image uploaded successfully",
                    content = @Content(schema = @Schema(implementation = Session.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid image file or session not found"
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            ),
            @ApiResponse(
                    responseCode = "413",
                    description = "File size exceeds maximum allowed size"
            )
    })
    @PostMapping("/{sessionId}/upload-image")
    @Transactional
    public ResponseEntity<?> uploadSessionImage(
            @Parameter(description = "Session ID", required = true)
            @PathVariable UUID sessionId,
            @Parameter(description = "Image file to upload", required = true)
            @RequestParam("image") MultipartFile imageFile) {

        log.info("Received image upload request for session: {}", sessionId);

        // Validate that file is not empty
        if (imageFile == null || imageFile.isEmpty()) {
            log.error("Image file is null or empty");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", "Image file is required"));
        }

        log.debug("Image file details - Name: {}, Size: {} bytes, Content-Type: {}",
                imageFile.getOriginalFilename(),
                imageFile.getSize(),
                imageFile.getContentType());

        try {
            Session session = sessionService.uploadSessionImage(sessionId, imageFile);
            log.info("Successfully uploaded image for session: {}", sessionId);
            return new ResponseEntity<>(sessionToMap(session), HttpStatus.OK);
        } catch (IOException e) {
            log.error("IO error while uploading image for session {}: {}", sessionId, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of(
                            "error", "Failed to upload image",
                            "message", e.getMessage(),
                            "sessionId", sessionId.toString()
                    ));
        } catch (RuntimeException e) {
            log.error("Runtime error while uploading image for session {}: {}", sessionId, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of(
                            "error", "Failed to upload image",
                            "message", e.getMessage(),
                            "sessionId", sessionId.toString()
                    ));
        } catch (Exception e) {
            log.error("Unexpected error while uploading image for session {}: {}", sessionId, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of(
                            "error", "Unexpected error occurred",
                            "message", e.getMessage(),
                            "sessionId", sessionId.toString()
                    ));
        }
    }

    @Operation(
            summary = "Delete session image",
            description = "Delete the image associated with a DJ session",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Image deleted successfully",
                    content = @Content(schema = @Schema(implementation = Session.class))
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Session not found"
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            )
    })
    @DeleteMapping("/{sessionId}/image")
    @Transactional
    public ResponseEntity<?> deleteSessionImage(
            @Parameter(description = "Session ID", required = true)
            @PathVariable UUID sessionId) {
        try {
            Session session = sessionService.deleteSessionImage(sessionId);
            return new ResponseEntity<>(sessionToMap(session), HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Failed to delete image: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Get session analytics",
            description = "Get comprehensive analytics for a specific session including earnings, requests, and performance metrics",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Analytics retrieved successfully",
                    content = @Content(schema = @Schema(implementation = SessionAnalyticsResponse.class))
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Session not found"
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            )
    })
    @GetMapping("/{sessionId}/analytics")
    public ResponseEntity<?> getSessionAnalytics(
            @Parameter(description = "Session ID", required = true)
            @PathVariable UUID sessionId) {
        try {
            SessionAnalyticsResponse analytics = sessionService.getSessionAnalytics(sessionId);
            return ResponseEntity.ok(analytics);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Failed to get analytics: " + e.getMessage());
        }
    }
}
