package com.spinwish.backend.models.responses.payments;

import com.spinwish.backend.entities.payments.PayoutRequest;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class PayoutRequestResponse {
    private UUID id;
    private UUID payoutMethodId;
    private String payoutMethodType;
    private String payoutMethodDisplayName;
    private Double amount;
    private String currency;
    private String status;
    private LocalDateTime requestedAt;
    private LocalDateTime processedAt;
    private LocalDateTime completedAt;
    private String externalTransactionId;
    private String receiptNumber;
    private String failureReason;
    private Double processingFee;
    private Double netAmount;
    
    public static PayoutRequestResponse fromEntity(PayoutRequest request) {
        PayoutRequestResponse response = new PayoutRequestResponse();
        response.setId(request.getId());
        response.setPayoutMethodId(request.getPayoutMethod().getId());
        response.setPayoutMethodType(request.getPayoutMethod().getMethodType().name());
        response.setPayoutMethodDisplayName(request.getPayoutMethod().getDisplayName());
        response.setAmount(request.getAmount());
        response.setCurrency(request.getCurrency());
        response.setStatus(request.getStatus().name());
        response.setRequestedAt(request.getRequestedAt());
        response.setProcessedAt(request.getProcessedAt());
        response.setCompletedAt(request.getCompletedAt());
        response.setExternalTransactionId(request.getExternalTransactionId());
        response.setReceiptNumber(request.getReceiptNumber());
        response.setFailureReason(request.getFailureReason());
        response.setProcessingFee(request.getProcessingFee());
        response.setNetAmount(request.getNetAmount());
        return response;
    }
}

