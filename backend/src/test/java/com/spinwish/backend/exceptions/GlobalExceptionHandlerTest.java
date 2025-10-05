package com.spinwish.backend.exceptions;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.spinwish.backend.enums.ErrorCode;
import com.spinwish.backend.models.responses.errors.ApiErrorResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.validation.BeanPropertyBindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GlobalExceptionHandlerTest {

    @InjectMocks
    private GlobalExceptionHandler globalExceptionHandler;

    private MockHttpServletRequest request;

    @BeforeEach
    void setUp() {
        request = new MockHttpServletRequest();
        request.setRequestURI("/api/v1/test");
        request.setMethod("POST");
    }

    @Test
    void handleBaseException_ShouldReturnCorrectErrorResponse() {
        // Given
        BusinessException exception = BusinessException.artistNotFound("123");
        
        // When
        ResponseEntity<ApiErrorResponse> response = globalExceptionHandler.handleBaseException(exception, request);
        
        // Then
        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(ErrorCode.ARTIST_NOT_FOUND.getCode(), response.getBody().getErrorCode());
        assertEquals("/api/v1/test", response.getBody().getPath());
        assertEquals("POST", response.getBody().getMethod());
        assertNotNull(response.getBody().getCorrelationId());
    }

    @Test
    void handleValidationException_ShouldReturnBadRequest() {
        // Given
        Object target = new Object();
        BeanPropertyBindingResult bindingResult = new BeanPropertyBindingResult(target, "testObject");
        bindingResult.addError(new FieldError("testObject", "email", "Invalid email format"));
        bindingResult.addError(new FieldError("testObject", "password", "Password too weak"));
        
        MethodArgumentNotValidException exception = new MethodArgumentNotValidException(null, bindingResult);
        
        // When
        ResponseEntity<ApiErrorResponse> response = globalExceptionHandler.handleValidationException(exception, request);
        
        // Then
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(ErrorCode.VALIDATION_FAILED.getCode(), response.getBody().getErrorCode());
        assertEquals(2, response.getBody().getErrors().size());
    }

    @Test
    void handleBadCredentialsException_ShouldReturnUnauthorized() {
        // Given
        BadCredentialsException exception = new BadCredentialsException("Invalid credentials");
        
        // When
        ResponseEntity<ApiErrorResponse> response = globalExceptionHandler.handleBadCredentialsException(exception, request);
        
        // Then
        assertEquals(HttpStatus.UNAUTHORIZED, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(ErrorCode.INVALID_CREDENTIALS.getCode(), response.getBody().getErrorCode());
        assertEquals("Invalid username or password", response.getBody().getMessage());
    }

    @Test
    void handleAccessDeniedException_ShouldReturnForbidden() {
        // Given
        AccessDeniedException exception = new AccessDeniedException("Access denied");
        
        // When
        ResponseEntity<ApiErrorResponse> response = globalExceptionHandler.handleAccessDeniedException(exception, request);
        
        // Then
        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(ErrorCode.ACCESS_DENIED.getCode(), response.getBody().getErrorCode());
    }

    @Test
    void handleGenericException_ShouldReturnInternalServerError() {
        // Given
        RuntimeException exception = new RuntimeException("Unexpected error");
        
        // When
        ResponseEntity<ApiErrorResponse> response = globalExceptionHandler.handleGenericException(exception, request);
        
        // Then
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(ErrorCode.INTERNAL_SERVER_ERROR.getCode(), response.getBody().getErrorCode());
        assertTrue(response.getBody().getRetryable());
        assertNotNull(response.getBody().getRetryAfter());
    }

    @Test
    void handleAuthenticationException_ShouldIncludeCorrelationId() {
        // Given
        AuthenticationException exception = AuthenticationException.tokenExpired();
        
        // When
        ResponseEntity<ApiErrorResponse> response = globalExceptionHandler.handleBaseException(exception, request);
        
        // Then
        assertEquals(HttpStatus.UNAUTHORIZED, response.getStatusCode());
        assertNotNull(response.getBody());
        assertNotNull(response.getBody().getCorrelationId());
        assertEquals(ErrorCode.TOKEN_EXPIRED.getCode(), response.getBody().getErrorCode());
    }

    @Test
    void handleValidationException_WithCustomValidationException_ShouldReturnDetailedErrors() {
        // Given
        ValidationException exception = ValidationException.requiredField("email");
        exception.addFieldError("password", null, "Password is required", "REQUIRED");
        
        // When
        ResponseEntity<ApiErrorResponse> response = globalExceptionHandler.handleBaseException(exception, request);
        
        // Then
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(ErrorCode.VALIDATION_FAILED.getCode(), response.getBody().getErrorCode());
        assertEquals(2, response.getBody().getErrors().size());
    }

    @Test
    void handleSystemException_ShouldBeRetryable() {
        // Given
        SystemException exception = SystemException.databaseConnectionError("Connection timeout", null);
        
        // When
        ResponseEntity<ApiErrorResponse> response = globalExceptionHandler.handleBaseException(exception, request);
        
        // Then
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().getRetryable());
        assertNotNull(response.getBody().getRetryAfter());
    }
}
