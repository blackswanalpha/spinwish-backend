package com.spinwish.backend.controllers;

import com.spinwish.backend.entities.Club;
import com.spinwish.backend.services.ClubService;
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
@RequestMapping(path = "api/v1/clubs")
@Tag(name = "Club Management", description = "APIs for managing clubs and venues")
public class ClubController {

    @Autowired
    private ClubService clubService;

    @Operation(
            summary = "Create a new club",
            description = "Create a new club or venue",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "201",
                    description = "Club created successfully",
                    content = @Content(schema = @Schema(implementation = Club.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid club data or club name already exists"
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            )
    })
    @PostMapping
    public ResponseEntity<?> createClub(
            @Parameter(description = "Club details", required = true)
            @RequestBody Club club) {
        try {
            Club createdClub = clubService.createClub(club);
            return new ResponseEntity<>(createdClub, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to create club: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Get all clubs",
            description = "Retrieve all clubs",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Clubs retrieved successfully",
                    content = @Content(schema = @Schema(implementation = Club.class))
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            )
    })
    @GetMapping
    public ResponseEntity<List<Club>> getAllClubs() {
        List<Club> clubs = clubService.getAllClubs();
        return new ResponseEntity<>(clubs, HttpStatus.OK);
    }

    @Operation(
            summary = "Get active clubs",
            description = "Retrieve all active clubs",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/active")
    public ResponseEntity<List<Club>> getActiveClubs() {
        List<Club> clubs = clubService.getActiveClubs();
        return new ResponseEntity<>(clubs, HttpStatus.OK);
    }

    @Operation(
            summary = "Get club by ID",
            description = "Retrieve a specific club by its ID",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Club found",
                    content = @Content(schema = @Schema(implementation = Club.class))
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Club not found"
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            )
    })
    @GetMapping("/{clubId}")
    public ResponseEntity<?> getClubById(
            @Parameter(description = "Club ID", required = true)
            @PathVariable UUID clubId) {
        Optional<Club> club = clubService.getClubById(clubId);
        if (club.isPresent()) {
            return new ResponseEntity<>(club.get(), HttpStatus.OK);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Club not found with id: " + clubId);
        }
    }

    @Operation(
            summary = "Search clubs by name",
            description = "Search for clubs by name (case-insensitive partial match)",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/search/name/{name}")
    public ResponseEntity<List<Club>> searchClubsByName(
            @Parameter(description = "Club name to search for", required = true)
            @PathVariable String name) {
        List<Club> clubs = clubService.searchClubsByName(name);
        return new ResponseEntity<>(clubs, HttpStatus.OK);
    }

    @Operation(
            summary = "Search clubs by location",
            description = "Search for clubs by location (case-insensitive partial match)",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/search/location/{location}")
    public ResponseEntity<List<Club>> searchClubsByLocation(
            @Parameter(description = "Location to search for", required = true)
            @PathVariable String location) {
        List<Club> clubs = clubService.searchClubsByLocation(location);
        return new ResponseEntity<>(clubs, HttpStatus.OK);
    }

    @Operation(
            summary = "Get clubs by capacity range",
            description = "Retrieve clubs within a specific capacity range",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/capacity/{minCapacity}/{maxCapacity}")
    public ResponseEntity<List<Club>> getClubsByCapacityRange(
            @Parameter(description = "Minimum capacity", required = true)
            @PathVariable Integer minCapacity,
            @Parameter(description = "Maximum capacity", required = true)
            @PathVariable Integer maxCapacity) {
        List<Club> clubs = clubService.getClubsByCapacityRange(minCapacity, maxCapacity);
        return new ResponseEntity<>(clubs, HttpStatus.OK);
    }

    @Operation(
            summary = "Get clubs in geographical area",
            description = "Retrieve clubs within a geographical bounding box",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/area")
    public ResponseEntity<List<Club>> getClubsInArea(
            @Parameter(description = "Minimum latitude", required = true)
            @RequestParam Double minLat,
            @Parameter(description = "Maximum latitude", required = true)
            @RequestParam Double maxLat,
            @Parameter(description = "Minimum longitude", required = true)
            @RequestParam Double minLng,
            @Parameter(description = "Maximum longitude", required = true)
            @RequestParam Double maxLng) {
        List<Club> clubs = clubService.getClubsInArea(minLat, maxLat, minLng, maxLng);
        return new ResponseEntity<>(clubs, HttpStatus.OK);
    }

    @Operation(
            summary = "Update club",
            description = "Update club details",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Club updated successfully",
                    content = @Content(schema = @Schema(implementation = Club.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid club data or club name conflict"
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Club not found"
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            )
    })
    @PutMapping("/{clubId}")
    public ResponseEntity<?> updateClub(
            @Parameter(description = "Club ID", required = true)
            @PathVariable UUID clubId,
            @Parameter(description = "Updated club details", required = true)
            @RequestBody Club updatedClub) {
        try {
            Club club = clubService.updateClub(clubId, updatedClub);
            return new ResponseEntity<>(club, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to update club: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Activate club",
            description = "Set club status to active",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @PutMapping("/{clubId}/activate")
    public ResponseEntity<?> activateClub(
            @Parameter(description = "Club ID", required = true)
            @PathVariable UUID clubId) {
        try {
            Club club = clubService.activateClub(clubId);
            return new ResponseEntity<>(club, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to activate club: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Deactivate club",
            description = "Set club status to inactive",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @PutMapping("/{clubId}/deactivate")
    public ResponseEntity<?> deactivateClub(
            @Parameter(description = "Club ID", required = true)
            @PathVariable UUID clubId) {
        try {
            Club club = clubService.deactivateClub(clubId);
            return new ResponseEntity<>(club, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to deactivate club: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Delete club",
            description = "Delete a club",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @DeleteMapping("/{clubId}")
    public ResponseEntity<?> deleteClub(
            @Parameter(description = "Club ID", required = true)
            @PathVariable UUID clubId) {
        try {
            clubService.deleteClub(clubId);
            return ResponseEntity.ok("Club deleted successfully");
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to delete club: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Get club statistics",
            description = "Get count of active clubs",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/stats/count")
    public ResponseEntity<Long> getActiveClubCount() {
        Long count = clubService.countActiveClubs();
        return new ResponseEntity<>(count, HttpStatus.OK);
    }
}
