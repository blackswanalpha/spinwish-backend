package com.spinwish.backend.enums;

/**
 * Comprehensive error codes for the SpinWish application
 * Each error code follows the pattern: CATEGORY_SPECIFIC_ERROR
 */
public enum ErrorCode {
    
    // Generic System Errors (1000-1099)
    INTERNAL_SERVER_ERROR("SYS_001", "Internal server error occurred"),
    SERVICE_UNAVAILABLE("SYS_002", "Service temporarily unavailable"),
    CONFIGURATION_ERROR("SYS_003", "System configuration error"),
    DATABASE_CONNECTION_ERROR("SYS_004", "Database connection failed"),
    EXTERNAL_SERVICE_ERROR("SYS_005", "External service error"),
    
    // Authentication & Authorization Errors (1100-1199)
    INVALID_CREDENTIALS("AUTH_001", "Invalid username or password"),
    TOKEN_EXPIRED("AUTH_002", "Authentication token has expired"),
    TOKEN_INVALID("AUTH_003", "Invalid authentication token"),
    ACCESS_DENIED("AUTH_004", "Access denied - insufficient permissions"),
    ACCOUNT_LOCKED("AUTH_005", "Account is locked"),
    ACCOUNT_DISABLED("AUTH_006", "Account is disabled"),
    SESSION_EXPIRED("AUTH_007", "Session has expired"),
    UNAUTHORIZED_ACCESS("AUTH_008", "Unauthorized access attempt"),
    
    // User Management Errors (1200-1299)
    USER_NOT_FOUND("USER_001", "User not found"),
    USER_ALREADY_EXISTS("USER_002", "User already exists"),
    EMAIL_ALREADY_REGISTERED("USER_003", "Email address already registered"),
    PHONE_ALREADY_REGISTERED("USER_004", "Phone number already registered"),
    INVALID_USER_DATA("USER_005", "Invalid user data provided"),
    PASSWORD_TOO_WEAK("USER_006", "Password does not meet security requirements"),
    EMAIL_NOT_VERIFIED("USER_007", "Email address not verified"),
    PHONE_NOT_VERIFIED("USER_008", "Phone number not verified"),
    PROFILE_NOT_FOUND("USER_009", "User profile not found"),
    ROLE_NOT_FOUND("USER_010", "User role not found"),
    
    // Validation Errors (1300-1399)
    VALIDATION_FAILED("VAL_001", "Input validation failed"),
    REQUIRED_FIELD_MISSING("VAL_002", "Required field is missing"),
    INVALID_EMAIL_FORMAT("VAL_003", "Invalid email format"),
    INVALID_PHONE_FORMAT("VAL_004", "Invalid phone number format"),
    INVALID_DATE_FORMAT("VAL_005", "Invalid date format"),
    VALUE_OUT_OF_RANGE("VAL_006", "Value is out of acceptable range"),
    INVALID_FILE_TYPE("VAL_007", "Invalid file type"),
    FILE_SIZE_EXCEEDED("VAL_008", "File size exceeds maximum limit"),
    DUPLICATE_VALUE("VAL_009", "Duplicate value not allowed"),
    
    // Business Logic Errors (1400-1499)
    ARTIST_NOT_FOUND("BIZ_001", "Artist not found"),
    ARTIST_ALREADY_EXISTS("BIZ_002", "Artist already exists"),
    SONG_NOT_FOUND("BIZ_003", "Song not found"),
    PLAYLIST_NOT_FOUND("BIZ_004", "Playlist not found"),
    PLAYBACK_FAILED("BIZ_005", "Playback creation failed"),
    INSUFFICIENT_PERMISSIONS("BIZ_006", "Insufficient permissions for this operation"),
    OPERATION_NOT_ALLOWED("BIZ_007", "Operation not allowed in current state"),
    RESOURCE_CONFLICT("BIZ_008", "Resource conflict detected"),
    
    // Payment Errors (1500-1599)
    PAYMENT_FAILED("PAY_001", "Payment processing failed"),
    INSUFFICIENT_FUNDS("PAY_002", "Insufficient funds"),
    PAYMENT_METHOD_INVALID("PAY_003", "Invalid payment method"),
    TRANSACTION_NOT_FOUND("PAY_004", "Transaction not found"),
    PAYMENT_TIMEOUT("PAY_005", "Payment processing timeout"),
    REFUND_FAILED("PAY_006", "Refund processing failed"),
    MPESA_ERROR("PAY_007", "M-Pesa service error"),
    
    // File Upload Errors (1600-1699)
    FILE_UPLOAD_FAILED("FILE_001", "File upload failed"),
    FILE_NOT_FOUND("FILE_002", "File not found"),
    FILE_PROCESSING_ERROR("FILE_003", "File processing error"),
    INVALID_FILE_FORMAT("FILE_004", "Invalid file format"),
    FILE_CORRUPTED("FILE_005", "File is corrupted"),
    STORAGE_QUOTA_EXCEEDED("FILE_006", "Storage quota exceeded"),
    
    // Network & Communication Errors (1700-1799)
    NETWORK_ERROR("NET_001", "Network communication error"),
    TIMEOUT_ERROR("NET_002", "Request timeout"),
    CONNECTION_REFUSED("NET_003", "Connection refused"),
    DNS_RESOLUTION_FAILED("NET_004", "DNS resolution failed"),
    SSL_HANDSHAKE_FAILED("NET_005", "SSL handshake failed"),
    
    // Rate Limiting & Throttling (1800-1899)
    RATE_LIMIT_EXCEEDED("RATE_001", "Rate limit exceeded"),
    TOO_MANY_REQUESTS("RATE_002", "Too many requests"),
    QUOTA_EXCEEDED("RATE_003", "API quota exceeded"),
    CONCURRENT_LIMIT_EXCEEDED("RATE_004", "Concurrent request limit exceeded"),
    
    // Data Integrity Errors (1900-1999)
    DATA_CORRUPTION("DATA_001", "Data corruption detected"),
    CONSTRAINT_VIOLATION("DATA_002", "Database constraint violation"),
    FOREIGN_KEY_VIOLATION("DATA_003", "Foreign key constraint violation"),
    UNIQUE_CONSTRAINT_VIOLATION("DATA_004", "Unique constraint violation"),
    DATA_INCONSISTENCY("DATA_005", "Data inconsistency detected");
    
    private final String code;
    private final String defaultMessage;
    
    ErrorCode(String code, String defaultMessage) {
        this.code = code;
        this.defaultMessage = defaultMessage;
    }
    
    public String getCode() {
        return code;
    }
    
    public String getDefaultMessage() {
        return defaultMessage;
    }
    
    /**
     * Get error code by string value
     */
    public static ErrorCode fromCode(String code) {
        for (ErrorCode errorCode : values()) {
            if (errorCode.getCode().equals(code)) {
                return errorCode;
            }
        }
        return INTERNAL_SERVER_ERROR; // Default fallback
    }
    
    /**
     * Check if error code represents a client error (4xx)
     */
    public boolean isClientError() {
        return this.name().startsWith("AUTH_") || 
               this.name().startsWith("USER_") || 
               this.name().startsWith("VAL_") ||
               this.name().startsWith("RATE_");
    }
    
    /**
     * Check if error code represents a server error (5xx)
     */
    public boolean isServerError() {
        return this.name().startsWith("SYS_") || 
               this.name().startsWith("NET_") || 
               this.name().startsWith("DATA_") ||
               this.name().startsWith("FILE_");
    }
}
