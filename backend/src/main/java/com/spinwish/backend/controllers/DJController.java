package com.spinwish.backend.controllers;

import com.spinwish.backend.entities.Users;
import com.spinwish.backend.services.DJService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping(path = "api/v1/djs")
@Tag(name = "DJ Management", description = "APIs for managing DJs and DJ-specific operations")
public class DJController {

    @Autowired
    private DJService djService;

    @Operation(
            summary = "Get all DJs",
            description = "Retrieve all registered DJs",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "DJs retrieved successfully",
                    content = @Content(schema = @Schema(implementation = Users.class))
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            )
    })
    @GetMapping
    public ResponseEntity<List<Users>> getAllDJs() {
        List<Users> djs = djService.getAllDJs();
        return new ResponseEntity<>(djs, HttpStatus.OK);
    }

    @Operation(
            summary = "Get DJ by ID",
            description = "Retrieve a specific DJ by their ID",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "DJ found",
                    content = @Content(schema = @Schema(implementation = Users.class))
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "DJ not found"
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            )
    })
    @GetMapping("/{djId}")
    public ResponseEntity<?> getDJById(
            @Parameter(description = "DJ ID", required = true)
            @PathVariable UUID djId) {
        Optional<Users> dj = djService.getDJById(djId);
        if (dj.isPresent()) {
            return new ResponseEntity<>(dj.get(), HttpStatus.OK);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("DJ not found with id: " + djId);
        }
    }

    @Operation(
            summary = "Get live DJs",
            description = "Retrieve all DJs that are currently live",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/live")
    public ResponseEntity<List<Users>> getLiveDJs() {
        List<Users> liveDJs = djService.getLiveDJs();
        return new ResponseEntity<>(liveDJs, HttpStatus.OK);
    }

    @Operation(
            summary = "Get DJs by genre",
            description = "Retrieve DJs that play a specific genre",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/genre/{genre}")
    public ResponseEntity<List<Users>> getDJsByGenre(
            @Parameter(description = "Genre name", required = true)
            @PathVariable String genre) {
        List<Users> djs = djService.getDJsByGenre(genre);
        return new ResponseEntity<>(djs, HttpStatus.OK);
    }

    @Operation(
            summary = "Get top rated DJs",
            description = "Retrieve top rated DJs with a specified limit",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/top-rated")
    public ResponseEntity<List<Users>> getTopRatedDJs(
            @Parameter(description = "Maximum number of DJs to return", required = false)
            @RequestParam(defaultValue = "10") int limit) {
        List<Users> djs = djService.getTopRatedDJs(limit);
        return new ResponseEntity<>(djs, HttpStatus.OK);
    }

    @Operation(
            summary = "Get most followed DJs",
            description = "Retrieve DJs with the most followers",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/most-followed")
    public ResponseEntity<List<Users>> getMostFollowedDJs(
            @Parameter(description = "Maximum number of DJs to return", required = false)
            @RequestParam(defaultValue = "10") int limit) {
        List<Users> djs = djService.getMostFollowedDJs(limit);
        return new ResponseEntity<>(djs, HttpStatus.OK);
    }

    @Operation(
            summary = "Search DJs by name",
            description = "Search for DJs by username (case-insensitive partial match)",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/search/{name}")
    public ResponseEntity<List<Users>> searchDJsByName(
            @Parameter(description = "DJ name to search for", required = true)
            @PathVariable String name) {
        List<Users> djs = djService.searchDJsByName(name);
        return new ResponseEntity<>(djs, HttpStatus.OK);
    }

    @Operation(
            summary = "Get DJs by rating range",
            description = "Retrieve DJs within a specific rating range",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/rating/{minRating}/{maxRating}")
    public ResponseEntity<List<Users>> getDJsByRatingRange(
            @Parameter(description = "Minimum rating", required = true)
            @PathVariable double minRating,
            @Parameter(description = "Maximum rating", required = true)
            @PathVariable double maxRating) {
        List<Users> djs = djService.getDJsByRatingRange(minRating, maxRating);
        return new ResponseEntity<>(djs, HttpStatus.OK);
    }

    @Operation(
            summary = "Get DJs by follower range",
            description = "Retrieve DJs within a specific follower count range",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/followers/{minFollowers}/{maxFollowers}")
    public ResponseEntity<List<Users>> getDJsByFollowerRange(
            @Parameter(description = "Minimum followers", required = true)
            @PathVariable int minFollowers,
            @Parameter(description = "Maximum followers", required = true)
            @PathVariable int maxFollowers) {
        List<Users> djs = djService.getDJsByFollowerRange(minFollowers, maxFollowers);
        return new ResponseEntity<>(djs, HttpStatus.OK);
    }

    @Operation(
            summary = "Update DJ profile",
            description = "Update DJ-specific profile information",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "DJ profile updated successfully",
                    content = @Content(schema = @Schema(implementation = Users.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid DJ data"
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "DJ not found"
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            )
    })
    @PutMapping("/{djId}/profile")
    public ResponseEntity<?> updateDJProfile(
            @Parameter(description = "DJ ID", required = true)
            @PathVariable UUID djId,
            @Parameter(description = "Updated DJ profile data", required = true)
            @RequestBody Users updatedDJ) {
        try {
            Users dj = djService.updateDJProfile(djId, updatedDJ);
            return new ResponseEntity<>(dj, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to update DJ profile: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Set DJ live status",
            description = "Update whether a DJ is currently live",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @PutMapping("/{djId}/live/{isLive}")
    public ResponseEntity<?> setDJLiveStatus(
            @Parameter(description = "DJ ID", required = true)
            @PathVariable UUID djId,
            @Parameter(description = "Live status", required = true)
            @PathVariable boolean isLive) {
        try {
            Users dj = djService.setDJLiveStatus(djId, isLive);
            return new ResponseEntity<>(dj, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to update DJ live status: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Update DJ rating",
            description = "Update a DJ's rating (0.0 to 5.0)",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @PutMapping("/{djId}/rating/{rating}")
    public ResponseEntity<?> updateDJRating(
            @Parameter(description = "DJ ID", required = true)
            @PathVariable UUID djId,
            @Parameter(description = "New rating (0.0 to 5.0)", required = true)
            @PathVariable double rating) {
        try {
            Users dj = djService.updateDJRating(djId, rating);
            return new ResponseEntity<>(dj, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to update DJ rating: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Follow DJ",
            description = "Add a follower to a DJ",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @PostMapping("/{djId}/follow")
    public ResponseEntity<?> followDJ(
            @Parameter(description = "DJ ID", required = true)
            @PathVariable UUID djId) {
        try {
            Users dj = djService.addFollower(djId);
            return new ResponseEntity<>(dj, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to follow DJ: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Unfollow DJ",
            description = "Remove a follower from a DJ",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @PostMapping("/{djId}/unfollow")
    public ResponseEntity<?> unfollowDJ(
            @Parameter(description = "DJ ID", required = true)
            @PathVariable UUID djId) {
        try {
            Users dj = djService.removeFollower(djId);
            return new ResponseEntity<>(dj, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to unfollow DJ: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Get DJ statistics",
            description = "Get statistics for a specific DJ",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/{djId}/stats")
    public ResponseEntity<?> getDJStats(
            @Parameter(description = "DJ ID", required = true)
            @PathVariable UUID djId) {
        try {
            DJService.DJStats stats = djService.getDJStats(djId);
            return new ResponseEntity<>(stats, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to get DJ stats: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Get current DJ profile",
            description = "Get the DJ profile of the currently authenticated user",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Current DJ profile retrieved successfully",
                    content = @Content(schema = @Schema(implementation = Users.class))
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Current user is not a DJ"
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            )
    })
    @GetMapping("/me")
    public ResponseEntity<?> getCurrentDJProfile() {
        try {
            Users currentDJ = djService.getCurrentDJProfile();
            return new ResponseEntity<>(currentDJ, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to get current DJ profile: " + e.getMessage());
        }
    }
}
