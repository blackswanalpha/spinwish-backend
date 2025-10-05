package com.spinwish.backend.exceptions;

import com.spinwish.backend.enums.ErrorCode;

/**
 * Exception for system-level errors and infrastructure issues
 */
public class SystemException extends BaseException {
    
    public SystemException(ErrorCode errorCode, String message) {
        super(errorCode, message, null, true, null); // System errors are typically retryable
    }
    
    public SystemException(ErrorCode errorCode, String message, Throwable cause) {
        super(errorCode, message, null, true, cause);
    }
    
    public SystemException(ErrorCode errorCode, String message, boolean retryable, Throwable cause) {
        super(errorCode, message, null, retryable, cause);
    }
    
    // Factory methods for common system errors
    
    public static SystemException internalServerError(String details, Throwable cause) {
        return new SystemException(
            ErrorCode.INTERNAL_SERVER_ERROR,
            "Internal server error: " + details,
            true,
            cause
        ).addContext("details", details);
    }
    
    public static SystemException serviceUnavailable(String serviceName, Throwable cause) {
        return new SystemException(
            ErrorCode.SERVICE_UNAVAILABLE,
            "Service unavailable: " + serviceName,
            true,
            cause
        ).addContext("serviceName", serviceName);
    }
    
    public static SystemException configurationError(String configKey, String details) {
        return new SystemException(
            ErrorCode.CONFIGURATION_ERROR,
            "Configuration error for key '" + configKey + "': " + details,
            false,
            null
        ).addContext("configKey", configKey).addContext("details", details);
    }
    
    public static SystemException databaseConnectionError(String details, Throwable cause) {
        return new SystemException(
            ErrorCode.DATABASE_CONNECTION_ERROR,
            "Database connection failed: " + details,
            true,
            cause
        ).addContext("details", details);
    }
    
    public static SystemException externalServiceError(String serviceName, String endpoint, Throwable cause) {
        return new SystemException(
            ErrorCode.EXTERNAL_SERVICE_ERROR,
            "External service error - " + serviceName + " at " + endpoint,
            true,
            cause
        ).addContext("serviceName", serviceName).addContext("endpoint", endpoint);
    }
    
    public static SystemException networkError(String details, Throwable cause) {
        return new SystemException(
            ErrorCode.NETWORK_ERROR,
            "Network error: " + details,
            true,
            cause
        ).addContext("details", details);
    }
    
    public static SystemException timeoutError(String operation, long timeoutMs) {
        return new SystemException(
            ErrorCode.TIMEOUT_ERROR,
            "Operation timeout: " + operation + " (timeout: " + timeoutMs + "ms)",
            true,
            null
        ).addContext("operation", operation).addContext("timeoutMs", timeoutMs);
    }

    // Override methods to return SystemException for method chaining

    @Override
    public SystemException addContext(String key, Object value) {
        super.addContext(key, value);
        return this;
    }

    @Override
    public SystemException setCorrelationId(String correlationId) {
        super.setCorrelationId(correlationId);
        return this;
    }
}
