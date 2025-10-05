package com.spinwish.backend.models.responses.errors;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.spinwish.backend.enums.ErrorCode;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * Comprehensive API error response model
 * Provides detailed error information including correlation IDs, error codes, and context
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiErrorResponse {
    
    /**
     * HTTP status code
     */
    private int status;
    
    /**
     * Error code for programmatic handling
     */
    private String errorCode;
    
    /**
     * Human-readable error message
     */
    private String message;
    
    /**
     * Detailed error description
     */
    private String details;
    
    /**
     * Timestamp when the error occurred
     */
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS")
    private LocalDateTime timestamp;
    
    /**
     * Request path where the error occurred
     */
    private String path;
    
    /**
     * HTTP method of the request
     */
    private String method;
    
    /**
     * Unique correlation ID for tracking this request
     */
    private String correlationId;
    
    /**
     * Session ID if available
     */
    private String sessionId;
    
    /**
     * User ID if authenticated
     */
    private String userId;
    
    /**
     * List of detailed error information (for validation errors)
     */
    private List<ErrorDetail> errors;
    
    /**
     * Additional metadata or context
     */
    private Map<String, Object> metadata;
    
    /**
     * Suggested actions for the client
     */
    private List<String> suggestions;
    
    /**
     * Reference to documentation or help
     */
    private String helpUrl;
    
    /**
     * Whether this error should be retried
     */
    private Boolean retryable;
    
    /**
     * Retry delay in milliseconds if retryable
     */
    private Long retryAfter;
    
    /**
     * Create a simple error response
     */
    public static ApiErrorResponse simple(int status, ErrorCode errorCode, String message) {
        return ApiErrorResponse.builder()
                .status(status)
                .errorCode(errorCode.getCode())
                .message(message != null ? message : errorCode.getDefaultMessage())
                .timestamp(LocalDateTime.now())
                .build();
    }
    
    /**
     * Create a detailed error response
     */
    public static ApiErrorResponse detailed(int status, ErrorCode errorCode, String message, 
                                          String path, String method, String correlationId) {
        return ApiErrorResponse.builder()
                .status(status)
                .errorCode(errorCode.getCode())
                .message(message != null ? message : errorCode.getDefaultMessage())
                .path(path)
                .method(method)
                .correlationId(correlationId)
                .timestamp(LocalDateTime.now())
                .build();
    }
    
    /**
     * Create a validation error response
     */
    public static ApiErrorResponse validation(int status, String message, List<ErrorDetail> errors,
                                            String path, String method, String correlationId) {
        return ApiErrorResponse.builder()
                .status(status)
                .errorCode(ErrorCode.VALIDATION_FAILED.getCode())
                .message(message)
                .errors(errors)
                .path(path)
                .method(method)
                .correlationId(correlationId)
                .timestamp(LocalDateTime.now())
                .build();
    }
    
    /**
     * Create a business logic error response
     */
    public static ApiErrorResponse business(int status, ErrorCode errorCode, String message,
                                          String details, String correlationId) {
        return ApiErrorResponse.builder()
                .status(status)
                .errorCode(errorCode.getCode())
                .message(message != null ? message : errorCode.getDefaultMessage())
                .details(details)
                .correlationId(correlationId)
                .timestamp(LocalDateTime.now())
                .build();
    }
    
    /**
     * Add suggestion to the error response
     */
    public ApiErrorResponse addSuggestion(String suggestion) {
        if (this.suggestions == null) {
            this.suggestions = new java.util.ArrayList<>();
        }
        this.suggestions.add(suggestion);
        return this;
    }
    
    /**
     * Add metadata to the error response
     */
    public ApiErrorResponse addMetadata(String key, Object value) {
        if (this.metadata == null) {
            this.metadata = new java.util.HashMap<>();
        }
        this.metadata.put(key, value);
        return this;
    }
    
    /**
     * Set retry information
     */
    public ApiErrorResponse setRetryInfo(boolean retryable, Long retryAfter) {
        this.retryable = retryable;
        this.retryAfter = retryAfter;
        return this;
    }
}
