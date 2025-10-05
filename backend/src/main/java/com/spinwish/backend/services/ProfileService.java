package com.spinwish.backend.services;

import com.spinwish.backend.entities.Profile;
import com.spinwish.backend.entities.Users;
import com.spinwish.backend.exceptions.UserNotExistingException;
import com.spinwish.backend.models.requests.users.ProfileRequest;
import com.spinwish.backend.models.responses.users.ProfileResponse;
import com.spinwish.backend.repositories.ProfileRepository;
import com.spinwish.backend.repositories.UsersRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import org.springframework.web.multipart.MultipartFile;

@Service
public class ProfileService {

    @Autowired
    private ProfileRepository profileRepository;

    @Autowired
    private UsersRepository userRepository;

    private final Path rootLocation = Paths.get("uploads/profile-images");

    @PostConstruct
    public void init() {
        try {
            Files.createDirectories(rootLocation);
        } catch (IOException e) {
            throw new RuntimeException("Could not initialize folder for upload!");
        }
    }

    @Transactional
    public ProfileResponse createOrUpdateProfile(ProfileRequest profileRequest) throws IOException {
        String emailAddress = SecurityContextHolder.getContext().getAuthentication().getName();
        Users user = userRepository.findByEmailAddress(emailAddress);
        if (user == null) {
            throw new UserNotExistingException("User not found");
        }

        Profile profile = profileRepository.findByUsersId(user.getId());
        if (profile == null) {
            profile = new Profile();
            profile.setUsers(user);
            profile.setCreatedAt(LocalDateTime.now());
        }

        profile.setUpdatedAt(LocalDateTime.now());
        if (profileRequest.getFirstName() != null) profile.setFirstName(profileRequest.getFirstName());
        if (profileRequest.getLastName() != null) profile.setLastName(profileRequest.getLastName());
        if (profileRequest.getPhoneNumber() != null) profile.setPhoneNumber(profileRequest.getPhoneNumber());


        if (profileRequest.getImage() != null && !profileRequest.getImage().isEmpty()) {
            // Validate image file
            validateImageFile(profileRequest.getImage());

            String originalFilename = profileRequest.getImage().getOriginalFilename();
            String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            String newFileName = UUID.randomUUID() + fileExtension;

            Path destinationFile = this.rootLocation.resolve(Paths.get(newFileName)).normalize().toAbsolutePath();

            // Ensure the path is within the upload directory (security check)
            if (!destinationFile.getParent().equals(this.rootLocation.toAbsolutePath())) {
                throw new RuntimeException("Cannot store file outside current directory.");
            }

            Files.copy(profileRequest.getImage().getInputStream(), destinationFile, StandardCopyOption.REPLACE_EXISTING);

            profile.setImageUrl("/uploads/profile-images/" + newFileName);
        }

        profileRepository.save(profile);
        return convertProfileResponse(user, profile);
    }

    public ProfileResponse getProfile(){
        String emailAddress = SecurityContextHolder.getContext().getAuthentication().getName();
        Users user = userRepository.findByEmailAddress(emailAddress);

        if (user == null) {
            throw new UserNotExistingException("User not found");
        }

        Profile profile = profileRepository.findByUsersId(user.getId());
        if (profile == null) {
            throw new RuntimeException("Profile not found for user");
        }
        return convertProfileResponse(user, profile);

    }

    private ProfileResponse convertProfileResponse(Users user, Profile profile) {
        ProfileResponse response = new ProfileResponse();

        // Basic user information
        response.setId(user.getId().toString());
        response.setEmailAddress(user.getEmailAddress());
        response.setEmail(user.getEmailAddress()); // Alias for frontend compatibility
        response.setUsername(user.getActualUsername());

        // Profile information
        response.setFirstName(profile.getFirstName());
        response.setLastName(profile.getLastName());
        response.setPhoneNumber(profile.getPhoneNumber());

        // Combine first and last name for frontend compatibility
        String fullName = "";
        if (profile.getFirstName() != null && profile.getLastName() != null) {
            fullName = profile.getFirstName() + " " + profile.getLastName();
        } else if (profile.getFirstName() != null) {
            fullName = profile.getFirstName();
        } else if (profile.getLastName() != null) {
            fullName = profile.getLastName();
        } else {
            fullName = user.getActualUsername(); // Fallback to username
        }
        response.setName(fullName);

        // Image handling - prefer profile image over user profile image
        String imageUrl = profile.getImageUrl() != null ? profile.getImageUrl() : user.getProfileImage();
        response.setImageUrl(imageUrl);
        response.setProfileImage(imageUrl); // Alias for frontend compatibility

        // User-specific fields
        response.setCredits(user.getCredits() != null ? user.getCredits() : 0.0);
        response.setFavoriteGenres(user.getGenres() != null ? user.getGenres() : new ArrayList<>());
        response.setFavoriteDJs(new ArrayList<>()); // TODO: Implement favorite DJs relationship
        response.setRole(user.getRole() != null ? user.getRole().getRoleName() : null);
        response.setCreatedAt(user.getCreatedAt());

        // DJ-specific fields (if applicable)
        response.setBio(user.getBio());
        response.setRating(user.getRating());
        response.setInstagramHandle(user.getInstagramHandle());
        response.setIsLive(user.getIsLive());
        response.setFollowers(user.getFollowers());

        return response;
    }

    private void validateImageFile(MultipartFile file) {
        // Log file details for debugging
        System.out.println("=== Image File Validation ===");
        System.out.println("Original filename: " + file.getOriginalFilename());
        System.out.println("Content type: " + file.getContentType());
        System.out.println("File size: " + file.getSize() + " bytes");

        // Check file size (max 5MB)
        long maxSize = 5 * 1024 * 1024; // 5MB in bytes
        if (file.getSize() > maxSize) {
            throw new RuntimeException("File size exceeds maximum allowed size of 5MB");
        }

        // Check file type - be more flexible with MIME types
        String contentType = file.getContentType();
        if (contentType != null) {
            contentType = contentType.toLowerCase();
        }

        boolean isValidType = contentType != null && (
            contentType.equals("image/jpeg") ||
            contentType.equals("image/jpg") ||  // Some systems use this
            contentType.equals("image/pjpeg") || // Progressive JPEG
            contentType.equals("image/png") ||
            contentType.equals("image/gif") ||
            contentType.equals("image/webp")
        );

        // Check filename and extension as fallback
        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null || originalFilename.trim().isEmpty()) {
            throw new RuntimeException("Invalid filename");
        }

        // Check file extension
        if (!originalFilename.contains(".")) {
            throw new RuntimeException("File must have an extension");
        }

        String fileExtension = originalFilename.substring(originalFilename.lastIndexOf(".")).toLowerCase();
        List<String> allowedExtensions = Arrays.asList(".jpg", ".jpeg", ".png", ".gif", ".webp");

        boolean hasValidExtension = allowedExtensions.contains(fileExtension);

        // If MIME type validation failed, try extension validation as fallback
        if (!isValidType && !hasValidExtension) {
            throw new RuntimeException("Invalid file type. Only JPEG, PNG, GIF, and WebP images are allowed. Received MIME type: " + contentType + ", Extension: " + fileExtension);
        }

        if (!hasValidExtension) {
            throw new RuntimeException("Invalid file extension. Only .jpg, .jpeg, .png, .gif, and .webp are allowed. Received: " + fileExtension);
        }
    }


}

