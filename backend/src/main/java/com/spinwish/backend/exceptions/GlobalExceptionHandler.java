package com.spinwish.backend.exceptions;

import com.spinwish.backend.enums.ErrorCode;
import com.spinwish.backend.models.responses.errors.ApiErrorResponse;
import com.spinwish.backend.models.responses.errors.ErrorDetail;
import com.spinwish.backend.models.responses.errors.ErrorsResponse;
import com.spinwish.backend.monitoring.ErrorMetrics;
import com.spinwish.backend.utils.ErrorContextHolder;
import com.spinwish.backend.utils.ErrorResponseBuilder;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.validation.BindException;
import org.springframework.validation.BindingResult;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.servlet.NoHandlerFoundException;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeoutException;

/**
 * Enhanced Global Exception Handler with comprehensive error handling,
 * structured logging, and detailed error responses
 */
@ControllerAdvice
@Slf4j
@RequiredArgsConstructor
public class GlobalExceptionHandler {

    private final ErrorMetrics errorMetrics;

    // Handle custom base exceptions
    @ExceptionHandler(BaseException.class)
    public ResponseEntity<ApiErrorResponse> handleBaseException(BaseException ex, HttpServletRequest request) {
        logException(ex, request);
        ApiErrorResponse errorResponse = ErrorResponseBuilder.fromException(ex, request);
        HttpStatus status = HttpStatus.valueOf(errorResponse.getStatus());

        // Record error metrics
        errorMetrics.recordError(ex.getErrorCode(), request.getRequestURI(), status.value());

        return new ResponseEntity<>(errorResponse, status);
    }

    // Handle validation errors
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiErrorResponse> handleValidationException(MethodArgumentNotValidException ex,
                                                                     HttpServletRequest request) {
        logException(ex, request);
        ApiErrorResponse errorResponse = ErrorResponseBuilder.fromBindingResult(ex.getBindingResult(), request);
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(BindException.class)
    public ResponseEntity<ApiErrorResponse> handleBindException(BindException ex, HttpServletRequest request) {
        logException(ex, request);
        ApiErrorResponse errorResponse = ErrorResponseBuilder.fromBindingResult(ex.getBindingResult(), request);
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ApiErrorResponse> handleConstraintViolationException(ConstraintViolationException ex,
                                                                              HttpServletRequest request) {
        logException(ex, request);

        List<ErrorDetail> errors = new ArrayList<>();
        for (ConstraintViolation<?> violation : ex.getConstraintViolations()) {
            errors.add(ErrorDetail.fieldError(
                violation.getPropertyPath().toString(),
                violation.getInvalidValue(),
                violation.getMessage(),
                "CONSTRAINT_VIOLATION"
            ));
        }

        ApiErrorResponse errorResponse = ApiErrorResponse.validation(
            HttpStatus.BAD_REQUEST.value(),
            "Constraint validation failed",
            errors,
            request.getRequestURI(),
            request.getMethod(),
            ErrorContextHolder.getCorrelationId()
        );

        // Record error metrics
        errorMetrics.recordError(ErrorCode.CONSTRAINT_VIOLATION, request.getRequestURI(), HttpStatus.BAD_REQUEST.value());

        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    // Handle Spring Security exceptions
    @ExceptionHandler(UsernameNotFoundException.class)
    public ResponseEntity<ApiErrorResponse> handleUsernameNotFoundException(UsernameNotFoundException ex,
                                                                           HttpServletRequest request) {
        logException(ex, request);
        ApiErrorResponse errorResponse = ErrorResponseBuilder.generic(
            HttpStatus.UNAUTHORIZED,
            ErrorCode.INVALID_CREDENTIALS,
            "Invalid username or password",
            request
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.UNAUTHORIZED);
    }

    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<ApiErrorResponse> handleBadCredentialsException(BadCredentialsException ex,
                                                                         HttpServletRequest request) {
        logException(ex, request);
        ApiErrorResponse errorResponse = ErrorResponseBuilder.generic(
            HttpStatus.UNAUTHORIZED,
            ErrorCode.INVALID_CREDENTIALS,
            "Invalid username or password",
            request
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.UNAUTHORIZED);
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ApiErrorResponse> handleAccessDeniedException(AccessDeniedException ex,
                                                                       HttpServletRequest request) {
        logException(ex, request);
        ApiErrorResponse errorResponse = ErrorResponseBuilder.generic(
            HttpStatus.FORBIDDEN,
            ErrorCode.ACCESS_DENIED,
            "Access denied",
            request
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.FORBIDDEN);
    }

    // Handle HTTP-related exceptions
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ApiErrorResponse> handleMethodNotSupportedException(HttpRequestMethodNotSupportedException ex,
                                                                             HttpServletRequest request) {
        logException(ex, request);
        ApiErrorResponse errorResponse = ErrorResponseBuilder.generic(
            HttpStatus.METHOD_NOT_ALLOWED,
            ErrorCode.VALIDATION_FAILED,
            "HTTP method not supported: " + ex.getMethod(),
            request
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.METHOD_NOT_ALLOWED);
    }

    @ExceptionHandler(HttpMediaTypeNotSupportedException.class)
    public ResponseEntity<ApiErrorResponse> handleMediaTypeNotSupportedException(HttpMediaTypeNotSupportedException ex,
                                                                                HttpServletRequest request) {
        logException(ex, request);
        ApiErrorResponse errorResponse = ErrorResponseBuilder.generic(
            HttpStatus.UNSUPPORTED_MEDIA_TYPE,
            ErrorCode.VALIDATION_FAILED,
            "Media type not supported: " + ex.getContentType(),
            request
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.UNSUPPORTED_MEDIA_TYPE);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ApiErrorResponse> handleMessageNotReadableException(HttpMessageNotReadableException ex,
                                                                             HttpServletRequest request) {
        logException(ex, request);
        ApiErrorResponse errorResponse = ErrorResponseBuilder.generic(
            HttpStatus.BAD_REQUEST,
            ErrorCode.VALIDATION_FAILED,
            "Malformed JSON request",
            request
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<ApiErrorResponse> handleMissingParameterException(MissingServletRequestParameterException ex,
                                                                           HttpServletRequest request) {
        logException(ex, request);
        ApiErrorResponse errorResponse = ErrorResponseBuilder.generic(
            HttpStatus.BAD_REQUEST,
            ErrorCode.REQUIRED_FIELD_MISSING,
            "Required parameter missing: " + ex.getParameterName(),
            request
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ApiErrorResponse> handleTypeMismatchException(MethodArgumentTypeMismatchException ex,
                                                                       HttpServletRequest request) {
        logException(ex, request);
        ApiErrorResponse errorResponse = ErrorResponseBuilder.generic(
            HttpStatus.BAD_REQUEST,
            ErrorCode.VALIDATION_FAILED,
            "Invalid parameter type for: " + ex.getName(),
            request
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    // Handle file upload exceptions
    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<ApiErrorResponse> handleMaxUploadSizeException(MaxUploadSizeExceededException ex,
                                                                        HttpServletRequest request) {
        logException(ex, request);
        ApiErrorResponse errorResponse = ErrorResponseBuilder.generic(
            HttpStatus.PAYLOAD_TOO_LARGE,
            ErrorCode.FILE_SIZE_EXCEEDED,
            "File size exceeds maximum allowed size",
            request
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.PAYLOAD_TOO_LARGE);
    }

    // Handle database exceptions
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ApiErrorResponse> handleDataIntegrityViolationException(DataIntegrityViolationException ex,
                                                                                 HttpServletRequest request) {
        logException(ex, request);

        String message = "Data integrity violation";
        ErrorCode errorCode = ErrorCode.CONSTRAINT_VIOLATION;

        // Try to determine specific constraint violation
        if (ex.getMessage() != null) {
            String lowerMessage = ex.getMessage().toLowerCase();
            if (lowerMessage.contains("unique") || lowerMessage.contains("duplicate")) {
                errorCode = ErrorCode.UNIQUE_CONSTRAINT_VIOLATION;
                message = "Duplicate value detected";
            } else if (lowerMessage.contains("foreign key")) {
                errorCode = ErrorCode.FOREIGN_KEY_VIOLATION;
                message = "Referenced record not found";
            }
        }

        ApiErrorResponse errorResponse = ErrorResponseBuilder.generic(
            HttpStatus.CONFLICT,
            errorCode,
            message,
            request
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.CONFLICT);
    }

    @ExceptionHandler(SQLException.class)
    public ResponseEntity<ApiErrorResponse> handleSQLException(SQLException ex, HttpServletRequest request) {
        logException(ex, request);
        ApiErrorResponse errorResponse = ErrorResponseBuilder.generic(
            HttpStatus.INTERNAL_SERVER_ERROR,
            ErrorCode.DATABASE_CONNECTION_ERROR,
            "Database operation failed",
            request
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    // Handle timeout exceptions
    @ExceptionHandler(TimeoutException.class)
    public ResponseEntity<ApiErrorResponse> handleTimeoutException(TimeoutException ex, HttpServletRequest request) {
        logException(ex, request);
        ApiErrorResponse errorResponse = ErrorResponseBuilder.generic(
            HttpStatus.REQUEST_TIMEOUT,
            ErrorCode.TIMEOUT_ERROR,
            "Request timeout",
            request
        ).setRetryInfo(true, 5000L);
        return new ResponseEntity<>(errorResponse, HttpStatus.REQUEST_TIMEOUT);
    }

    // Handle 404 errors
    @ExceptionHandler(NoHandlerFoundException.class)
    public ResponseEntity<ApiErrorResponse> handleNoHandlerFoundException(NoHandlerFoundException ex,
                                                                         HttpServletRequest request) {
        logException(ex, request);
        ApiErrorResponse errorResponse = ErrorResponseBuilder.generic(
            HttpStatus.NOT_FOUND,
            ErrorCode.VALIDATION_FAILED,
            "Endpoint not found: " + ex.getRequestURL(),
            request
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.NOT_FOUND);
    }

    // Handle generic exceptions (fallback)
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiErrorResponse> handleGenericException(Exception ex, HttpServletRequest request) {
        logException(ex, request);

        // Don't expose internal error details in production
        String message = "An unexpected error occurred";
        if (log.isDebugEnabled()) {
            message = ex.getMessage();
        }

        ApiErrorResponse errorResponse = ErrorResponseBuilder.generic(
            HttpStatus.INTERNAL_SERVER_ERROR,
            ErrorCode.INTERNAL_SERVER_ERROR,
            message,
            request
        ).setRetryInfo(true, 30000L);

        return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    // Legacy exception handlers for backward compatibility
    @ExceptionHandler(UnauthorizedException.class)
    public ResponseEntity<ApiErrorResponse> handleUnauthorizedException(UnauthorizedException ex,
                                                                       HttpServletRequest request) {
        return handleBaseException(ex, request);
    }

    @ExceptionHandler(UserAlreadyExistsException.class)
    public ResponseEntity<ApiErrorResponse> handleUserAlreadyExistsException(UserAlreadyExistsException ex,
                                                                            HttpServletRequest request) {
        return handleBaseException(ex, request);
    }

    @ExceptionHandler(UserNotExistingException.class)
    public ResponseEntity<ApiErrorResponse> handleUserNotExistingException(UserNotExistingException ex,
                                                                          HttpServletRequest request) {
        return handleBaseException(ex, request);
    }

    @ExceptionHandler(PlaySongException.class)
    public ResponseEntity<ApiErrorResponse> handlePlaySongException(PlaySongException ex,
                                                                   HttpServletRequest request) {
        return handleBaseException(ex, request);
    }

    /**
     * Log exception with context information
     */
    private void logException(Exception ex, HttpServletRequest request) {
        String correlationId = ErrorContextHolder.getCorrelationId();
        String userId = ErrorContextHolder.getUserId();

        if (ex instanceof BaseException) {
            BaseException baseEx = (BaseException) ex;
            if (baseEx.isClientError()) {
                log.warn("Client error - CorrelationId: {}, UserId: {}, Path: {}, Error: {}",
                        correlationId, userId, request.getRequestURI(), ex.getMessage());
            } else {
                log.error("Server error - CorrelationId: {}, UserId: {}, Path: {}, Error: {}",
                        correlationId, userId, request.getRequestURI(), ex.getMessage(), ex);
            }
        } else if (isClientError(ex)) {
            log.warn("Client error - CorrelationId: {}, UserId: {}, Path: {}, Error: {}",
                    correlationId, userId, request.getRequestURI(), ex.getMessage());
        } else {
            log.error("Server error - CorrelationId: {}, UserId: {}, Path: {}, Error: {}",
                    correlationId, userId, request.getRequestURI(), ex.getMessage(), ex);
        }
    }

    /**
     * Determine if exception represents a client error
     */
    private boolean isClientError(Exception ex) {
        return ex instanceof MethodArgumentNotValidException ||
               ex instanceof BindException ||
               ex instanceof ConstraintViolationException ||
               ex instanceof HttpRequestMethodNotSupportedException ||
               ex instanceof HttpMediaTypeNotSupportedException ||
               ex instanceof HttpMessageNotReadableException ||
               ex instanceof MissingServletRequestParameterException ||
               ex instanceof MethodArgumentTypeMismatchException ||
               ex instanceof MaxUploadSizeExceededException ||
               ex instanceof NoHandlerFoundException ||
               ex instanceof BadCredentialsException ||
               ex instanceof UsernameNotFoundException;
    }
}
