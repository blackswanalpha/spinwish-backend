package com.spinwish.backend.utils;

import com.spinwish.backend.enums.ErrorCode;
import com.spinwish.backend.exceptions.BaseException;
import com.spinwish.backend.exceptions.ValidationException;
import com.spinwish.backend.models.responses.errors.ApiErrorResponse;
import com.spinwish.backend.models.responses.errors.ErrorDetail;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.validation.ObjectError;

import java.util.ArrayList;
import java.util.List;

/**
 * Utility class for building standardized error responses
 */
public class ErrorResponseBuilder {
    
    /**
     * Build error response from BaseException
     */
    public static ApiErrorResponse fromException(BaseException exception, HttpServletRequest request) {
        String correlationId = ErrorContextHolder.getCorrelationId();
        if (correlationId == null) {
            correlationId = CorrelationIdGenerator.generateShort();
            ErrorContextHolder.setCorrelationId(correlationId);
        }
        
        HttpStatus status = determineHttpStatus(exception);
        
        ApiErrorResponse.ApiErrorResponseBuilder builder = ApiErrorResponse.builder()
                .status(status.value())
                .errorCode(exception.getErrorCode().getCode())
                .message(exception.getUserFriendlyMessage())
                .details(exception.getTechnicalMessage())
                .correlationId(correlationId)
                .userId(ErrorContextHolder.getUserId())
                .sessionId(ErrorContextHolder.getSessionId())
                .metadata(ErrorContextHolder.getMetadata());
        
        if (request != null) {
            builder.path(request.getRequestURI())
                   .method(request.getMethod());
        }
        
        // Add validation errors if present
        if (exception instanceof ValidationException) {
            ValidationException validationException = (ValidationException) exception;
            builder.errors(validationException.getValidationErrors());
        }
        
        // Set retry information
        builder.retryable(exception.isRetryable());
        if (exception.isRetryable()) {
            builder.retryAfter(calculateRetryDelay(exception));
        }
        
        return builder.build();
    }
    
    /**
     * Build error response from validation binding result
     */
    public static ApiErrorResponse fromBindingResult(BindingResult bindingResult, HttpServletRequest request) {
        String correlationId = ErrorContextHolder.getCorrelationId();
        if (correlationId == null) {
            correlationId = CorrelationIdGenerator.generateShort();
            ErrorContextHolder.setCorrelationId(correlationId);
        }
        
        List<ErrorDetail> errors = new ArrayList<>();
        
        // Process field errors
        for (FieldError fieldError : bindingResult.getFieldErrors()) {
            errors.add(ErrorDetail.fieldError(
                fieldError.getField(),
                fieldError.getRejectedValue(),
                fieldError.getDefaultMessage(),
                fieldError.getCode()
            ));
        }
        
        // Process global errors
        for (ObjectError objectError : bindingResult.getGlobalErrors()) {
            errors.add(ErrorDetail.generalError(
                objectError.getDefaultMessage(),
                objectError.getCode()
            ));
        }
        
        ApiErrorResponse.ApiErrorResponseBuilder builder = ApiErrorResponse.builder()
                .status(HttpStatus.BAD_REQUEST.value())
                .errorCode(ErrorCode.VALIDATION_FAILED.getCode())
                .message("Validation failed")
                .errors(errors)
                .correlationId(correlationId)
                .userId(ErrorContextHolder.getUserId())
                .sessionId(ErrorContextHolder.getSessionId());
        
        if (request != null) {
            builder.path(request.getRequestURI())
                   .method(request.getMethod());
        }
        
        return builder.build();
    }
    
    /**
     * Build generic error response
     */
    public static ApiErrorResponse generic(HttpStatus status, ErrorCode errorCode, String message, 
                                         HttpServletRequest request) {
        String correlationId = ErrorContextHolder.getCorrelationId();
        if (correlationId == null) {
            correlationId = CorrelationIdGenerator.generateShort();
            ErrorContextHolder.setCorrelationId(correlationId);
        }
        
        ApiErrorResponse.ApiErrorResponseBuilder builder = ApiErrorResponse.builder()
                .status(status.value())
                .errorCode(errorCode.getCode())
                .message(message != null ? message : errorCode.getDefaultMessage())
                .correlationId(correlationId)
                .userId(ErrorContextHolder.getUserId())
                .sessionId(ErrorContextHolder.getSessionId());
        
        if (request != null) {
            builder.path(request.getRequestURI())
                   .method(request.getMethod());
        }
        
        return builder.build();
    }
    
    /**
     * Determine HTTP status from exception
     */
    private static HttpStatus determineHttpStatus(BaseException exception) {
        ErrorCode errorCode = exception.getErrorCode();
        
        // Authentication and authorization errors
        if (errorCode.name().startsWith("AUTH_")) {
            if (errorCode == ErrorCode.ACCESS_DENIED || errorCode == ErrorCode.INSUFFICIENT_PERMISSIONS) {
                return HttpStatus.FORBIDDEN;
            }
            return HttpStatus.UNAUTHORIZED;
        }
        
        // Validation errors
        if (errorCode.name().startsWith("VAL_")) {
            return HttpStatus.BAD_REQUEST;
        }
        
        // User management errors
        if (errorCode.name().startsWith("USER_")) {
            if (errorCode == ErrorCode.USER_NOT_FOUND) {
                return HttpStatus.NOT_FOUND;
            }
            if (errorCode == ErrorCode.USER_ALREADY_EXISTS || 
                errorCode == ErrorCode.EMAIL_ALREADY_REGISTERED ||
                errorCode == ErrorCode.PHONE_ALREADY_REGISTERED) {
                return HttpStatus.CONFLICT;
            }
            return HttpStatus.BAD_REQUEST;
        }
        
        // Business logic errors
        if (errorCode.name().startsWith("BIZ_")) {
            if (errorCode.name().contains("NOT_FOUND")) {
                return HttpStatus.NOT_FOUND;
            }
            if (errorCode.name().contains("ALREADY_EXISTS") || errorCode == ErrorCode.RESOURCE_CONFLICT) {
                return HttpStatus.CONFLICT;
            }
            return HttpStatus.BAD_REQUEST;
        }
        
        // Rate limiting errors
        if (errorCode.name().startsWith("RATE_")) {
            return HttpStatus.TOO_MANY_REQUESTS;
        }
        
        // System errors
        return HttpStatus.INTERNAL_SERVER_ERROR;
    }
    
    /**
     * Calculate retry delay based on exception type
     */
    private static Long calculateRetryDelay(BaseException exception) {
        if (exception.getErrorCode().name().startsWith("RATE_")) {
            return 60000L; // 1 minute for rate limiting
        }
        if (exception.getErrorCode().name().startsWith("SYS_")) {
            return 30000L; // 30 seconds for system errors
        }
        return 5000L; // 5 seconds default
    }
}
