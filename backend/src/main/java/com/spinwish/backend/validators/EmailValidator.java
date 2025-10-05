package com.spinwish.backend.validators;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import java.util.regex.Pattern;

/**
 * Custom email validator with enhanced validation rules
 */
public class EmailValidator implements ConstraintValidator<ValidEmail, String> {
    
    private static final String EMAIL_PATTERN = 
        "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@" +
        "(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
    
    private static final Pattern pattern = Pattern.compile(EMAIL_PATTERN);
    
    @Override
    public void initialize(ValidEmail constraintAnnotation) {
        // Initialization if needed
    }
    
    @Override
    public boolean isValid(String email, ConstraintValidatorContext context) {
        if (email == null || email.trim().isEmpty()) {
            return true; // Let @NotNull handle null/empty validation
        }
        
        // Basic format validation
        if (!pattern.matcher(email).matches()) {
            return false;
        }
        
        // Additional business rules
        if (email.length() > 254) { // RFC 5321 limit
            context.disableDefaultConstraintViolation();
            context.buildConstraintViolationWithTemplate("Email address is too long (max 254 characters)")
                   .addConstraintViolation();
            return false;
        }
        
        // Check for consecutive dots
        if (email.contains("..")) {
            context.disableDefaultConstraintViolation();
            context.buildConstraintViolationWithTemplate("Email address cannot contain consecutive dots")
                   .addConstraintViolation();
            return false;
        }
        
        // Check local part length (before @)
        String localPart = email.substring(0, email.indexOf('@'));
        if (localPart.length() > 64) { // RFC 5321 limit
            context.disableDefaultConstraintViolation();
            context.buildConstraintViolationWithTemplate("Email local part is too long (max 64 characters)")
                   .addConstraintViolation();
            return false;
        }
        
        return true;
    }
}
