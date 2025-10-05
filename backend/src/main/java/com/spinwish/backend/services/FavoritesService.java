package com.spinwish.backend.services;

import com.spinwish.backend.entities.UserFavorites;
import com.spinwish.backend.entities.Users;
import com.spinwish.backend.models.requests.favorites.AddFavoriteRequest;
import com.spinwish.backend.models.responses.favorites.FavoriteResponse;
import com.spinwish.backend.repositories.UserFavoritesRepository;
import com.spinwish.backend.repositories.UsersRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class FavoritesService {

    @Autowired
    private UserFavoritesRepository favoritesRepository;

    @Autowired
    private UsersRepository userRepository;

    private Users getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();
        Users user = userRepository.findByEmailAddress(email);
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        return user;
    }

    @Transactional
    public FavoriteResponse addFavorite(AddFavoriteRequest request) {
        Users user = getCurrentUser();
        
        // Check if already exists
        if (favoritesRepository.existsByUserAndFavoriteTypeAndFavoriteId(
                user, request.getFavoriteType(), request.getFavoriteId())) {
            throw new RuntimeException("Item is already in favorites");
        }

        UserFavorites favorite = new UserFavorites();
        favorite.setUser(user);
        favorite.setFavoriteType(request.getFavoriteType());
        favorite.setFavoriteId(request.getFavoriteId());
        favorite.setFavoriteName(request.getFavoriteName());

        UserFavorites saved = favoritesRepository.save(favorite);
        return convertToResponse(saved);
    }

    @Transactional
    public void removeFavorite(UserFavorites.FavoriteType favoriteType, UUID favoriteId) {
        Users user = getCurrentUser();
        favoritesRepository.deleteByUserAndFavoriteTypeAndFavoriteId(user, favoriteType, favoriteId);
    }

    public List<FavoriteResponse> getUserFavorites() {
        Users user = getCurrentUser();
        List<UserFavorites> favorites = favoritesRepository.findByUser(user);
        return favorites.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<FavoriteResponse> getUserFavoritesByType(UserFavorites.FavoriteType favoriteType) {
        Users user = getCurrentUser();
        List<UserFavorites> favorites = favoritesRepository.findByUserAndFavoriteType(user, favoriteType);
        return favorites.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public boolean isFavorite(UserFavorites.FavoriteType favoriteType, UUID favoriteId) {
        Users user = getCurrentUser();
        return favoritesRepository.existsByUserAndFavoriteTypeAndFavoriteId(user, favoriteType, favoriteId);
    }

    public List<UUID> getFavoriteIds(UserFavorites.FavoriteType favoriteType) {
        Users user = getCurrentUser();
        return favoritesRepository.findFavoriteIdsByUserAndType(user, favoriteType);
    }

    private FavoriteResponse convertToResponse(UserFavorites favorite) {
        FavoriteResponse response = new FavoriteResponse();
        response.setId(favorite.getId());
        response.setFavoriteType(favorite.getFavoriteType());
        response.setFavoriteId(favorite.getFavoriteId());
        response.setFavoriteName(favorite.getFavoriteName());
        response.setCreatedAt(favorite.getCreatedAt());
        return response;
    }
}
