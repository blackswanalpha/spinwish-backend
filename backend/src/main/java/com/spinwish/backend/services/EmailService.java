package com.spinwish.backend.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class EmailService {

    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);

    @Autowired
    private JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    @Value("${spring.mail.host:smtp.gmail.com}")
    private String mailHost;

    @Value("${spring.mail.port:587}")
    private String mailPort;

    public boolean sendVerificationCode(String toEmail, String verificationCode, String username) {
        try {
            // Validate email configuration
            if (!isEmailConfigurationValid()) {
                logger.error("Email configuration is invalid. Cannot send verification email.");
                return false;
            }

            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(toEmail);
            message.setSubject("SpinWish - Email Verification Code");

            String emailBody = String.format(
                "Hello %s,\n\n" +
                "Welcome to SpinWish! 🎵\n\n" +
                "Please use the following verification code to complete your registration:\n\n" +
                "┌─────────────────────┐\n" +
                "│  Verification Code  │\n" +
                "│       %s        │\n" +
                "└─────────────────────┘\n\n" +
                "⏰ This code will expire in 10 minutes.\n\n" +
                "🔒 For your security, do not share this code with anyone.\n\n" +
                "If you didn't create an account with SpinWish, please ignore this email.\n\n" +
                "Best regards,\n" +
                "The SpinWish Team 🎶\n\n" +
                "---\n" +
                "SpinWish - Where Music Meets Moments",
                username, verificationCode
            );

            message.setText(emailBody);

            logger.debug("Attempting to send verification email to: {} using SMTP server: {}:{}",
                        maskEmail(toEmail), mailHost, mailPort);

            mailSender.send(message);
            logger.info("Verification email sent successfully to: {}", maskEmail(toEmail));
            return true;

        } catch (Exception e) {
            logger.error("Failed to send verification email to: {}. Error: {}",
                        maskEmail(toEmail), e.getMessage(), e);
            return false;
        }
    }

    public boolean sendWelcomeEmail(String toEmail, String username) {
        try {
            if (!isEmailConfigurationValid()) {
                logger.error("Email configuration is invalid. Cannot send welcome email.");
                return false;
            }

            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(toEmail);
            message.setSubject("🎉 Welcome to SpinWish!");

            String emailBody = String.format(
                "Hello %s,\n\n" +
                "🎉 Welcome to SpinWish! Your account has been successfully verified.\n\n" +
                "🎵 You can now enjoy all the amazing features of SpinWish:\n\n" +
                "🎤 Request your favorite songs from DJs\n" +
                "🎶 Discover new music and artists\n" +
                "🎧 Connect with DJs in your area\n" +
                "💫 Create unforgettable musical moments\n\n" +
                "🚀 Get started by exploring the app and making your first song request!\n\n" +
                "Need help? Our support team is here for you.\n\n" +
                "Best regards,\n" +
                "The SpinWish Team 🎶\n\n" +
                "---\n" +
                "SpinWish - Where Music Meets Moments\n" +
                "Follow us for the latest updates and music trends!",
                username
            );

            message.setText(emailBody);

            logger.debug("Attempting to send welcome email to: {}", maskEmail(toEmail));
            mailSender.send(message);
            logger.info("Welcome email sent successfully to: {}", maskEmail(toEmail));
            return true;

        } catch (Exception e) {
            logger.error("Failed to send welcome email to: {}. Error: {}",
                        maskEmail(toEmail), e.getMessage(), e);
            return false;
        }
    }

    /**
     * Validates if email configuration is properly set up
     */
    private boolean isEmailConfigurationValid() {
        if (fromEmail == null || fromEmail.trim().isEmpty() || fromEmail.contains("your-email")) {
            logger.error("Email username is not configured properly: {}", fromEmail);
            return false;
        }

        if (mailHost == null || mailHost.trim().isEmpty()) {
            logger.error("Email host is not configured properly: {}", mailHost);
            return false;
        }

        try {
            // Test if JavaMailSender is properly configured
            if (mailSender == null) {
                logger.error("JavaMailSender is not configured");
                return false;
            }

            logger.debug("Email configuration validated successfully. Host: {}, Port: {}, Username: {}",
                        mailHost, mailPort, maskEmail(fromEmail));
            return true;

        } catch (Exception e) {
            logger.error("Email configuration validation failed", e);
            return false;
        }
    }

    /**
     * Masks email address for logging purposes
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
