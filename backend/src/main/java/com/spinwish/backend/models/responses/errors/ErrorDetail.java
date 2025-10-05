package com.spinwish.backend.models.responses.errors;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Represents detailed error information for specific fields or validation errors
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ErrorDetail {
    
    /**
     * The field name that caused the error (for validation errors)
     */
    private String field;
    
    /**
     * The rejected value that caused the error
     */
    private Object rejectedValue;
    
    /**
     * Detailed error message for this specific error
     */
    private String message;
    
    /**
     * Error code specific to this detail
     */
    private String code;
    
    /**
     * Additional context or metadata for this error
     */
    private Object context;
    
    /**
     * Create an error detail for field validation
     */
    public static ErrorDetail fieldError(String field, Object rejectedValue, String message, String code) {
        return ErrorDetail.builder()
                .field(field)
                .rejectedValue(rejectedValue)
                .message(message)
                .code(code)
                .build();
    }
    
    /**
     * Create a general error detail
     */
    public static ErrorDetail generalError(String message, String code) {
        return ErrorDetail.builder()
                .message(message)
                .code(code)
                .build();
    }
    
    /**
     * Create an error detail with context
     */
    public static ErrorDetail contextError(String message, String code, Object context) {
        return ErrorDetail.builder()
                .message(message)
                .code(code)
                .context(context)
                .build();
    }
}
