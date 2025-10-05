package com.spinwish.backend.models.responses.users;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
public class UserResponse {
    private UUID id;
    private String emailAddress;
    private String username;
    private String role;
    private LocalDateTime createdAt;
    private Boolean emailVerified;

    // DJ-specific fields
    private Boolean isActive;
    private Double credits;
    private Integer followers;
    private Double rating;
    private List<String> genres;
    private String bio;
    private String profileImage;
    private String instagramHandle;
    private Boolean isLive;
}
