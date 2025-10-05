package com.spinwish.backend.exceptions;

import com.spinwish.backend.enums.ErrorCode;

/**
 * @deprecated Use AuthenticationException instead
 * Kept for backward compatibility
 */
@Deprecated
public class UnauthorizedException extends AuthenticationException {
    public UnauthorizedException(String message) {
        super(ErrorCode.UNAUTHORIZED_ACCESS, message);
    }
}
