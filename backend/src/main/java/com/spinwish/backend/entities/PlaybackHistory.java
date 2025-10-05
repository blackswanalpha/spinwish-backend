package com.spinwish.backend.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "playback_history")
@Getter
@Setter
public class PlaybackHistory {
    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "request_id")
    private String requestId;

    @Column(name = "client_id")
    private UUID clientId;

    private Boolean status;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", referencedColumnName = "id", insertable = false, updatable = false)
    private Users users;
}