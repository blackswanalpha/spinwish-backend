package com.spinwish.backend.controllers;

import com.spinwish.backend.services.EmailService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@RestController
@RequestMapping(path = "api/v1/email-test")
@Tag(name = "Email Testing", description = "APIs for testing email functionality (Development only)")
public class EmailTestController {

    private static final Logger logger = LoggerFactory.getLogger(EmailTestController.class);

    @Autowired
    private EmailService emailService;

    @Value("${email.test.enabled:false}")
    private boolean emailTestEnabled;

    @Value("${email.test.recipient:kamandembugua18@gmail.com}")
    private String testRecipient;

    @Operation(
            summary = "Test verification email sending",
            description = "Send a test verification email to verify SMTP configuration is working"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Test email sent successfully"
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Email testing is disabled"
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "Failed to send test email"
            )
    })
    @PostMapping("/send-verification")
    public ResponseEntity<Map<String, Object>> testVerificationEmail(
            @Parameter(description = "Email address to send test to (optional, defaults to configured test recipient)")
            @RequestParam(required = false) String email,
            @Parameter(description = "Username for the test email (optional)")
            @RequestParam(required = false, defaultValue = "Test User") String username) {

        Map<String, Object> response = new HashMap<>();

        if (!emailTestEnabled) {
            response.put("success", false);
            response.put("message", "Email testing is disabled. Set email.test.enabled=true in application properties.");
            return ResponseEntity.badRequest().body(response);
        }

        String targetEmail = (email != null && !email.trim().isEmpty()) ? email.trim() : testRecipient;
        String testCode = generateTestVerificationCode();

        try {
            logger.info("Testing verification email to: {}", targetEmail);
            
            boolean sent = emailService.sendVerificationCode(targetEmail, testCode, username);
            
            if (sent) {
                response.put("success", true);
                response.put("message", "Test verification email sent successfully");
                response.put("recipient", maskEmail(targetEmail));
                response.put("testCode", testCode);
                response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                
                logger.info("Test verification email sent successfully to: {}", targetEmail);
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "Failed to send test verification email");
                response.put("recipient", maskEmail(targetEmail));
                
                logger.error("Failed to send test verification email to: {}", targetEmail);
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
            }

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error occurred while sending test email: " + e.getMessage());
            response.put("recipient", maskEmail(targetEmail));
            
            logger.error("Error occurred while sending test verification email to: {}", targetEmail, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @Operation(
            summary = "Test welcome email sending",
            description = "Send a test welcome email to verify SMTP configuration is working"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Test welcome email sent successfully"
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Email testing is disabled"
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "Failed to send test welcome email"
            )
    })
    @PostMapping("/send-welcome")
    public ResponseEntity<Map<String, Object>> testWelcomeEmail(
            @Parameter(description = "Email address to send test to (optional, defaults to configured test recipient)")
            @RequestParam(required = false) String email,
            @Parameter(description = "Username for the test email (optional)")
            @RequestParam(required = false, defaultValue = "Test User") String username) {

        Map<String, Object> response = new HashMap<>();

        if (!emailTestEnabled) {
            response.put("success", false);
            response.put("message", "Email testing is disabled. Set email.test.enabled=true in application properties.");
            return ResponseEntity.badRequest().body(response);
        }

        String targetEmail = (email != null && !email.trim().isEmpty()) ? email.trim() : testRecipient;

        try {
            logger.info("Testing welcome email to: {}", targetEmail);
            
            boolean sent = emailService.sendWelcomeEmail(targetEmail, username);
            
            if (sent) {
                response.put("success", true);
                response.put("message", "Test welcome email sent successfully");
                response.put("recipient", maskEmail(targetEmail));
                response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                
                logger.info("Test welcome email sent successfully to: {}", targetEmail);
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "Failed to send test welcome email");
                response.put("recipient", maskEmail(targetEmail));
                
                logger.error("Failed to send test welcome email to: {}", targetEmail);
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
            }

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error occurred while sending test email: " + e.getMessage());
            response.put("recipient", maskEmail(targetEmail));
            
            logger.error("Error occurred while sending test welcome email to: {}", targetEmail, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @Operation(
            summary = "Get email configuration status",
            description = "Check if email configuration is properly set up"
    )
    @GetMapping("/config-status")
    public ResponseEntity<Map<String, Object>> getEmailConfigStatus() {
        Map<String, Object> response = new HashMap<>();
        
        response.put("emailTestEnabled", emailTestEnabled);
        response.put("testRecipient", maskEmail(testRecipient));
        response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        
        return ResponseEntity.ok(response);
    }

    /**
     * Generate a test verification code
     */
    private String generateTestVerificationCode() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(1000000));
    }

    /**
     * Mask email address for logging purposes
     */
    private String maskEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return "***";
        }
        
        int atIndex = email.indexOf('@');
        if (atIndex <= 0) {
            return "***";
        }
        
        String localPart = email.substring(0, atIndex);
        String domain = email.substring(atIndex);
        
        if (localPart.length() <= 2) {
            return "*".repeat(localPart.length()) + domain;
        }
        
        return localPart.charAt(0) + "*".repeat(localPart.length() - 2) + 
               localPart.charAt(localPart.length() - 1) + domain;
    }
}
