package com.spinwish.backend.models.requests.payments;

import lombok.Data;

import java.util.UUID;

@Data
public class CreatePayoutRequest {
    private UUID payoutMethodId;
    private Double amount;
    private String notes;
}

