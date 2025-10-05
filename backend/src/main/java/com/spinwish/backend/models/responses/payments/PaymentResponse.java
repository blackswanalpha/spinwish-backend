package com.spinwish.backend.models.responses.payments;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class PaymentResponse {
    private Double amount;
    private String phoneNumber;
    private String receiptNumber;
    private String payerName;
    private String type;
    private LocalDateTime transactionDate;
    private UUID requestId;
    private String djName;
}

