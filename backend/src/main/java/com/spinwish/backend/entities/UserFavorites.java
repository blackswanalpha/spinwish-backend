package com.spinwish.backend.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "user_favorites")
@Getter
@Setter
public class UserFavorites {
    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private Users user;

    @Column(name = "favorite_type", nullable = false)
    @Enumerated(EnumType.STRING)
    private FavoriteType favoriteType;

    @Column(name = "favorite_id", nullable = false)
    private UUID favoriteId;

    @Column(name = "favorite_name")
    private String favoriteName;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    public enum FavoriteType {
        DJ, SONG, GENRE, ARTIST
    }
}
