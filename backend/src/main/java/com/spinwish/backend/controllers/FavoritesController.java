package com.spinwish.backend.controllers;

import com.spinwish.backend.entities.UserFavorites;
import com.spinwish.backend.models.requests.favorites.AddFavoriteRequest;
import com.spinwish.backend.models.responses.favorites.FavoriteResponse;
import com.spinwish.backend.services.FavoritesService;
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
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/favorites")
@Tag(name = "Favorites Management", description = "APIs for managing user favorites (DJs, songs, genres, artists)")
public class FavoritesController {

    @Autowired
    private FavoritesService favoritesService;

    @Operation(
            summary = "Add item to favorites",
            description = "Add a DJ, song, genre, or artist to user's favorites",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Item added to favorites successfully"),
            @ApiResponse(responseCode = "400", description = "Item already in favorites or invalid request"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required")
    })
    @PostMapping
    public ResponseEntity<?> addFavorite(@Valid @RequestBody AddFavoriteRequest request) {
        try {
            FavoriteResponse response = favoritesService.addFavorite(request);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to add favorite: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Remove item from favorites",
            description = "Remove a DJ, song, genre, or artist from user's favorites",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "204", description = "Item removed from favorites successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required")
    })
    @DeleteMapping("/{favoriteType}/{favoriteId}")
    public ResponseEntity<?> removeFavorite(
            @Parameter(description = "Type of favorite (DJ, SONG, GENRE, ARTIST)", required = true)
            @PathVariable UserFavorites.FavoriteType favoriteType,
            @Parameter(description = "ID of the favorite item", required = true)
            @PathVariable UUID favoriteId) {
        try {
            favoritesService.removeFavorite(favoriteType, favoriteId);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to remove favorite: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Get all user favorites",
            description = "Retrieve all favorites for the current user",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Favorites retrieved successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required")
    })
    @GetMapping
    public ResponseEntity<List<FavoriteResponse>> getAllFavorites() {
        List<FavoriteResponse> favorites = favoritesService.getUserFavorites();
        return ResponseEntity.ok(favorites);
    }

    @Operation(
            summary = "Get favorites by type",
            description = "Retrieve user favorites filtered by type (DJ, SONG, GENRE, ARTIST)",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Favorites retrieved successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required")
    })
    @GetMapping("/{favoriteType}")
    public ResponseEntity<List<FavoriteResponse>> getFavoritesByType(
            @Parameter(description = "Type of favorite (DJ, SONG, GENRE, ARTIST)", required = true)
            @PathVariable UserFavorites.FavoriteType favoriteType) {
        List<FavoriteResponse> favorites = favoritesService.getUserFavoritesByType(favoriteType);
        return ResponseEntity.ok(favorites);
    }

    @Operation(
            summary = "Check if item is favorite",
            description = "Check if a specific item is in user's favorites",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Check completed successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required")
    })
    @GetMapping("/check/{favoriteType}/{favoriteId}")
    public ResponseEntity<Boolean> isFavorite(
            @Parameter(description = "Type of favorite (DJ, SONG, GENRE, ARTIST)", required = true)
            @PathVariable UserFavorites.FavoriteType favoriteType,
            @Parameter(description = "ID of the item to check", required = true)
            @PathVariable UUID favoriteId) {
        boolean isFavorite = favoritesService.isFavorite(favoriteType, favoriteId);
        return ResponseEntity.ok(isFavorite);
    }

    @Operation(
            summary = "Get favorite IDs by type",
            description = "Get list of favorite IDs for a specific type",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Favorite IDs retrieved successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token required")
    })
    @GetMapping("/ids/{favoriteType}")
    public ResponseEntity<List<UUID>> getFavoriteIds(
            @Parameter(description = "Type of favorite (DJ, SONG, GENRE, ARTIST)", required = true)
            @PathVariable UserFavorites.FavoriteType favoriteType) {
        List<UUID> favoriteIds = favoritesService.getFavoriteIds(favoriteType);
        return ResponseEntity.ok(favoriteIds);
    }
}
