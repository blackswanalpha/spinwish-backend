package com.spinwish.backend.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@Entity
public class Artists {
    @Id
    @GeneratedValue
    private UUID id;
    @Column(name = "artist_name")
    private String name;

    @Column(name = "artist_bio")
    private String bio;

    @Column(name = "artist_profile")
    private String imageUrl;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
