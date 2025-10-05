package com.spinwish.backend.exceptions;

import com.spinwish.backend.enums.ErrorCode;

/**
 * @deprecated Use BusinessException.playbackFailed() instead
 * Kept for backward compatibility
 */
@Deprecated
public class PlaySongException extends BusinessException {
    public PlaySongException(String message) {
        super(ErrorCode.PLAYBACK_FAILED, message);
    }
}
