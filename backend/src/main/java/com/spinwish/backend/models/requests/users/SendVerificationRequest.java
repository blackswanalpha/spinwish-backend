package com.spinwish.backend.models.requests.users;

import lombok.Data;

@Data
public class SendVerificationRequest {
    private String emailAddress;
    private String verificationType; // "EMAIL" or "PHONE"
}
