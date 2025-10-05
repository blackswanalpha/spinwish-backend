# SpinWish Error Handling Guide

## Overview

The SpinWish backend implements a comprehensive error handling system that provides:
- Structured error responses with correlation IDs
- Detailed validation error messages
- Proper HTTP status codes
- Request/response logging and monitoring
- Retry mechanisms for transient errors

## Error Response Structure

All API errors return a standardized `ApiErrorResponse` with the following structure:

```json
{
  "status": 400,
  "errorCode": "VAL_001",
  "message": "Validation failed",
  "details": "Additional error details",
  "timestamp": "2024-01-15T10:30:00.000",
  "path": "/api/v1/users/signup",
  "method": "POST",
  "correlationId": "REQ-ABC12345",
  "sessionId": "session-123",
  "userId": "user@example.com",
  "errors": [
    {
      "field": "email",
      "rejectedValue": "invalid-email",
      "message": "Please enter a valid email address",
      "code": "INVALID_FORMAT"
    }
  ],
  "metadata": {},
  "suggestions": ["Check your email format"],
  "helpUrl": "https://docs.spinwish.com/errors/VAL_001",
  "retryable": false,
  "retryAfter": null
}
```

## Error Codes

### System Errors (SYS_001 - SYS_099)
- `SYS_001`: Internal server error occurred
- `SYS_002`: Service temporarily unavailable
- `SYS_003`: System configuration error
- `SYS_004`: Database connection failed
- `SYS_005`: External service error

### Authentication & Authorization (AUTH_001 - AUTH_099)
- `AUTH_001`: Invalid username or password
- `AUTH_002`: Authentication token has expired
- `AUTH_003`: Invalid authentication token
- `AUTH_004`: Access denied - insufficient permissions
- `AUTH_005`: Account is locked
- `AUTH_006`: Account is disabled
- `AUTH_007`: Session has expired
- `AUTH_008`: Unauthorized access attempt

### User Management (USER_001 - USER_099)
- `USER_001`: User not found
- `USER_002`: User already exists
- `USER_003`: Email address already registered
- `USER_004`: Phone number already registered
- `USER_005`: Invalid user data provided
- `USER_006`: Password does not meet security requirements
- `USER_007`: Email address not verified
- `USER_008`: Phone number not verified
- `USER_009`: User profile not found
- `USER_010`: User role not found

### Validation Errors (VAL_001 - VAL_099)
- `VAL_001`: Input validation failed
- `VAL_002`: Required field is missing
- `VAL_003`: Invalid email format
- `VAL_004`: Invalid phone number format
- `VAL_005`: Invalid date format
- `VAL_006`: Value is out of acceptable range
- `VAL_007`: Invalid file type
- `VAL_008`: File size exceeds maximum limit
- `VAL_009`: Duplicate value not allowed

### Business Logic (BIZ_001 - BIZ_099)
- `BIZ_001`: Artist not found
- `BIZ_002`: Artist already exists
- `BIZ_003`: Song not found
- `BIZ_004`: Playlist not found
- `BIZ_005`: Playback creation failed
- `BIZ_006`: Insufficient permissions for this operation
- `BIZ_007`: Operation not allowed in current state
- `BIZ_008`: Resource conflict detected

### Payment Errors (PAY_001 - PAY_099)
- `PAY_001`: Payment processing failed
- `PAY_002`: Insufficient funds
- `PAY_003`: Invalid payment method
- `PAY_004`: Transaction not found
- `PAY_005`: Payment processing timeout
- `PAY_006`: Refund processing failed
- `PAY_007`: M-Pesa service error

## Exception Hierarchy

### BaseException
All custom exceptions extend `BaseException` which provides:
- Error code association
- Context information
- Retry capability indication
- User-friendly messages
- Correlation ID tracking

### Specific Exception Types

#### BusinessException
For business logic violations:
```java
throw BusinessException.artistNotFound("artist-123");
throw BusinessException.insufficientPermissions("delete_artist", "user-456");
```

#### ValidationException
For validation errors:
```java
ValidationException ex = ValidationException.requiredField("email");
ex.addFieldError("password", null, "Password is required", "REQUIRED");
throw ex;
```

#### AuthenticationException
For authentication/authorization errors:
```java
throw AuthenticationException.tokenExpired();
throw AuthenticationException.accessDenied("/admin/users");
```

#### SystemException
For system-level errors:
```java
throw SystemException.databaseConnectionError("Connection timeout", cause);
throw SystemException.externalServiceError("PaymentService", "/api/charge", cause);
```

## Validation

### Built-in Validators

#### Email Validation (`@ValidEmail`)
```java
@ValidEmail
private String emailAddress;
```
Validates:
- Email format (RFC compliant)
- Maximum length (254 characters)
- Local part length (64 characters)
- No consecutive dots

#### Password Validation (`@ValidPassword`)
```java
@ValidPassword
private String password;
```
Validates:
- Minimum 8 characters, maximum 128
- At least one uppercase letter
- At least one lowercase letter
- At least one digit
- At least one special character (@$!%*?&)
- Not a common password
- No sequential characters

### Standard Validation Annotations
```java
@NotBlank(message = "Username is required")
@Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
@Pattern(regexp = "^[a-zA-Z0-9_-]+$", message = "Username can only contain letters, numbers, underscores, and hyphens")
private String username;
```

## Correlation ID Tracking

Every request gets a unique correlation ID for tracking:
- Generated automatically if not provided
- Included in all log messages
- Returned in response headers
- Used for distributed tracing

### Headers
- `X-Correlation-ID`: Primary correlation ID header
- `X-Request-ID`: Alternative request ID header

## Logging

### Log Levels
- **ERROR**: Server errors, system failures
- **WARN**: Client errors, business rule violations
- **INFO**: Normal operations, authentication events
- **DEBUG**: Detailed request/response information

### Log Format
```
2024-01-15 10:30:00.123 INFO [http-nio-8080-exec-1] c.s.b.e.GlobalExceptionHandler [REQ-ABC12345] : Client error - Path: /api/v1/users/signup, Error: Email already registered
```

### Structured Logging
JSON format for production environments:
```json
{
  "timestamp": "2024-01-15T10:30:00.123Z",
  "level": "ERROR",
  "logger": "com.spinwish.backend.exceptions.GlobalExceptionHandler",
  "message": "Server error occurred",
  "correlationId": "REQ-ABC12345",
  "userId": "user@example.com",
  "path": "/api/v1/artists",
  "method": "POST",
  "exception": "DatabaseConnectionException"
}
```

## Monitoring and Metrics

### Actuator Endpoints
- `/actuator/health`: Application health status
- `/actuator/metrics`: Application metrics
- `/actuator/prometheus`: Prometheus metrics

### Custom Metrics
- Error count by type
- Response time percentiles
- Active correlation IDs
- Retry attempts

## Best Practices

### For Developers

1. **Use Specific Exceptions**
   ```java
   // Good
   throw BusinessException.artistNotFound(artistId);
   
   // Avoid
   throw new RuntimeException("Artist not found");
   ```

2. **Add Context Information**
   ```java
   throw BusinessException.playbackFailed("Insufficient credits")
       .addContext("userId", userId)
       .addContext("songId", songId);
   ```

3. **Use Validation Annotations**
   ```java
   @Valid @RequestBody RegisterRequest request
   ```

4. **Handle Async Operations**
   ```java
   try {
       return paymentService.processPayment(request);
   } catch (PaymentException e) {
       throw SystemException.externalServiceError("PaymentService", "/charge", e);
   }
   ```

### For API Consumers

1. **Check Error Codes**: Use `errorCode` field for programmatic handling
2. **Use Correlation IDs**: Include in support requests
3. **Handle Retryable Errors**: Check `retryable` field and `retryAfter` delay
4. **Parse Validation Errors**: Use `errors` array for field-specific messages

## Troubleshooting

### Common Issues

1. **Validation Errors Not Showing**
   - Ensure `@Valid` annotation is present
   - Check controller method parameters

2. **Missing Correlation IDs**
   - Verify interceptor is registered
   - Check request path patterns

3. **Logs Not Structured**
   - Verify logback-spring.xml configuration
   - Check active Spring profile

### Debug Mode
Enable debug logging:
```properties
logging.level.com.spinwish.backend=DEBUG
logging.level.com.spinwish.backend.interceptors=TRACE
```

## Configuration

### Application Properties
```properties
# Error handling
error.handling.include-stacktrace=false
error.handling.include-message=true
error.handling.log-client-errors=true

# Validation
spring.mvc.throw-exception-if-no-handler-found=true
spring.web.resources.add-mappings=false

# File upload limits
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
```

### Environment-Specific Settings

#### Development
- Detailed error messages
- Stack traces included
- Debug logging enabled

#### Production
- Generic error messages
- No stack traces
- Structured JSON logging
- Metrics collection enabled
