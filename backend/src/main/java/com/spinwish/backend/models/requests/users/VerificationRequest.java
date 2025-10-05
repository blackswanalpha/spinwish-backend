package com.spinwish.backend.models.requests.users;

import lombok.Data;

@Data
public class VerificationRequest {
    private String emailAddress;
    private String verificationCode;
    private String verificationType; // "EMAIL" or "PHONE"
}
