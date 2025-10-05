package com.spinwish.backend.entities;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
@Entity
@Table(name = "requests")
public class Request {
    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "client_id")
    private UUID clientId;

    @Column(name = "dj_id")
    private UUID djId;

    @Column(name = "session_id")
    private UUID sessionId;

    @Column(name = "songs_id")
    private String songId;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private RequestStatus status;

    @Column(name = "amount")
    private Double amount;

    @Column(name = "message", columnDefinition = "TEXT")
    private String message;

    @Column(name = "queue_position")
    private Integer queuePosition;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dj_id", referencedColumnName = "id", insertable = false, updatable = false)
    private Users dj;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id", referencedColumnName = "id", insertable = false, updatable = false)
    private Users client;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", referencedColumnName = "id", insertable = false, updatable = false)
    private Session session;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Enum for request status
    public enum RequestStatus {
        PENDING, ACCEPTED, REJECTED, PLAYED;

        @JsonCreator
        public static RequestStatus fromString(String value) {
            if (value == null) {
                return PENDING; // Default value
            }

            switch (value.toUpperCase()) {
                case "PENDING":
                    return PENDING;
                case "ACCEPTED":
                    return ACCEPTED;
                case "REJECTED":
                    return REJECTED;
                case "PLAYED":
                    return PLAYED;
                default:
                    return PENDING; // Default fallback
            }
        }

        @JsonValue
        public String toValue() {
            return this.name();
        }
    }
}
