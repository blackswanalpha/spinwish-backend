# Swagger UI Setup for SpinWish API

## Overview
Swagger UI has been successfully configured for the SpinWish backend API. This provides interactive API documentation that allows you to explore and test all endpoints directly from your browser.

## Accessing Swagger UI

### Development Environment
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **OpenAPI JSON**: http://localhost:8080/v3/api-docs
- **OpenAPI YAML**: http://localhost:8080/v3/api-docs.yaml

### Production Environment
- **Swagger UI**: https://spinwish.onrender.com/swagger-ui.html
- **OpenAPI JSON**: https://spinwish.onrender.com/v3/api-docs

## Features Configured

### 1. API Documentation Groups
The API is organized into logical groups:
- **Public**: All API endpoints (`/api/v1/**`)
- **Authentication**: User management endpoints (`/api/v1/users/**`)
- **Payment**: Payment-related endpoints (`/api/v1/payment/**`)

### 2. Security Configuration
- JWT Bearer token authentication is configured
- Public endpoints (signup, login, payment callbacks) don't require authentication
- Protected endpoints require a valid JWT token

### 3. UI Enhancements
- Operations sorted by HTTP method
- Tags sorted alphabetically
- "Try it out" functionality enabled
- Request duration display enabled
- Search/filter functionality enabled

## Using Swagger UI

### 1. Authentication
For protected endpoints:
1. First, use the `/api/v1/users/login` endpoint to get a JWT token
2. Click the "Authorize" button at the top of the Swagger UI
3. Enter your JWT token in the format: `Bearer your-jwt-token-here`
4. Click "Authorize" to apply the token to all requests

### 2. Testing Endpoints
1. Navigate to any endpoint in the Swagger UI
2. Click "Try it out"
3. Fill in the required parameters
4. Click "Execute" to send the request
5. View the response below

### 3. Example Workflow
1. **Register a new user**: POST `/api/v1/users/signup`
2. **Login**: POST `/api/v1/users/login` (copy the JWT token from response)
3. **Authorize**: Click "Authorize" and paste the JWT token
4. **Test protected endpoints**: Now you can test any protected endpoint

## Configuration Files

### Dependencies (pom.xml)
```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.8.9</version>
</dependency>
```

### Application Properties
```properties
# Swagger/OpenAPI Configuration
springdoc.api-docs.path=/v3/api-docs
springdoc.swagger-ui.path=/swagger-ui.html
springdoc.swagger-ui.operationsSorter=method
springdoc.swagger-ui.tagsSorter=alpha
springdoc.swagger-ui.tryItOutEnabled=true
springdoc.swagger-ui.filter=true
springdoc.swagger-ui.displayRequestDuration=true
```

### Security Configuration
The following endpoints are publicly accessible (no authentication required):
- `/swagger-ui.html`
- `/swagger-ui/**`
- `/v3/api-docs/**`
- `/api/v1/users/signup`
- `/api/v1/users/login`
- `/api/v1/payment/mpesa/callback`

## Adding Swagger Annotations to Controllers

### Example Controller with Annotations
```java
@RestController
@RequestMapping("/api/v1/example")
@Tag(name = "Example API", description = "Example endpoints")
public class ExampleController {

    @Operation(
        summary = "Create example",
        description = "Create a new example resource"
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "201",
            description = "Example created successfully",
            content = @Content(schema = @Schema(implementation = ExampleResponse.class))
        ),
        @ApiResponse(
            responseCode = "400",
            description = "Invalid input"
        )
    })
    @PostMapping
    public ResponseEntity<ExampleResponse> create(
        @Parameter(description = "Example request data", required = true)
        @RequestBody ExampleRequest request) {
        // Implementation
    }
}
```

### Common Annotations
- `@Tag`: Groups related operations
- `@Operation`: Describes the operation
- `@ApiResponses`: Documents possible responses
- `@Parameter`: Describes request parameters
- `@SecurityRequirement`: Specifies security requirements

## Troubleshooting

### Common Issues
1. **Swagger UI not loading**: Check if the application is running on the correct port
2. **Authentication not working**: Ensure JWT token is prefixed with "Bearer "
3. **Endpoints not showing**: Verify controller classes are in the component scan path

### Logs
Enable debug logging for SpringDoc:
```properties
logging.level.org.springdoc=DEBUG
```

## Next Steps

1. **Add more annotations**: Enhance other controllers with Swagger annotations
2. **Custom schemas**: Define custom response schemas for better documentation
3. **Examples**: Add example request/response bodies
4. **Validation**: Document validation constraints using Bean Validation annotations

## Resources
- [SpringDoc OpenAPI Documentation](https://springdoc.org/)
- [OpenAPI 3.0 Specification](https://swagger.io/specification/)
- [Swagger UI Documentation](https://swagger.io/tools/swagger-ui/)
