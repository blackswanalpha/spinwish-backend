package com.spinwish.backend.models.responses.users;

import lombok.Data;

@Data
public class VerificationResponse {
    private boolean success;
    private String message;
    private UserResponse userDetails;
    private String token;
    private String refreshToken;
}
