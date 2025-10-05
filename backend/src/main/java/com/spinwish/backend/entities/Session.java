package com.spinwish.backend.entities;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonValue;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "sessions")
@Getter
@Setter
public class Session {
    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "dj_id", nullable = false)
    private UUID djId;

    @Column(name = "club_id")
    private UUID clubId;

    @Enumerated(EnumType.STRING)
    @Column(name = "session_type", nullable = false)
    private SessionType type;

    @Enumerated(EnumType.STRING)
    @Column(name = "session_status", nullable = false)
    private SessionStatus status;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "start_time", nullable = false)
    private LocalDateTime startTime;

    @Column(name = "end_time")
    private LocalDateTime endTime;

    @Column(name = "listener_count")
    private Integer listenerCount;

    @ElementCollection
    @CollectionTable(name = "session_request_queue", joinColumns = @JoinColumn(name = "session_id"))
    @Column(name = "request_id")
    private List<String> requestQueue;

    @Column(name = "total_earnings")
    private Double totalEarnings;

    @Column(name = "total_tips")
    private Double totalTips;

    @Column(name = "total_requests")
    private Integer totalRequests;

    @Column(name = "accepted_requests")
    private Integer acceptedRequests;

    @Column(name = "rejected_requests")
    private Integer rejectedRequests;

    @Column(name = "current_song_id")
    private String currentSongId;

    @Column(name = "is_accepting_requests")
    private Boolean isAcceptingRequests;

    @Column(name = "min_tip_amount")
    private Double minTipAmount;

    @ElementCollection
    @CollectionTable(name = "session_genres", joinColumns = @JoinColumn(name = "session_id"))
    @Column(name = "genre")
    private List<String> genres;

    @Column(name = "shareable_link")
    private String shareableLink;

    @Column(name = "image_url")
    private String imageUrl;

    @Column(name = "thumbnail_url")
    private String thumbnailUrl;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // Relationships (excluded from JSON serialization to avoid lazy loading issues)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dj_id", referencedColumnName = "id", insertable = false, updatable = false)
    @JsonIgnore
    private Users dj;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "club_id", referencedColumnName = "id", insertable = false, updatable = false)
    @JsonIgnore
    private Club club;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Enums
    public enum SessionType {
        CLUB, ONLINE;

        @JsonCreator
        public static SessionType fromString(String value) {
            if (value == null) {
                return ONLINE; // Default value
            }

            switch (value.toUpperCase()) {
                case "CLUB":
                    return CLUB;
                case "ONLINE":
                    return ONLINE;
                default:
                    return ONLINE; // Default fallback
            }
        }

        @JsonValue
        public String toValue() {
            return this.name();
        }
    }

    public enum SessionStatus {
        PREPARING, LIVE, PAUSED, ENDED;

        @JsonCreator
        public static SessionStatus fromString(String value) {
            if (value == null) {
                return PREPARING; // Default value
            }

            switch (value.toUpperCase()) {
                case "PREPARING":
                    return PREPARING;
                case "LIVE":
                    return LIVE;
                case "PAUSED":
                    return PAUSED;
                case "ENDED":
                    return ENDED;
                default:
                    return PREPARING; // Default fallback
            }
        }

        @JsonValue
        public String toValue() {
            return this.name();
        }
    }
}
