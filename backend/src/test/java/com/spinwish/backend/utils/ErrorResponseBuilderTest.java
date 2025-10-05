package com.spinwish.backend.utils;

import com.spinwish.backend.enums.ErrorCode;
import com.spinwish.backend.exceptions.BusinessException;
import com.spinwish.backend.exceptions.ValidationException;
import com.spinwish.backend.models.responses.errors.ApiErrorResponse;
import com.spinwish.backend.models.responses.errors.ErrorDetail;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.validation.BeanPropertyBindingResult;
import org.springframework.validation.FieldError;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class ErrorResponseBuilderTest {

    private MockHttpServletRequest request;

    @BeforeEach
    void setUp() {
        request = new MockHttpServletRequest();
        request.setRequestURI("/api/v1/test");
        request.setMethod("POST");
        
        // Clear any existing context
        ErrorContextHolder.clear();
    }

    @Test
    void fromException_WithBusinessException_ShouldCreateCorrectResponse() {
        // Given
        BusinessException exception = BusinessException.artistNotFound("123");
        
        // When
        ApiErrorResponse response = ErrorResponseBuilder.fromException(exception, request);
        
        // Then
        assertNotNull(response);
        assertEquals(HttpStatus.NOT_FOUND.value(), response.getStatus());
        assertEquals(ErrorCode.ARTIST_NOT_FOUND.getCode(), response.getErrorCode());
        assertEquals("The requested artist could not be found", response.getMessage());
        assertEquals("Artist not found with ID: 123", response.getDetails());
        assertEquals("/api/v1/test", response.getPath());
        assertEquals("POST", response.getMethod());
        assertNotNull(response.getCorrelationId());
        assertNotNull(response.getTimestamp());
        assertFalse(response.getRetryable());
    }

    @Test
    void fromException_WithValidationException_ShouldIncludeValidationErrors() {
        // Given
        ValidationException exception = ValidationException.invalidEmail("invalid-email")
                .addFieldError("password", "", "Password is required", "REQUIRED");
        
        // When
        ApiErrorResponse response = ErrorResponseBuilder.fromException(exception, request);
        
        // Then
        assertNotNull(response);
        assertEquals(HttpStatus.BAD_REQUEST.value(), response.getStatus());
        assertEquals(ErrorCode.VALIDATION_FAILED.getCode(), response.getErrorCode());
        assertNotNull(response.getErrors());
        assertEquals(2, response.getErrors().size());
        
        // Check validation errors
        ErrorDetail emailError = response.getErrors().stream()
                .filter(error -> "email".equals(error.getField()))
                .findFirst()
                .orElse(null);
        assertNotNull(emailError);
        assertEquals("invalid-email", emailError.getRejectedValue());
        assertEquals("Please enter a valid email address", emailError.getMessage());
    }

    @Test
    void fromBindingResult_ShouldCreateValidationResponse() {
        // Given
        BeanPropertyBindingResult bindingResult = new BeanPropertyBindingResult(new Object(), "testObject");
        bindingResult.addError(new FieldError("testObject", "email", "invalid-email", false, null, null, "Invalid email format"));
        bindingResult.addError(new FieldError("testObject", "password", "", false, null, null, "Password is required"));
        
        // When
        ApiErrorResponse response = ErrorResponseBuilder.fromBindingResult(bindingResult, request);
        
        // Then
        assertNotNull(response);
        assertEquals(HttpStatus.BAD_REQUEST.value(), response.getStatus());
        assertEquals(ErrorCode.VALIDATION_FAILED.getCode(), response.getErrorCode());
        assertEquals("Validation failed", response.getMessage());
        assertNotNull(response.getErrors());
        assertEquals(2, response.getErrors().size());
        assertEquals("/api/v1/test", response.getPath());
        assertEquals("POST", response.getMethod());
    }

    @Test
    void generic_ShouldCreateGenericErrorResponse() {
        // Given
        HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
        ErrorCode errorCode = ErrorCode.INTERNAL_SERVER_ERROR;
        String message = "Something went wrong";
        
        // When
        ApiErrorResponse response = ErrorResponseBuilder.generic(status, errorCode, message, request);
        
        // Then
        assertNotNull(response);
        assertEquals(status.value(), response.getStatus());
        assertEquals(errorCode.getCode(), response.getErrorCode());
        assertEquals(message, response.getMessage());
        assertEquals("/api/v1/test", response.getPath());
        assertEquals("POST", response.getMethod());
        assertNotNull(response.getCorrelationId());
    }

    @Test
    void generic_WithNullMessage_ShouldUseDefaultMessage() {
        // Given
        HttpStatus status = HttpStatus.BAD_REQUEST;
        ErrorCode errorCode = ErrorCode.VALIDATION_FAILED;
        
        // When
        ApiErrorResponse response = ErrorResponseBuilder.generic(status, errorCode, null, request);
        
        // Then
        assertNotNull(response);
        assertEquals(errorCode.getDefaultMessage(), response.getMessage());
    }

    @Test
    void fromException_WithExistingCorrelationId_ShouldUseExistingId() {
        // Given
        String existingCorrelationId = "existing-correlation-id";
        ErrorContextHolder.setCorrelationId(existingCorrelationId);
        BusinessException exception = BusinessException.artistNotFound("123");
        
        // When
        ApiErrorResponse response = ErrorResponseBuilder.fromException(exception, request);
        
        // Then
        assertEquals(existingCorrelationId, response.getCorrelationId());
    }

    @Test
    void fromException_WithNullRequest_ShouldNotIncludeRequestInfo() {
        // Given
        BusinessException exception = BusinessException.artistNotFound("123");
        
        // When
        ApiErrorResponse response = ErrorResponseBuilder.fromException(exception, null);
        
        // Then
        assertNotNull(response);
        assertNull(response.getPath());
        assertNull(response.getMethod());
    }

    @Test
    void fromException_WithContextInformation_ShouldIncludeContext() {
        // Given
        String userId = "user123";
        String sessionId = "session456";
        ErrorContextHolder.setUserId(userId);
        ErrorContextHolder.setSessionId(sessionId);
        ErrorContextHolder.addMetadata("key", "value");
        
        BusinessException exception = BusinessException.artistNotFound("123");
        
        // When
        ApiErrorResponse response = ErrorResponseBuilder.fromException(exception, request);
        
        // Then
        assertEquals(userId, response.getUserId());
        assertEquals(sessionId, response.getSessionId());
        assertNotNull(response.getMetadata());
        assertEquals("value", response.getMetadata().get("key"));
    }

    @Test
    void httpStatusDetermination_ShouldMapCorrectly() {
        // Test authentication errors
        BusinessException authException = new BusinessException(ErrorCode.INVALID_CREDENTIALS, "Invalid credentials");
        ApiErrorResponse authResponse = ErrorResponseBuilder.fromException(authException, request);
        assertEquals(HttpStatus.UNAUTHORIZED.value(), authResponse.getStatus());
        
        // Test validation errors
        ValidationException validationException = ValidationException.requiredField("email");
        ApiErrorResponse validationResponse = ErrorResponseBuilder.fromException(validationException, request);
        assertEquals(HttpStatus.BAD_REQUEST.value(), validationResponse.getStatus());
        
        // Test not found errors
        BusinessException notFoundException = BusinessException.artistNotFound("123");
        ApiErrorResponse notFoundResponse = ErrorResponseBuilder.fromException(notFoundException, request);
        assertEquals(HttpStatus.NOT_FOUND.value(), notFoundResponse.getStatus());
        
        // Test conflict errors
        BusinessException conflictException = BusinessException.artistAlreadyExists("Test Artist");
        ApiErrorResponse conflictResponse = ErrorResponseBuilder.fromException(conflictException, request);
        assertEquals(HttpStatus.CONFLICT.value(), conflictResponse.getStatus());
    }

    @Test
    void retryInformation_ShouldBeSetCorrectly() {
        // Test retryable system exception
        com.spinwish.backend.exceptions.SystemException systemException = 
            new com.spinwish.backend.exceptions.SystemException(
                ErrorCode.NETWORK_ERROR, 
                "Network error", 
                "Please try again", 
                true
            );
        
        ApiErrorResponse response = ErrorResponseBuilder.fromException(systemException, request);
        assertTrue(response.getRetryable());
        assertNotNull(response.getRetryAfter());
        
        // Test non-retryable exception
        BusinessException businessException = BusinessException.artistNotFound("123");
        ApiErrorResponse businessResponse = ErrorResponseBuilder.fromException(businessException, request);
        assertFalse(businessResponse.getRetryable());
    }
}
