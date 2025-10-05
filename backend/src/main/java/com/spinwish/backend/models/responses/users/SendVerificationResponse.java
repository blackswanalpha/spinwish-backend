package com.spinwish.backend.models.responses.users;

import lombok.Data;

@Data
public class SendVerificationResponse {
    private boolean success;
    private String message;
    private String verificationType;
    private String destination; // email address or masked phone number
}
