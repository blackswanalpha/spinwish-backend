package com.spinwish.backend.models.responses.users;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "DJ registration response with DJ profile information")
public class DJRegisterResponse {
    
    @Schema(description = "User's email address", example = "john.smith@example.com")
    private String emailAddress;
    
    @Schema(description = "User's full name", example = "John Smith")
    private String username;
    
    @Schema(description = "DJ's stage name", example = "DJ Nexus")
    private String djName;
    
    @Schema(description = "DJ's biography", example = "Electronic music producer with 8+ years of experience...")
    private String bio;
    
    @Schema(description = "List of music genres", example = "[\"House\", \"Techno\", \"Electronic\"]")
    private List<String> genres;
    
    @Schema(description = "DJ's Instagram handle", example = "@dj_nexus_official")
    private String instagramHandle;
    
    @Schema(description = "DJ's profile image URL", example = "https://example.com/profile.jpg")
    private String profileImage;
    
    @Schema(description = "Initial rating (0.0 for new DJs)", example = "0.0")
    private Double rating;
    
    @Schema(description = "Initial followers count", example = "0")
    private Integer followers;
    
    @Schema(description = "Account verification status", example = "false")
    private Boolean emailVerified;
    
    @Schema(description = "Success message", example = "DJ registration successful. Please check your email for verification.")
    private String message;
}
