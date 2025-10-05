package com.spinwish.backend.models.requests.users;

import com.spinwish.backend.validators.ValidEmail;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LoginRequest {

    @NotBlank(message = "Email address is required")
    @ValidEmail
    private String emailAddress;

    @NotBlank(message = "Password is required")
    private String password;
}
