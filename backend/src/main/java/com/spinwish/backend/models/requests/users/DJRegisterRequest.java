package com.spinwish.backend.models.requests.users;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "DJ registration request with DJ-specific information")
public class DJRegisterRequest {
    
    @NotBlank(message = "Username is required")
    @Size(min = 2, max = 50, message = "Username must be between 2 and 50 characters")
    @Schema(description = "User's full name", example = "John Smith")
    private String username;
    
    @NotBlank(message = "Email address is required")
    @Email(message = "Please provide a valid email address")
    @Schema(description = "User's email address", example = "john.smith@example.com")
    private String emailAddress;
    
    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters long")
    @Schema(description = "User's password", example = "securePassword123")
    private String password;
    
    @NotBlank(message = "Password confirmation is required")
    @Schema(description = "Password confirmation", example = "securePassword123")
    private String confirmPassword;
    
    @Schema(description = "User's phone number", example = "+254712345678")
    private String phoneNumber;
    
    // DJ-specific fields
    @NotBlank(message = "DJ name is required")
    @Size(min = 2, max = 50, message = "DJ name must be between 2 and 50 characters")
    @Schema(description = "DJ's stage name", example = "DJ Nexus")
    private String djName;
    
    @Size(max = 1000, message = "Bio must not exceed 1000 characters")
    @Schema(description = "DJ's biography and description", example = "Electronic music producer with 8+ years of experience...")
    private String bio;
    
    @NotEmpty(message = "At least one genre must be selected")
    @Schema(description = "List of music genres the DJ specializes in", example = "[\"House\", \"Techno\", \"Electronic\"]")
    private List<String> genres;
    
    @Schema(description = "DJ's Instagram handle", example = "@dj_nexus_official")
    private String instagramHandle;
    
    @Schema(description = "DJ's profile image URL", example = "https://example.com/profile.jpg")
    private String profileImage;
}
