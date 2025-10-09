package com.spinwish.backend.controllers;

import com.spinwish.backend.exceptions.PlaySongException;
import com.spinwish.backend.models.requests.users.PlaySongRequest;
import com.spinwish.backend.models.responses.users.PlaySongResponse;
import com.spinwish.backend.services.RequestsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/requests")
@Tag(name = "Song Requests", description = "APIs for managing song requests between users and DJs")
public class RequestController {
    @Autowired
    private RequestsService requestsService;

    @Operation(
            summary = "Create a song request",
            description = "Create a new song request from a user to a DJ",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Request created successfully"),
            @ApiResponse(responseCode = "400", description = "Invalid request data"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping
    public ResponseEntity<?> create(@Valid @RequestBody PlaySongRequest playSongRequest) {
        try{
            PlaySongResponse playSongResponse = requestsService.createRequest(playSongRequest);
            return new ResponseEntity<>(playSongResponse, HttpStatus.CREATED);
        }catch (PlaySongException e){
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Failed to create: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Get request by ID",
            description = "Retrieve a specific song request by its ID",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Request retrieved successfully"),
            @ApiResponse(responseCode = "404", description = "Request not found"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required")
    })
    @GetMapping("/{id}")
    public ResponseEntity<?> getById(
            @Parameter(description = "Request ID", required = true)
            @PathVariable UUID id) {
        try {
            PlaySongResponse response = requestsService.getRequestById(id);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Request not found: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Get all requests",
            description = "Retrieve all song requests (admin/DJ access)",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Requests retrieved successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required")
    })
    @GetMapping
    public ResponseEntity<List<PlaySongResponse>> getAll() {
        return ResponseEntity.ok(requestsService.getAllRequests());
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable UUID id, @RequestBody PlaySongRequest request) {
        try {
            PlaySongResponse updated = requestsService.updateRequest(id, request);
            return ResponseEntity.ok(updated);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Failed to update: " + e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable UUID id) {
        try {
            requestsService.delete(id);
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Failed to delete: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Mark request as done",
            description = "Mark a song request as completed/played (DJ only)",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Request marked as done successfully"),
            @ApiResponse(responseCode = "404", description = "Request not found"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required"),
            @ApiResponse(responseCode = "403", description = "Forbidden - DJ role required")
    })
    @PreAuthorize("hasRole('DJ')")
    @PutMapping("/{id}/done")
    public ResponseEntity<?> markAsDone(
            @Parameter(description = "Request ID", required = true)
            @PathVariable UUID id) {
        try {
            PlaySongResponse response = requestsService.markRequestAsDone(id);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    @Operation(
            summary = "Get current user's requests",
            description = "Retrieve all song requests made by the current user",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User requests retrieved successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required")
    })
    @GetMapping("/my-requests")
    public ResponseEntity<List<PlaySongResponse>> getMyRequests() {
        List<PlaySongResponse> requests = requestsService.getCurrentUserRequests();
        return ResponseEntity.ok(requests);
    }

    @Operation(
            summary = "Get requests for current DJ",
            description = "Retrieve all song requests for the current DJ's sessions",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "DJ requests retrieved successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required"),
            @ApiResponse(responseCode = "403", description = "Forbidden - DJ role required")
    })
    @PreAuthorize("hasRole('DJ')")
    @GetMapping("/dj-requests")
    public ResponseEntity<List<PlaySongResponse>> getDJRequests() {
        List<PlaySongResponse> requests = requestsService.getCurrentDJRequests();
        return ResponseEntity.ok(requests);
    }

    @Operation(
            summary = "Get requests by status",
            description = "Retrieve requests filtered by status for the current user",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Filtered requests retrieved successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required")
    })
    @GetMapping("/my-requests/status/{status}")
    public ResponseEntity<List<PlaySongResponse>> getMyRequestsByStatus(
            @Parameter(description = "Request status (PENDING, ACCEPTED, REJECTED, PLAYED)", required = true)
            @PathVariable String status) {
        try {
            List<PlaySongResponse> requests = requestsService.getCurrentUserRequestsByStatus(status);
            return ResponseEntity.ok(requests);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
        }
    }

    @Operation(
            summary = "Get requests by session",
            description = "Retrieve all song requests for a specific session",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Session requests retrieved successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required")
    })
    @GetMapping("/session/{sessionId}")
    public ResponseEntity<List<PlaySongResponse>> getRequestsBySession(
            @Parameter(description = "Session ID", required = true)
            @PathVariable UUID sessionId) {
        try {
            List<PlaySongResponse> requests = requestsService.getRequestsBySessionId(sessionId);
            return ResponseEntity.ok(requests);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @Operation(
            summary = "Get session queue",
            description = "Retrieve accepted song requests for a session ordered by queue position",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Session queue retrieved successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required")
    })
    @GetMapping("/session/{sessionId}/queue")
    public ResponseEntity<List<PlaySongResponse>> getSessionQueue(
            @Parameter(description = "Session ID", required = true)
            @PathVariable UUID sessionId) {
        try {
            List<PlaySongResponse> queue = requestsService.getSessionQueue(sessionId);
            return ResponseEntity.ok(queue);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @Operation(
            summary = "Accept a request",
            description = "Accept a song request (DJ only)",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Request accepted successfully"),
            @ApiResponse(responseCode = "404", description = "Request not found"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required"),
            @ApiResponse(responseCode = "403", description = "Forbidden - DJ role required")
    })
    @PreAuthorize("hasRole('DJ')")
    @PutMapping("/{id}/accept")
    public ResponseEntity<?> acceptRequest(
            @Parameter(description = "Request ID", required = true)
            @PathVariable UUID id) {
        try {
            PlaySongResponse response = requestsService.acceptRequest(id);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    @Operation(
            summary = "Reject a request",
            description = "Reject a song request (DJ only)",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Request rejected successfully"),
            @ApiResponse(responseCode = "404", description = "Request not found"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required"),
            @ApiResponse(responseCode = "403", description = "Forbidden - DJ role required")
    })
    @PreAuthorize("hasRole('DJ')")
    @PutMapping("/{id}/reject")
    public ResponseEntity<?> rejectRequest(
            @Parameter(description = "Request ID", required = true)
            @PathVariable UUID id) {
        try {
            PlaySongResponse response = requestsService.rejectRequest(id);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    @Operation(
            summary = "Get pending requests for a session",
            description = "Get all pending song requests for a specific session (DJ only)",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Pending requests retrieved successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required")
    })
    @GetMapping("/session/{sessionId}/pending")
    public ResponseEntity<?> getPendingRequestsForSession(
            @Parameter(description = "Session ID", required = true)
            @PathVariable UUID sessionId) {
        try {
            List<PlaySongResponse> requests = requestsService.getPendingRequestsBySessionId(sessionId);
            return ResponseEntity.ok(requests);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to get pending requests: " + e.getMessage());
        }
    }



    // ===== ENHANCED QUEUE MANAGEMENT ENDPOINTS =====

    @Operation(
            summary = "Get DJ's priority queue",
            description = "Get DJ's request queue ordered by priority (tip amount + time decay)",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Queue retrieved successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required"),
            @ApiResponse(responseCode = "403", description = "Forbidden - DJ role required")
    })
    @PreAuthorize("hasRole('DJ')")
    @GetMapping("/queue/{djId}/priority")
    public ResponseEntity<List<PlaySongResponse>> getPriorityQueue(
            @Parameter(description = "DJ ID", required = true)
            @PathVariable UUID djId) {
        try {
            List<PlaySongResponse> queue = requestsService.getDJRequestQueueWithPriority(djId);
            return ResponseEntity.ok(queue);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @Operation(
            summary = "Reorder queue manually",
            description = "Manually reorder the request queue by providing new order of request IDs",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Queue reordered successfully"),
            @ApiResponse(responseCode = "400", description = "Invalid request data"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required"),
            @ApiResponse(responseCode = "403", description = "Forbidden - DJ role required")
    })
    @PreAuthorize("hasRole('DJ')")
    @PutMapping("/queue/{djId}/reorder")
    public ResponseEntity<?> reorderQueue(
            @Parameter(description = "DJ ID", required = true)
            @PathVariable UUID djId,
            @RequestBody Map<String, List<String>> requestBody) {
        try {
            List<String> requestIdStrings = requestBody.get("requestIds");
            List<UUID> requestIds = requestIdStrings.stream()
                .map(UUID::fromString)
                .collect(Collectors.toList());

            List<PlaySongResponse> reorderedQueue = requestsService.reorderQueue(djId, requestIds);
            return ResponseEntity.ok(reorderedQueue);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    @Operation(
            summary = "Check for duplicate song",
            description = "Check if a song is already in the DJ's pending queue",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Duplicate check completed"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required")
    })
    @GetMapping("/queue/{djId}/duplicate-check")
    public ResponseEntity<Map<String, Boolean>> checkDuplicateSong(
            @Parameter(description = "DJ ID", required = true)
            @PathVariable UUID djId,
            @Parameter(description = "Song ID to check", required = true)
            @RequestParam String songId) {
        try {
            boolean isDuplicate = requestsService.isDuplicateSong(djId, songId);
            return ResponseEntity.ok(Map.of("isDuplicate", isDuplicate));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", true));
        }
    }

    @Operation(
            summary = "Get queue statistics",
            description = "Get analytics and statistics for DJ's request queue",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Statistics retrieved successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required"),
            @ApiResponse(responseCode = "403", description = "Forbidden - DJ role required")
    })
    @PreAuthorize("hasRole('DJ')")
    @GetMapping("/queue/{djId}/statistics")
    public ResponseEntity<Map<String, Object>> getQueueStatistics(
            @Parameter(description = "DJ ID", required = true)
            @PathVariable UUID djId) {
        try {
            Map<String, Object> statistics = requestsService.getQueueStatistics(djId);
            return ResponseEntity.ok(statistics);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", e.getMessage()));
        }
    }
}
