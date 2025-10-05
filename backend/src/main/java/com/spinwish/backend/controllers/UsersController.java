package com.spinwish.backend.controllers;

import com.spinwish.backend.exceptions.UnauthorizedException;
import com.spinwish.backend.exceptions.UserNotExistingException;
import com.spinwish.backend.models.requests.users.DJRegisterRequest;
import com.spinwish.backend.models.requests.users.LoginRequest;
import com.spinwish.backend.models.requests.users.RegisterRequest;
import com.spinwish.backend.models.requests.users.SendVerificationRequest;
import com.spinwish.backend.models.requests.users.VerificationRequest;
import com.spinwish.backend.models.responses.songs.SongResponse;
import com.spinwish.backend.models.responses.users.DJRegisterResponse;
import com.spinwish.backend.models.responses.users.LoginResponse;
import com.spinwish.backend.models.responses.users.ProfileResponse;
import com.spinwish.backend.models.responses.users.RegisterResponse;
import com.spinwish.backend.models.responses.users.UserResponse;
import com.spinwish.backend.models.responses.users.SendVerificationResponse;
import com.spinwish.backend.models.responses.users.VerificationResponse;
import com.spinwish.backend.services.UserService;
import com.spinwish.backend.services.VerificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping(path = "api/v1/users")
@Tag(name = "User Management", description = "APIs for user registration, authentication, and management")
public class UsersController {
    @Autowired
    private UserService userService;

    @Autowired
    private VerificationService verificationService;

    @Operation(
            summary = "Register a new user",
            description = "Create a new user account with the provided registration details"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "201",
                    description = "User registered successfully",
                    content = @Content(schema = @Schema(implementation = RegisterResponse.class))
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Registration failed - unauthorized",
                    content = @Content(schema = @Schema(implementation = String.class))
            )
    })
    @PostMapping("/signup")
    public ResponseEntity<?> signUp(
            @Parameter(description = "User registration details", required = true)
            @RequestBody RegisterRequest registerRequest){
        try{
            RegisterResponse registerResponse = userService.createUser(registerRequest);
            return new ResponseEntity<>(registerResponse, HttpStatus.CREATED);
        } catch (UnauthorizedException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Failed to register: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Register a new DJ",
            description = "Create a new DJ account with DJ-specific information including bio, genres, and profile details"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "201",
                    description = "DJ registration successful",
                    content = @Content(schema = @Schema(implementation = DJRegisterResponse.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid registration data",
                    content = @Content(schema = @Schema(implementation = String.class))
            ),
            @ApiResponse(
                    responseCode = "409",
                    description = "User already exists",
                    content = @Content(schema = @Schema(implementation = String.class))
            )
    })
    @PostMapping("/dj-signup")
    public ResponseEntity<?> djSignUp(
            @Parameter(description = "DJ registration details with DJ-specific information", required = true)
            @RequestBody DJRegisterRequest djRegisterRequest){
        try{
            DJRegisterResponse djRegisterResponse = userService.createDJ(djRegisterRequest);
            return new ResponseEntity<>(djRegisterResponse, HttpStatus.CREATED);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to register DJ: " + e.getMessage());
        }
    }

    @Operation(
            summary = "User login",
            description = "Authenticate user and return JWT token"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Login successful",
                    content = @Content(schema = @Schema(implementation = LoginResponse.class))
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Invalid credentials",
                    content = @Content(schema = @Schema(implementation = String.class))
            )
    })
    @PostMapping("/login")
    public ResponseEntity<?> login(
            @Parameter(description = "User login credentials", required = true)
            @RequestBody LoginRequest loginRequest){
        try{
            LoginResponse loginResponse = userService.loginUser(loginRequest);
            return new ResponseEntity<>(loginResponse, HttpStatus.OK);
        } catch (UnauthorizedException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Unauthorized: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Get all users",
            description = "Retrieve a list of all registered users (requires authentication)",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Users retrieved successfully",
                    content = @Content(schema = @Schema(implementation = ProfileResponse.class))
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            )
    })
    @GetMapping
    public ResponseEntity<List<ProfileResponse>> fetchUsers() {
        List<ProfileResponse> profileResponses = userService.getAllUsers();
        return new ResponseEntity<>(profileResponses, HttpStatus.OK);
    }

    @Operation(
            summary = "Send verification code",
            description = "Send verification code via email or SMS to the user"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Verification code sent successfully",
                    content = @Content(schema = @Schema(implementation = SendVerificationResponse.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid request or user not found",
                    content = @Content(schema = @Schema(implementation = String.class))
            )
    })
    @PostMapping("/send-verification")
    public ResponseEntity<?> sendVerificationCode(
            @Parameter(description = "Verification request details", required = true)
            @RequestBody SendVerificationRequest request) {
        try {
            SendVerificationResponse response = verificationService.sendVerificationCode(request);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Failed to send verification code: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Verify user account",
            description = "Verify user account with the provided verification code"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Verification successful",
                    content = @Content(schema = @Schema(implementation = VerificationResponse.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid verification code or expired",
                    content = @Content(schema = @Schema(implementation = String.class))
            )
    })
    @PostMapping("/verify")
    public ResponseEntity<?> verifyAccount(
            @Parameter(description = "Verification code details", required = true)
            @RequestBody VerificationRequest request) {
        try {
            VerificationResponse response = verificationService.verifyCode(request);
            if (response.isSuccess()) {
                return new ResponseEntity<>(response, HttpStatus.OK);
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response.getMessage());
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Verification failed: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Get current user data",
            description = "Retrieve current authenticated user's data with favorites and preferences",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Current user data retrieved successfully",
                    content = @Content(schema = @Schema(implementation = UserResponse.class))
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            )
    })
    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser() {
        try {
            UserResponse userResponse = userService.getCurrentUserWithDetails();
            return ResponseEntity.ok(userResponse);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body("Failed to get current user: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Update current user profile",
            description = "Update current authenticated user's profile information",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Profile updated successfully",
                    content = @Content(schema = @Schema(implementation = UserResponse.class))
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            )
    })
    @PutMapping("/me")
    public ResponseEntity<?> updateCurrentUser(
            @Parameter(description = "Updated user profile data", required = true)
            @RequestBody RegisterRequest updateRequest) {
        try {
            UserResponse userResponse = userService.updateCurrentUser(updateRequest);
            return ResponseEntity.ok(userResponse);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Failed to update profile: " + e.getMessage());
        }
    }
}

