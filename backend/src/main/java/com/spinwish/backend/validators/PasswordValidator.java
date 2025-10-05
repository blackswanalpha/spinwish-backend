package com.spinwish.backend.validators;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import java.util.regex.Pattern;

/**
 * Custom password validator with security requirements
 */
public class PasswordValidator implements ConstraintValidator<ValidPassword, String> {
    
    private static final int MIN_LENGTH = 8;
    private static final int MAX_LENGTH = 128;
    
    // At least one uppercase letter, one lowercase letter, one digit, and one special character
    private static final String STRONG_PASSWORD_PATTERN = 
        "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]";
    
    private static final Pattern pattern = Pattern.compile(STRONG_PASSWORD_PATTERN);
    
    @Override
    public void initialize(ValidPassword constraintAnnotation) {
        // Initialization if needed
    }
    
    @Override
    public boolean isValid(String password, ConstraintValidatorContext context) {
        if (password == null || password.trim().isEmpty()) {
            return true; // Let @NotNull handle null/empty validation
        }
        
        context.disableDefaultConstraintViolation();
        boolean isValid = true;
        
        // Check minimum length
        if (password.length() < MIN_LENGTH) {
            context.buildConstraintViolationWithTemplate(
                "Password must be at least " + MIN_LENGTH + " characters long")
                .addConstraintViolation();
            isValid = false;
        }
        
        // Check maximum length
        if (password.length() > MAX_LENGTH) {
            context.buildConstraintViolationWithTemplate(
                "Password must not exceed " + MAX_LENGTH + " characters")
                .addConstraintViolation();
            isValid = false;
        }
        
        // Check for at least one lowercase letter
        if (!password.matches(".*[a-z].*")) {
            context.buildConstraintViolationWithTemplate(
                "Password must contain at least one lowercase letter")
                .addConstraintViolation();
            isValid = false;
        }
        
        // Check for at least one uppercase letter
        if (!password.matches(".*[A-Z].*")) {
            context.buildConstraintViolationWithTemplate(
                "Password must contain at least one uppercase letter")
                .addConstraintViolation();
            isValid = false;
        }
        
        // Check for at least one digit
        if (!password.matches(".*\\d.*")) {
            context.buildConstraintViolationWithTemplate(
                "Password must contain at least one digit")
                .addConstraintViolation();
            isValid = false;
        }
        
        // Check for at least one special character
        if (!password.matches(".*[@$!%*?&].*")) {
            context.buildConstraintViolationWithTemplate(
                "Password must contain at least one special character (@$!%*?&)")
                .addConstraintViolation();
            isValid = false;
        }
        
        // Check for common weak passwords
        if (isCommonPassword(password)) {
            context.buildConstraintViolationWithTemplate(
                "Password is too common. Please choose a more secure password")
                .addConstraintViolation();
            isValid = false;
        }
        
        // Check for sequential characters
        if (hasSequentialCharacters(password)) {
            context.buildConstraintViolationWithTemplate(
                "Password should not contain sequential characters")
                .addConstraintViolation();
            isValid = false;
        }
        
        return isValid;
    }
    
    /**
     * Check if password is in common password list
     */
    private boolean isCommonPassword(String password) {
        String[] commonPasswords = {
            "password", "123456", "123456789", "12345678", "12345",
            "1234567", "admin", "qwerty", "abc123", "password123",
            "welcome", "letmein", "monkey", "dragon", "master"
        };
        
        String lowerPassword = password.toLowerCase();
        for (String common : commonPasswords) {
            if (lowerPassword.contains(common)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Check for sequential characters (e.g., 123, abc, qwe)
     */
    private boolean hasSequentialCharacters(String password) {
        String lowerPassword = password.toLowerCase();
        
        // Check for sequential numbers
        for (int i = 0; i < lowerPassword.length() - 2; i++) {
            char c1 = lowerPassword.charAt(i);
            char c2 = lowerPassword.charAt(i + 1);
            char c3 = lowerPassword.charAt(i + 2);
            
            if (Character.isDigit(c1) && Character.isDigit(c2) && Character.isDigit(c3)) {
                if (c2 == c1 + 1 && c3 == c2 + 1) {
                    return true;
                }
            }
            
            if (Character.isLetter(c1) && Character.isLetter(c2) && Character.isLetter(c3)) {
                if (c2 == c1 + 1 && c3 == c2 + 1) {
                    return true;
                }
            }
        }
        
        return false;
    }
}
