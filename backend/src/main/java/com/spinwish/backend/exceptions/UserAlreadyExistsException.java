package com.spinwish.backend.exceptions;

import com.spinwish.backend.enums.ErrorCode;

/**
 * @deprecated Use BusinessException.userAlreadyExists() or ValidationException instead
 * Kept for backward compatibility
 */
@Deprecated
public class UserAlreadyExistsException extends BusinessException {
    public UserAlreadyExistsException(String message) {
        super(ErrorCode.USER_ALREADY_EXISTS, message);
    }
}
