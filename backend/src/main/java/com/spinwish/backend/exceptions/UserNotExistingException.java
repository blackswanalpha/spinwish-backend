package com.spinwish.backend.exceptions;

import com.spinwish.backend.enums.ErrorCode;

/**
 * @deprecated Use BusinessException.userNotFound() instead
 * Kept for backward compatibility
 */
@Deprecated
public class UserNotExistingException extends BusinessException {
    public UserNotExistingException(String message) {
        super(ErrorCode.USER_NOT_FOUND, message);
    }
}