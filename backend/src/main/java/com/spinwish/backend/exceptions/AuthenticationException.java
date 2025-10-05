package com.spinwish.backend.exceptions;

import com.spinwish.backend.enums.ErrorCode;

/**
 * Exception for authentication and authorization related errors
 */
public class AuthenticationException extends BaseException {
    
    public AuthenticationException(ErrorCode errorCode, String message) {
        super(errorCode, message);
    }
    
    public AuthenticationException(ErrorCode errorCode, String message, Throwable cause) {
        super(errorCode, message, cause);
    }
    
    public AuthenticationException(ErrorCode errorCode, String message, String userMessage) {
        super(errorCode, message, userMessage, false, null);
    }
    
    // Factory methods for common authentication scenarios
    
    public static AuthenticationException invalidCredentials() {
        return new AuthenticationException(
            ErrorCode.INVALID_CREDENTIALS,
            "Authentication failed - invalid credentials",
            "Invalid username or password"
        );
    }
    
    public static AuthenticationException tokenExpired() {
        return new AuthenticationException(
            ErrorCode.TOKEN_EXPIRED,
            "JWT token has expired",
            "Your session has expired. Please log in again"
        );
    }
    
    public static AuthenticationException tokenInvalid(String reason) {
        return new AuthenticationException(
            ErrorCode.TOKEN_INVALID,
            "Invalid JWT token: " + reason,
            "Invalid authentication token"
        ).addContext("reason", reason);
    }
    
    public static AuthenticationException accessDenied(String resource) {
        return new AuthenticationException(
            ErrorCode.ACCESS_DENIED,
            "Access denied to resource: " + resource,
            "You don't have permission to access this resource"
        ).addContext("resource", resource);
    }
    
    public static AuthenticationException accountLocked(String userId, String reason) {
        return new AuthenticationException(
            ErrorCode.ACCOUNT_LOCKED,
            "Account locked for user: " + userId + ", reason: " + reason,
            "Your account has been locked. Please contact support"
        ).addContext("userId", userId).addContext("reason", reason);
    }
    
    public static AuthenticationException accountDisabled(String userId) {
        return new AuthenticationException(
            ErrorCode.ACCOUNT_DISABLED,
            "Account disabled for user: " + userId,
            "Your account has been disabled. Please contact support"
        ).addContext("userId", userId);
    }
    
    public static AuthenticationException sessionExpired() {
        return new AuthenticationException(
            ErrorCode.SESSION_EXPIRED,
            "User session has expired",
            "Your session has expired. Please log in again"
        );
    }
    
    public static AuthenticationException unauthorizedAccess(String operation, String userId) {
        return new AuthenticationException(
            ErrorCode.UNAUTHORIZED_ACCESS,
            "Unauthorized access attempt by user " + userId + " for operation: " + operation,
            "You are not authorized to perform this action"
        ).addContext("operation", operation).addContext("userId", userId);
    }

    // Override methods to return AuthenticationException for method chaining

    @Override
    public AuthenticationException addContext(String key, Object value) {
        super.addContext(key, value);
        return this;
    }

    @Override
    public AuthenticationException setCorrelationId(String correlationId) {
        super.setCorrelationId(correlationId);
        return this;
    }
}
