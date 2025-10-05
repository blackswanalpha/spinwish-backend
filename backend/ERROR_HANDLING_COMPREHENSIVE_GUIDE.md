# SpinWish Backend - Comprehensive Error Handling System

## 🎯 Overview

The SpinWish backend implements a comprehensive, production-ready error handling system that provides:

- **Structured Error Responses** with correlation IDs and detailed context
- **Comprehensive Error Codes** covering all application domains
- **Advanced Monitoring & Metrics** with real-time error tracking
- **Robust Validation System** with field-level error details
- **Request/Response Tracking** with correlation ID propagation
- **Health Monitoring** with custom health indicators
- **Structured Logging** with correlation ID integration

## 🏗️ Architecture Components

### 1. Error Code System (`ErrorCode.java`)

Comprehensive error codes organized by domain:

```java
// Authentication & Authorization (AUTH_*)
INVALID_CREDENTIALS("AUTH_001", "Invalid username or password")
TOKEN_EXPIRED("AUTH_002", "Authentication token has expired")
ACCESS_DENIED("AUTH_004", "Access denied - insufficient permissions")

// User Management (USER_*)
USER_NOT_FOUND("USER_001", "User not found")
EMAIL_ALREADY_REGISTERED("USER_003", "Email address already registered")

// Validation (VAL_*)
VALIDATION_FAILED("VAL_001", "Input validation failed")
INVALID_EMAIL_FORMAT("VAL_003", "Invalid email format")

// Business Logic (BIZ_*)
ARTIST_NOT_FOUND("BIZ_001", "Artist not found")
PLAYBACK_FAILED("BIZ_005", "Playback creation failed")

// Payment (PAY_*)
PAYMENT_FAILED("PAY_001", "Payment processing failed")
MPESA_ERROR("PAY_006", "M-Pesa service error")
```

### 2. Exception Hierarchy

```
BaseException (abstract)
├── BusinessException (domain logic errors)
├── ValidationException (validation errors with field details)
├── AuthenticationException (auth/authz errors)
└── SystemException (infrastructure errors)
```

### 3. Error Response Structure

```json
{
  "status": 400,
  "errorCode": "VAL_003",
  "message": "Please enter a valid email address",
  "details": "Email validation failed for: invalid@email",
  "timestamp": "2024-01-15T10:30:00.000",
  "path": "/api/v1/users/signup",
  "method": "POST",
  "correlationId": "REQ-ABC12345",
  "userId": "user123",
  "sessionId": "session456",
  "errors": [
    {
      "field": "email",
      "rejectedValue": "invalid@email",
      "message": "Please enter a valid email address",
      "code": "INVALID_FORMAT"
    }
  ],
  "suggestions": ["Check email format", "Try again"],
  "retryable": false,
  "helpUrl": "https://docs.spinwish.com/errors/VAL_003"
}
```

## 🔧 Usage Examples

### Creating Custom Exceptions

```java
// Business logic exception
throw BusinessException.artistNotFound("123")
    .addContext("userId", currentUserId)
    .addContext("searchCriteria", criteria);

// Validation exception with multiple field errors
ValidationException exception = new ValidationException("Registration validation failed");
exception.addFieldError("email", email, "Invalid email format", "INVALID_FORMAT");
exception.addFieldError("password", "", "Password is required", "REQUIRED");
throw exception;

// System exception with retry capability
throw new SystemException(
    ErrorCode.DATABASE_CONNECTION_ERROR,
    "Database connection failed",
    "Unable to connect to database",
    true // retryable
);
```

### Controller Error Handling

```java
@PostMapping("/artists")
public ResponseEntity<ArtistResponse> createArtist(@Valid @RequestBody ArtistRequest request) {
    // Validation errors are automatically handled by GlobalExceptionHandler
    // Business logic errors are thrown as BusinessExceptions
    
    ArtistResponse response = artistService.createArtist(request);
    return ResponseEntity.ok(response);
}
```

### Service Layer Error Handling

```java
@Service
public class ArtistService {
    
    public ArtistResponse createArtist(ArtistRequest request) {
        // Check for existing artist
        if (artistRepository.existsByName(request.getName())) {
            throw BusinessException.artistAlreadyExists(request.getName())
                .addContext("requestedName", request.getName());
        }
        
        try {
            // Create artist logic
            return convertToResponse(savedArtist);
        } catch (DataIntegrityViolationException e) {
            throw new SystemException(
                ErrorCode.DATABASE_CONNECTION_ERROR,
                "Failed to save artist",
                "Database operation failed",
                true
            );
        }
    }
}
```

## 📊 Monitoring & Metrics

### Error Metrics

The system automatically tracks:

- **Error counts by type** (authentication, validation, business logic, etc.)
- **Error counts by HTTP status** (400, 401, 404, 500, etc.)
- **Error counts by endpoint** (with path parameter sanitization)
- **Error resolution times**
- **Retry attempts**
- **Correlation ID usage**

### Health Indicators

Custom health checks monitor:

- **Database connectivity** with connection validation
- **Error rate** with configurable thresholds
- **Memory usage** with heap monitoring
- **Disk space** with usage thresholds

### Accessing Metrics

```bash
# Error statistics
GET /api/v1/monitoring/errors

# Health summary
GET /api/v1/monitoring/health-summary

# Actuator endpoints
GET /actuator/health
GET /actuator/metrics
GET /actuator/error-metrics
GET /actuator/prometheus
```

## 🔍 Request Tracking

### Correlation ID System

Every request gets a unique correlation ID that:

- **Propagates through all logs** for request tracing
- **Included in error responses** for debugging
- **Tracked in metrics** for request correlation
- **Exposed in response headers** (`X-Correlation-ID`)

### Request Context

The system maintains thread-local context with:

```java
ErrorContextHolder.setCorrelationId("REQ-ABC123");
ErrorContextHolder.setUserId("user123");
ErrorContextHolder.setSessionId("session456");
ErrorContextHolder.addMetadata("clientVersion", "1.2.3");
```

## ✅ Validation System

### Custom Validators

```java
// Email validation with business rules
@ValidEmail
private String emailAddress;

// Strong password validation
@ValidPassword
private String password;

// Standard Bean Validation
@NotBlank(message = "Username is required")
@Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
private String username;
```

### Validation Error Responses

Validation errors return detailed field-level information:

```json
{
  "status": 400,
  "errorCode": "VAL_001",
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "rejectedValue": "invalid-email",
      "message": "Please enter a valid email address",
      "code": "INVALID_FORMAT"
    },
    {
      "field": "password",
      "rejectedValue": "",
      "message": "Password is required",
      "code": "REQUIRED"
    }
  ]
}
```

## 🚀 Best Practices

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
   throw BusinessException.playbackFailed("Invalid format")
       .addContext("fileFormat", format)
       .addContext("fileSize", size);
   ```

3. **Use Appropriate Error Codes**
   ```java
   // For business logic violations
   throw new BusinessException(ErrorCode.INSUFFICIENT_PERMISSIONS, message);
   
   // For validation errors
   throw ValidationException.invalidEmail(email);
   
   // For system errors
   throw new SystemException(ErrorCode.DATABASE_CONNECTION_ERROR, message, true);
   ```

### For API Consumers

1. **Always Check Error Codes**
   ```javascript
   if (response.errorCode === 'AUTH_002') {
     // Token expired - redirect to login
     redirectToLogin();
   }
   ```

2. **Use Correlation IDs for Support**
   ```javascript
   console.error(`Request failed with correlation ID: ${response.correlationId}`);
   ```

3. **Handle Retryable Errors**
   ```javascript
   if (response.retryable && response.retryAfter) {
     setTimeout(() => retryRequest(), response.retryAfter);
   }
   ```

## 🔧 Configuration

### Application Properties

```properties
# Logging with correlation ID
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level [%X{correlationId:-}] %logger{36} - %msg%n

# Error handling
server.error.include-message=never
server.error.include-stacktrace=never

# Monitoring
management.endpoints.web.exposure.include=health,info,metrics,prometheus,error-metrics
management.metrics.export.prometheus.enabled=true
```

### Environment-Specific Settings

```properties
# Development
logging.level.com.spinwish.backend.exceptions=DEBUG
logging.level.com.spinwish.backend.interceptors=DEBUG

# Production
logging.level.com.spinwish.backend.exceptions=INFO
logging.level.com.spinwish.backend.interceptors=WARN
```

## 🧪 Testing

### Unit Tests

```java
@Test
void handleBusinessException_ShouldReturnCorrectErrorResponse() {
    BusinessException exception = BusinessException.artistNotFound("123");
    
    ResponseEntity<ApiErrorResponse> response = 
        globalExceptionHandler.handleBaseException(exception, request);
    
    assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
    assertEquals(ErrorCode.ARTIST_NOT_FOUND.getCode(), 
                response.getBody().getErrorCode());
}
```

### Integration Tests

```java
@Test
void createArtist_WithDuplicateName_ShouldReturnConflictError() {
    mockMvc.perform(post("/api/v1/artists")
            .contentType(MediaType.APPLICATION_JSON)
            .content(duplicateArtistJson))
        .andExpect(status().isConflict())
        .andExpect(jsonPath("$.errorCode").value("BIZ_002"))
        .andExpect(jsonPath("$.correlationId").exists());
}
```

## 📈 Monitoring Dashboard

### Key Metrics to Monitor

1. **Error Rate** - Percentage of requests resulting in errors
2. **Error Distribution** - Breakdown by error type and category
3. **Response Times** - P50, P95, P99 percentiles
4. **Correlation ID Coverage** - Percentage of requests with correlation IDs
5. **Retry Success Rate** - Success rate of retried requests

### Alerting Thresholds

- **Error Rate > 5%** - Warning
- **Error Rate > 10%** - Critical
- **Memory Usage > 90%** - Warning
- **Disk Usage > 90%** - Critical
- **Database Health Check Failure** - Critical

## 🎉 Conclusion

This comprehensive error handling system provides:

- **Consistent error responses** across all endpoints
- **Detailed debugging information** with correlation IDs
- **Comprehensive monitoring** and metrics
- **Robust validation** with field-level details
- **Production-ready logging** and health checks
- **Developer-friendly APIs** for error handling

The system is designed to be maintainable, scalable, and provides excellent debugging capabilities while maintaining security and performance standards.
