package com.spinwish.backend.exceptions;

import com.spinwish.backend.enums.ErrorCode;

/**
 * Exception for business logic violations and domain-specific errors
 */
public class BusinessException extends BaseException {
    
    public BusinessException(ErrorCode errorCode, String message) {
        super(errorCode, message);
    }
    
    public BusinessException(ErrorCode errorCode, String message, Throwable cause) {
        super(errorCode, message, cause);
    }
    
    public BusinessException(ErrorCode errorCode, String message, String userMessage) {
        super(errorCode, message, userMessage, false, null);
    }
    
    // Specific business exception factory methods
    
    public static BusinessException artistNotFound(String artistId) {
        return new BusinessException(
            ErrorCode.ARTIST_NOT_FOUND, 
            "Artist not found with ID: " + artistId,
            "The requested artist could not be found"
        ).addContext("artistId", artistId);
    }
    
    public static BusinessException artistAlreadyExists(String artistName) {
        return new BusinessException(
            ErrorCode.ARTIST_ALREADY_EXISTS, 
            "Artist already exists with name: " + artistName,
            "An artist with this name already exists"
        ).addContext("artistName", artistName);
    }
    
    public static BusinessException songNotFound(String songId) {
        return new BusinessException(
            ErrorCode.SONG_NOT_FOUND, 
            "Song not found with ID: " + songId,
            "The requested song could not be found"
        ).addContext("songId", songId);
    }
    
    public static BusinessException playbackFailed(String reason) {
        return new BusinessException(
            ErrorCode.PLAYBACK_FAILED, 
            "Playback creation failed: " + reason,
            "Unable to start playback at this time"
        ).addContext("reason", reason);
    }
    
    public static BusinessException insufficientPermissions(String operation, String userId) {
        return new BusinessException(
            ErrorCode.INSUFFICIENT_PERMISSIONS, 
            "User " + userId + " lacks permissions for operation: " + operation,
            "You don't have permission to perform this action"
        ).addContext("operation", operation).addContext("userId", userId);
    }
    
    public static BusinessException operationNotAllowed(String operation, String currentState) {
        return new BusinessException(
            ErrorCode.OPERATION_NOT_ALLOWED, 
            "Operation " + operation + " not allowed in current state: " + currentState,
            "This operation is not allowed at this time"
        ).addContext("operation", operation).addContext("currentState", currentState);
    }
    
    public static BusinessException resourceConflict(String resource, String conflictReason) {
        return new BusinessException(
            ErrorCode.RESOURCE_CONFLICT,
            "Resource conflict for " + resource + ": " + conflictReason,
            "A conflict occurred while processing your request"
        ).addContext("resource", resource).addContext("conflictReason", conflictReason);
    }

    // Override methods to return BusinessException for method chaining

    @Override
    public BusinessException addContext(String key, Object value) {
        super.addContext(key, value);
        return this;
    }

    @Override
    public BusinessException setCorrelationId(String correlationId) {
        super.setCorrelationId(correlationId);
        return this;
    }
}
