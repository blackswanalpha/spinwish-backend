package com.spinwish.backend.models.requests.payments;

import lombok.Data;

import java.util.UUID;

@Data
public class MpesaRequest {
    private String phoneNumber;
    private String amount;
    private String requestId; // Changed to String to handle JSON deserialization
    private String djName;

    /**
     * Get requestId as UUID, handling string conversion
     */
    public UUID getRequestIdAsUuid() {
        if (requestId == null || requestId.trim().isEmpty()) {
            return null;
        }
        try {
            return UUID.fromString(requestId);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    /**
     * Check if this is a valid request payment (has requestId)
     */
    public boolean isRequestPayment() {
        return requestId != null && !requestId.trim().isEmpty();
    }

    /**
     * Check if this is a valid tip payment (has djName)
     */
    public boolean isTipPayment() {
        return djName != null && !djName.trim().isEmpty();
    }
}

