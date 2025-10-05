package com.spinwish.backend.models.requests.favorites;

import com.spinwish.backend.entities.UserFavorites;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.UUID;

@Data
public class AddFavoriteRequest {
    @NotNull(message = "Favorite type is required")
    private UserFavorites.FavoriteType favoriteType;
    
    @NotNull(message = "Favorite ID is required")
    private UUID favoriteId;
    
    private String favoriteName;
}
