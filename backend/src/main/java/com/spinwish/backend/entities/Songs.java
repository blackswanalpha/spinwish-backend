package com.spinwish.backend.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "songs", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"name", "artist_id", "album"})
})
@Getter
@Setter
public class Songs {
    @Id
    @GeneratedValue
    private UUID id;

    private String name;

    @Column(name = "artist_id")
    private UUID artistId;

    private String album;

    @Column(name = "genre")
    private String genre;

    @Column(name = "duration") // in seconds
    private Integer duration;

    @Column(name = "artwork_url")
    private String artworkUrl;

    @Column(name = "base_request_price")
    private Double baseRequestPrice;

    @Column(name = "popularity")
    private Integer popularity;

    @Column(name = "is_explicit")
    private Boolean isExplicit;

    @Column(name = "spotify_url")
    private String spotifyUrl;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @ManyToOne
    @JoinColumn(name = "artist_id", referencedColumnName = "id", insertable = false, updatable = false)
    private Artists artist;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}

