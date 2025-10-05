package com.spinwish.backend.services;

import com.spinwish.backend.entities.Users;
import com.spinwish.backend.exceptions.UnauthorizedException;
import com.spinwish.backend.models.requests.users.SendVerificationRequest;
import com.spinwish.backend.models.requests.users.VerificationRequest;
import com.spinwish.backend.models.responses.users.SendVerificationResponse;
import com.spinwish.backend.models.responses.users.VerificationResponse;
import com.spinwish.backend.models.responses.users.UserResponse;
import com.spinwish.backend.repositories.UsersRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;
import java.util.Random;

@Service
public class VerificationService {

    private static final Logger logger = LoggerFactory.getLogger(VerificationService.class);
    private static final int VERIFICATION_CODE_LENGTH = 6;
    private static final int VERIFICATION_CODE_EXPIRY_MINUTES = 10;

    @Autowired
    private UsersRepository usersRepository;

    @Autowired
    private EmailService emailService;

    @Autowired
    private SmsService smsService;

    @Autowired
    private JwtService jwtService;

    public SendVerificationResponse sendVerificationCode(SendVerificationRequest request) {
        try {
            Users user = usersRepository.findByEmailAddress(request.getEmailAddress());
            if (user == null) {
                throw new UnauthorizedException("User not found");
            }

            // Generate 6-digit verification code
            String verificationCode = generateVerificationCode();
            
            // Set expiry time (10 minutes from now)
            LocalDateTime expiryTime = LocalDateTime.now().plusMinutes(VERIFICATION_CODE_EXPIRY_MINUTES);
            
            // Update user with verification code and expiry
            user.setVerificationCode(verificationCode);
            user.setVerificationCodeExpiry(expiryTime);
            usersRepository.save(user);

            SendVerificationResponse response = new SendVerificationResponse();
            response.setVerificationType(request.getVerificationType());

            boolean sent = false;
            String destination = "";

            if ("EMAIL".equalsIgnoreCase(request.getVerificationType())) {
                sent = emailService.sendVerificationCode(
                    user.getEmailAddress(), 
                    verificationCode, 
                    user.getActualUsername()
                );
                destination = maskEmail(user.getEmailAddress());
                
            } else if ("PHONE".equalsIgnoreCase(request.getVerificationType())) {
                if (user.getPhoneNumber() == null || user.getPhoneNumber().isEmpty()) {
                    throw new UnauthorizedException("Phone number not provided during registration");
                }
                
                sent = smsService.sendVerificationCode(
                    user.getPhoneNumber(), 
                    verificationCode, 
                    user.getActualUsername()
                );
                destination = maskPhoneNumber(user.getPhoneNumber());
            } else {
                throw new UnauthorizedException("Invalid verification type. Use EMAIL or PHONE");
            }

            response.setSuccess(sent);
            response.setMessage(sent ? 
                "Verification code sent successfully" : 
                "Failed to send verification code");
            response.setDestination(destination);

            logger.info("Verification code sent via {} to user: {}", 
                request.getVerificationType(), user.getEmailAddress());

            return response;

        } catch (Exception e) {
            logger.error("Failed to send verification code", e);
            SendVerificationResponse response = new SendVerificationResponse();
            response.setSuccess(false);
            response.setMessage("Failed to send verification code: " + e.getMessage());
            return response;
        }
    }

    public VerificationResponse verifyCode(VerificationRequest request) {
        try {
            Users user = usersRepository.findByEmailAddress(request.getEmailAddress());
            if (user == null) {
                throw new UnauthorizedException("User not found");
            }

            // Check if verification code exists and matches
            if (user.getVerificationCode() == null || 
                !user.getVerificationCode().equals(request.getVerificationCode())) {
                throw new UnauthorizedException("Invalid verification code");
            }

            // Check if verification code has expired
            if (user.getVerificationCodeExpiry() == null || 
                LocalDateTime.now().isAfter(user.getVerificationCodeExpiry())) {
                throw new UnauthorizedException("Verification code has expired");
            }

            // Mark appropriate field as verified
            if ("EMAIL".equalsIgnoreCase(request.getVerificationType())) {
                user.setEmailVerified(true);
                // Send welcome email
                emailService.sendWelcomeEmail(user.getEmailAddress(), user.getActualUsername());
                
            } else if ("PHONE".equalsIgnoreCase(request.getVerificationType())) {
                user.setPhoneVerified(true);
                // Send welcome SMS
                if (user.getPhoneNumber() != null) {
                    smsService.sendWelcomeSms(user.getPhoneNumber(), user.getActualUsername());
                }
            }

            // Clear verification code after successful verification
            user.setVerificationCode(null);
            user.setVerificationCodeExpiry(null);
            
            // Activate user account
            user.setIsActive(true);
            
            usersRepository.save(user);

            // Generate JWT tokens for automatic login
            String token = jwtService.generateToken(user);
            String refreshToken = jwtService.generateRefreshToken(user);

            // Create response
            VerificationResponse response = new VerificationResponse();
            response.setSuccess(true);
            response.setMessage("Verification successful");
            response.setToken(token);
            response.setRefreshToken(refreshToken);

            // Create user response
            UserResponse userResponse = new UserResponse();
            userResponse.setEmailAddress(user.getEmailAddress());
            userResponse.setUsername(user.getActualUsername());
            userResponse.setRole(user.getRole().getRoleName());
            userResponse.setCreatedAt(user.getCreatedAt());
            response.setUserDetails(userResponse);

            logger.info("User verified successfully via {}: {}", 
                request.getVerificationType(), user.getEmailAddress());

            return response;

        } catch (Exception e) {
            logger.error("Verification failed", e);
            VerificationResponse response = new VerificationResponse();
            response.setSuccess(false);
            response.setMessage("Verification failed: " + e.getMessage());
            return response;
        }
    }

    private String generateVerificationCode() {
        Random random = new Random();
        StringBuilder code = new StringBuilder();
        for (int i = 0; i < VERIFICATION_CODE_LENGTH; i++) {
            code.append(random.nextInt(10));
        }
        return code.toString();
    }

    private String maskEmail(String email) {
        if (email == null || !email.contains("@")) {
            return "****@****.com";
        }
        String[] parts = email.split("@");
        String username = parts[0];
        String domain = parts[1];
        
        String maskedUsername = username.length() > 2 ? 
            username.substring(0, 2) + "****" : "****";
        String maskedDomain = domain.length() > 4 ? 
            "****" + domain.substring(domain.length() - 4) : "****.com";
            
        return maskedUsername + "@" + maskedDomain;
    }

    private String maskPhoneNumber(String phoneNumber) {
        if (phoneNumber == null || phoneNumber.length() < 4) {
            return "+254****";
        }
        return phoneNumber.substring(0, 4) + "****" + phoneNumber.substring(phoneNumber.length() - 2);
    }
}
