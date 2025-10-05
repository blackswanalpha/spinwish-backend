package com.spinwish.backend.repositories;

import com.spinwish.backend.entities.UserFavorites;
import com.spinwish.backend.entities.Users;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserFavoritesRepository extends JpaRepository<UserFavorites, UUID> {
    
    List<UserFavorites> findByUserAndFavoriteType(Users user, UserFavorites.FavoriteType favoriteType);
    
    List<UserFavorites> findByUser(Users user);
    
    Optional<UserFavorites> findByUserAndFavoriteTypeAndFavoriteId(
        Users user, 
        UserFavorites.FavoriteType favoriteType, 
        UUID favoriteId
    );
    
    boolean existsByUserAndFavoriteTypeAndFavoriteId(
        Users user, 
        UserFavorites.FavoriteType favoriteType, 
        UUID favoriteId
    );
    
    void deleteByUserAndFavoriteTypeAndFavoriteId(
        Users user, 
        UserFavorites.FavoriteType favoriteType, 
        UUID favoriteId
    );
    
    @Query("SELECT COUNT(f) FROM UserFavorites f WHERE f.user = :user AND f.favoriteType = :type")
    long countByUserAndFavoriteType(@Param("user") Users user, @Param("type") UserFavorites.FavoriteType type);
    
    @Query("SELECT f.favoriteId FROM UserFavorites f WHERE f.user = :user AND f.favoriteType = :type")
    List<UUID> findFavoriteIdsByUserAndType(@Param("user") Users user, @Param("type") UserFavorites.FavoriteType type);
}
