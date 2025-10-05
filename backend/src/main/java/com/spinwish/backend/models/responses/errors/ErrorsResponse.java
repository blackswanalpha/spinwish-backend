package com.spinwish.backend.models.responses.errors;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class ErrorsResponse {
    private int status;
    private String error;
    private String message;
    private LocalDateTime timestamp = LocalDateTime.now();

    public ErrorsResponse(int status, String error, String message) {
        this.status = status;
        this.error = error;
        this.message = message;
    }
}

