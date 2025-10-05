package com.spinwish.backend.models.responses.users;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class ProfileResponse {
    private String id;
    private String emailAddress;
    private String username;
    private String name; // Combined first and last name
    private String email; // Alias for emailAddress for frontend compatibility
    private String phoneNumber;
    private String firstName;
    private String lastName;
    private String imageUrl;
    private String profileImage; // Alias for imageUrl for frontend compatibility
    private Double credits;
    private List<String> favoriteGenres;
    private List<String> favoriteDJs; // Will be populated from relationships
    private String role;
    private LocalDateTime createdAt;

    // Additional fields for DJ profiles
    private String bio;
    private Double rating;
    private String instagramHandle;
    private Boolean isLive;
    private Integer followers;
}
