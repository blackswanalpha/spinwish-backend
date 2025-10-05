package com.spinwish.backend.services;

import com.spinwish.backend.entities.Profile;
import com.spinwish.backend.entities.Roles;
import com.spinwish.backend.entities.Users;
import com.spinwish.backend.exceptions.UserAlreadyExistsException;
import com.spinwish.backend.exceptions.UserNotExistingException;
import com.spinwish.backend.models.requests.users.DJRegisterRequest;
import com.spinwish.backend.models.requests.users.LoginRequest;
import com.spinwish.backend.models.requests.users.RegisterRequest;
import com.spinwish.backend.models.responses.users.*;
import com.spinwish.backend.repositories.ProfileRepository;
import com.spinwish.backend.repositories.RoleRepository;
import com.spinwish.backend.repositories.UsersRepository;
import com.spinwish.backend.security.JwtTokenUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@Slf4j
public class UserService implements UserDetailsService {
    @Autowired
    private UsersRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    @Lazy
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtTokenUtil jwtTokenUtil;

    @Autowired
    private ProfileRepository profileRepository;

    @Transactional
    public RegisterResponse createUser(RegisterRequest registerRequest){
        // Validate password confirmation
        if (!registerRequest.getPassword().equals(registerRequest.getConfirmPassword())) {
            throw new RuntimeException("Passwords do not match");
        }

        // Validate phone number format (basic validation)
        if (registerRequest.getPhoneNumber() != null && !registerRequest.getPhoneNumber().isEmpty()) {
            if (!isValidPhoneNumber(registerRequest.getPhoneNumber())) {
                throw new RuntimeException("Invalid phone number format");
            }
        }

        Roles role = roleRepository.findByRoleName(registerRequest.getRoleName());
        Users existingUser = userRepository.findByEmailAddress(registerRequest.getEmailAddress());

        if (role == null) {
            throw new RuntimeException("Role not found: " + registerRequest.getRoleName());
        }

        if (existingUser != null){
            throw new UserAlreadyExistsException("User already exists");
        }

        // Check if phone number is already registered (if provided)
        if (registerRequest.getPhoneNumber() != null && !registerRequest.getPhoneNumber().isEmpty()) {
            Users existingUserByPhone = userRepository.findByPhoneNumber(registerRequest.getPhoneNumber());
            if (existingUserByPhone != null) {
                throw new UserAlreadyExistsException("Phone number already registered");
            }
        }

        Users newUser = new Users();
        newUser.setActualUsername(registerRequest.getUsername());
        newUser.setEmailAddress(registerRequest.getEmailAddress());
        newUser.setPassword(passwordEncoder.encode(registerRequest.getPassword()));
        newUser.setPhoneNumber(registerRequest.getPhoneNumber());
        newUser.setCreatedAt(LocalDateTime.now());
        newUser.setUpdatedAt(LocalDateTime.now());
        newUser.setRole(role);
        // User starts as inactive until verified
        newUser.setIsActive(false);

        Users savedUser = userRepository.save(newUser); // Hibernate generates ID here

        Profile profile = new Profile();
        profile.setUsers(savedUser);
        profileRepository.save(profile);

        return convertRegisterResponse(savedUser);
    }

    @Transactional
    public DJRegisterResponse createDJ(DJRegisterRequest djRegisterRequest) {
        // Validate password confirmation
        if (!djRegisterRequest.getPassword().equals(djRegisterRequest.getConfirmPassword())) {
            throw new RuntimeException("Passwords do not match");
        }

        // Validate phone number format (basic validation)
        if (djRegisterRequest.getPhoneNumber() != null && !djRegisterRequest.getPhoneNumber().isEmpty()) {
            if (!isValidPhoneNumber(djRegisterRequest.getPhoneNumber())) {
                throw new RuntimeException("Invalid phone number format");
            }
        }

        // Get DJ role
        Roles djRole = roleRepository.findByRoleName("DJ");
        if (djRole == null) {
            throw new RuntimeException("DJ role not found");
        }

        // Check if user already exists
        Users existingUser = userRepository.findByEmailAddress(djRegisterRequest.getEmailAddress());
        if (existingUser != null) {
            throw new UserAlreadyExistsException("User already exists");
        }

        // Check if phone number is already registered (if provided)
        if (djRegisterRequest.getPhoneNumber() != null &&
            !djRegisterRequest.getPhoneNumber().trim().isEmpty()) {
            Users existingUserByPhone = userRepository.findByPhoneNumber(djRegisterRequest.getPhoneNumber());
            if (existingUserByPhone != null) {
                throw new UserAlreadyExistsException("Phone number already registered");
            }
        }

        // Create new DJ user
        Users newDJ = new Users();
        newDJ.setActualUsername(djRegisterRequest.getUsername());
        newDJ.setEmailAddress(djRegisterRequest.getEmailAddress());
        newDJ.setPassword(passwordEncoder.encode(djRegisterRequest.getPassword()));
        newDJ.setPhoneNumber(djRegisterRequest.getPhoneNumber());
        newDJ.setRole(djRole);

        // Set DJ-specific fields
        newDJ.setBio(djRegisterRequest.getBio());
        newDJ.setGenres(djRegisterRequest.getGenres());
        newDJ.setInstagramHandle(djRegisterRequest.getInstagramHandle());
        newDJ.setProfileImage(djRegisterRequest.getProfileImage());

        // Initialize DJ metrics
        newDJ.setRating(0.0);
        newDJ.setFollowers(0);
        newDJ.setIsLive(false);
        newDJ.setCredits(0.0);

        // User starts as inactive until verified
        newDJ.setIsActive(false);
        newDJ.setEmailVerified(false);
        newDJ.setPhoneVerified(false);

        newDJ.setCreatedAt(LocalDateTime.now());
        newDJ.setUpdatedAt(LocalDateTime.now());

        Users savedDJ = userRepository.save(newDJ);

        // Create profile for DJ
        Profile profile = new Profile();
        profile.setUsers(savedDJ);
        profileRepository.save(profile);

        return convertDJRegisterResponse(savedDJ);
    }

    @Transactional
    public LoginResponse loginUser(LoginRequest loginRequest){
        Users user = userRepository.findByEmailAddress(loginRequest.getEmailAddress());

        if (user == null){
            throw new UsernameNotFoundException("Invalid email or password");
        }

        // Check if user account is active before authentication
        if (user.getIsActive() == null || !user.getIsActive()) {
            throw new UsernameNotFoundException("Account is not verified. Please check your email for verification instructions.");
        }

        try{
            authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(loginRequest.getEmailAddress(), loginRequest.getPassword()));
        } catch (AuthenticationException e) {
            throw new UsernameNotFoundException("Invalid email or password");
        }

        final String token = jwtTokenUtil.generateToken(user);
        final String refreshToken = jwtTokenUtil.generateRefreshToken(user);

        return convertLoginResponse(token, refreshToken, user);
    }

    private LoginResponse convertLoginResponse(String token, String refreshToken, Users user) {
        LoginResponse loginResponse = new LoginResponse();

        UserResponse userResponse = new UserResponse();
        userResponse.setId(user.getId());
        userResponse.setEmailAddress(user.getEmailAddress());
        userResponse.setUsername(user.getActualUsername());
        userResponse.setRole(user.getRole().getRoleName());
        userResponse.setCreatedAt(user.getCreatedAt());
        userResponse.setEmailVerified(user.getEmailVerified());

        loginResponse.setUserDetails(userResponse);
        loginResponse.setToken(token);
        loginResponse.setRefreshToken(refreshToken);
        return loginResponse;
    }

    private RegisterResponse convertRegisterResponse(Users user) {
        RegisterResponse registerResponse = new RegisterResponse();

        registerResponse.setEmailAddress(user.getEmailAddress());
        registerResponse.setUsername(user.getActualUsername());

        return registerResponse;
    }

    private DJRegisterResponse convertDJRegisterResponse(Users djUser) {
        DJRegisterResponse response = new DJRegisterResponse();

        response.setEmailAddress(djUser.getEmailAddress());
        response.setUsername(djUser.getActualUsername());
        response.setDjName(djUser.getActualUsername()); // Use username as DJ name for now
        response.setBio(djUser.getBio());
        response.setGenres(djUser.getGenres());
        response.setInstagramHandle(djUser.getInstagramHandle());
        response.setProfileImage(djUser.getProfileImage());
        response.setRating(djUser.getRating());
        response.setFollowers(djUser.getFollowers());
        response.setEmailVerified(djUser.getEmailVerified());
        response.setMessage("DJ registration successful. Please check your email for verification.");

        return response;
    }

    @Override
    public UserDetails loadUserByUsername(String emailAddress) throws UsernameNotFoundException {
        Users user = userRepository.findByEmailAddress(emailAddress);
        if (user == null) {
            throw new UsernameNotFoundException("User not found with email: " + emailAddress);
        }

        // Return email as username for JWT consistency
        return new org.springframework.security.core.userdetails.User(user.getEmailAddress(), user.getPassword(),
                user.getAuthorities());
    }

    private boolean isValidPhoneNumber(String phoneNumber) {
        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            return false;
        }

        // Remove spaces and common separators
        String cleanNumber = phoneNumber.replaceAll("[\\s\\-\\(\\)]", "");

        // Check if it starts with + and contains only digits after that
        if (cleanNumber.startsWith("+")) {
            String numberPart = cleanNumber.substring(1);
            return numberPart.matches("\\d{10,15}"); // 10-15 digits after country code
        }

        // For local numbers, check if it's all digits and reasonable length
        return cleanNumber.matches("\\d{9,15}");
    }

    public List<ProfileResponse> getAllUsers() {
        List<Profile> profiles = profileRepository.findAll(); // this gives you access to both Profile and Users
        return profiles.stream()
                .map(this::convertUserResponse)
                .toList();
    }

    private ProfileResponse convertUserResponse(Profile profile) {
        Users user = profile.getUsers();

        ProfileResponse response = new ProfileResponse();
        response.setUsername(user.getUsername());
        response.setEmailAddress(user.getEmailAddress());

        response.setFirstName(profile.getFirstName());
        response.setLastName(profile.getLastName());
        response.setPhoneNumber(profile.getPhoneNumber());
        response.setImageUrl(profile.getImageUrl());

        return response;
    }

    // Get current user with detailed information including favorites
    public UserResponse getCurrentUserWithDetails() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();
        Users user = userRepository.findByEmailAddress(email);
        if (user == null) {
            throw new RuntimeException("User not found");
        }

        UserResponse response = new UserResponse();
        response.setId(user.getId());
        response.setEmailAddress(user.getEmailAddress());
        response.setUsername(user.getActualUsername());
        response.setRole(user.getRole().getRoleName());
        response.setCreatedAt(user.getCreatedAt());
        response.setEmailVerified(user.getEmailVerified());
        response.setIsActive(user.getIsActive());
        response.setCredits(user.getCredits());
        response.setFollowers(user.getFollowers());
        response.setRating(user.getRating());
        response.setGenres(user.getGenres());
        response.setBio(user.getBio());
        response.setProfileImage(user.getProfileImage());
        response.setInstagramHandle(user.getInstagramHandle());
        response.setIsLive(user.getIsLive());

        return response;
    }

    // Update current user profile
    @Transactional
    public UserResponse updateCurrentUser(RegisterRequest updateRequest) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();
        Users user = userRepository.findByEmailAddress(email);
        if (user == null) {
            throw new RuntimeException("User not found");
        }

        // Update allowed fields
        if (updateRequest.getUsername() != null && !updateRequest.getUsername().trim().isEmpty()) {
            user.setActualUsername(updateRequest.getUsername().trim());
        }

        if (updateRequest.getPhoneNumber() != null && !updateRequest.getPhoneNumber().trim().isEmpty()) {
            user.setPhoneNumber(updateRequest.getPhoneNumber().trim());
        }

        user.setUpdatedAt(LocalDateTime.now());
        Users updatedUser = userRepository.save(user);

        return getCurrentUserWithDetails();
    }
}
