package com.spinwish.backend.models.responses.users;

import lombok.Data;

@Data
public class RegisterResponse {
    private String emailAddress;
    private String username;
}
