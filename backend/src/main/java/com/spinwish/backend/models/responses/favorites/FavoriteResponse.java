package com.spinwish.backend.models.responses.favorites;

import com.spinwish.backend.entities.UserFavorites;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class FavoriteResponse {
    private UUID id;
    private UserFavorites.FavoriteType favoriteType;
    private UUID favoriteId;
    private String favoriteName;
    private LocalDateTime createdAt;
}
