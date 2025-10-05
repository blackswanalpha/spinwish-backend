package com.spinwish.backend.exceptions;

import com.spinwish.backend.enums.ErrorCode;
import lombok.Getter;

import java.util.HashMap;
import java.util.Map;

/**
 * Base exception class for all custom exceptions in the SpinWish application
 * Provides common functionality for error handling, context, and metadata
 */
@Getter
public abstract class BaseException extends RuntimeException {
    
    /**
     * Error code associated with this exception
     */
    private final ErrorCode errorCode;
    
    /**
     * Additional context information
     */
    private final Map<String, Object> context;
    
    /**
     * Whether this exception should be retried
     */
    private final boolean retryable;
    
    /**
     * User-friendly message (different from technical message)
     */
    private final String userMessage;
    
    /**
     * Correlation ID for tracking
     */
    private String correlationId;
    
    /**
     * Constructor with error code and message
     */
    protected BaseException(ErrorCode errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
        this.context = new HashMap<>();
        this.retryable = false;
        this.userMessage = null;
    }
    
    /**
     * Constructor with error code, message, and cause
     */
    protected BaseException(ErrorCode errorCode, String message, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
        this.context = new HashMap<>();
        this.retryable = false;
        this.userMessage = null;
    }
    
    /**
     * Constructor with full parameters
     */
    protected BaseException(ErrorCode errorCode, String message, String userMessage, 
                          boolean retryable, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
        this.userMessage = userMessage;
        this.retryable = retryable;
        this.context = new HashMap<>();
    }
    
    /**
     * Add context information
     */
    public BaseException addContext(String key, Object value) {
        this.context.put(key, value);
        return this;
    }
    
    /**
     * Set correlation ID
     */
    public BaseException setCorrelationId(String correlationId) {
        this.correlationId = correlationId;
        return this;
    }
    
    /**
     * Get user-friendly message, fallback to error code default message
     */
    public String getUserFriendlyMessage() {
        return userMessage != null ? userMessage : errorCode.getDefaultMessage();
    }
    
    /**
     * Get technical message (exception message)
     */
    public String getTechnicalMessage() {
        return getMessage();
    }
    
    /**
     * Check if this is a client error (4xx)
     */
    public boolean isClientError() {
        return errorCode.isClientError();
    }
    
    /**
     * Check if this is a server error (5xx)
     */
    public boolean isServerError() {
        return errorCode.isServerError();
    }
}
