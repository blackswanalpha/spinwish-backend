package com.spinwish.backend.exceptions;

import com.spinwish.backend.enums.ErrorCode;
import com.spinwish.backend.models.responses.errors.ErrorDetail;
import lombok.Getter;

import java.util.ArrayList;
import java.util.List;

/**
 * Exception for validation errors with detailed field-level error information
 */
@Getter
public class ValidationException extends BaseException {
    
    /**
     * List of detailed validation errors
     */
    private final List<ErrorDetail> validationErrors;
    
    public ValidationException(String message) {
        super(ErrorCode.VALIDATION_FAILED, message);
        this.validationErrors = new ArrayList<>();
    }
    
    public ValidationException(String message, List<ErrorDetail> validationErrors) {
        super(ErrorCode.VALIDATION_FAILED, message);
        this.validationErrors = validationErrors != null ? validationErrors : new ArrayList<>();
    }
    
    public ValidationException(ErrorCode errorCode, String message, List<ErrorDetail> validationErrors) {
        super(errorCode, message);
        this.validationErrors = validationErrors != null ? validationErrors : new ArrayList<>();
    }
    
    /**
     * Add a validation error
     */
    public ValidationException addValidationError(ErrorDetail errorDetail) {
        this.validationErrors.add(errorDetail);
        return this;
    }
    
    /**
     * Add a field validation error
     */
    public ValidationException addFieldError(String field, Object rejectedValue, String message, String code) {
        this.validationErrors.add(ErrorDetail.fieldError(field, rejectedValue, message, code));
        return this;
    }
    
    /**
     * Check if there are validation errors
     */
    public boolean hasValidationErrors() {
        return !validationErrors.isEmpty();
    }
    
    // Factory methods for common validation scenarios
    
    public static ValidationException requiredField(String fieldName) {
        ValidationException exception = new ValidationException("Required field is missing: " + fieldName);
        exception.addFieldError(fieldName, null, "This field is required", "REQUIRED");
        return exception;
    }
    
    public static ValidationException invalidEmail(String email) {
        ValidationException exception = new ValidationException("Invalid email format: " + email);
        exception.addFieldError("email", email, "Please enter a valid email address", "INVALID_FORMAT");
        return exception;
    }
    
    public static ValidationException invalidPhoneNumber(String phoneNumber) {
        ValidationException exception = new ValidationException("Invalid phone number format: " + phoneNumber);
        exception.addFieldError("phoneNumber", phoneNumber, "Please enter a valid phone number", "INVALID_FORMAT");
        return exception;
    }
    
    public static ValidationException passwordTooWeak(String reason) {
        ValidationException exception = new ValidationException("Password does not meet security requirements");
        exception.addFieldError("password", null, reason, "WEAK_PASSWORD");
        return exception;
    }
    
    public static ValidationException valueOutOfRange(String fieldName, Object value, Object min, Object max) {
        ValidationException exception = new ValidationException("Value out of range for field: " + fieldName);
        exception.addFieldError(fieldName, value, 
            String.format("Value must be between %s and %s", min, max), "OUT_OF_RANGE");
        return exception;
    }
    
    public static ValidationException invalidFileType(String fieldName, String actualType, String[] allowedTypes) {
        ValidationException exception = new ValidationException("Invalid file type: " + actualType);
        exception.addFieldError(fieldName, actualType, 
            "Allowed file types: " + String.join(", ", allowedTypes), "INVALID_FILE_TYPE");
        return exception;
    }
    
    public static ValidationException fileSizeExceeded(String fieldName, long actualSize, long maxSize) {
        ValidationException exception = new ValidationException("File size exceeds maximum limit");
        exception.addFieldError(fieldName, actualSize, 
            String.format("File size must not exceed %d bytes", maxSize), "FILE_SIZE_EXCEEDED");
        return exception;
    }
    
    public static ValidationException duplicateValue(String fieldName, Object value) {
        ValidationException exception = new ValidationException("Duplicate value not allowed: " + value);
        exception.addFieldError(fieldName, value, "This value already exists", "DUPLICATE_VALUE");
        return exception;
    }
}
