package com.spinwish.backend.models.responses.users;

import lombok.Data;

@Data
public class LoginResponse {
    private UserResponse userDetails;
    private String token;
    private String refreshToken;
}
