package com.spinwish.backend.models.responses.payments;

import com.spinwish.backend.entities.payments.PayoutMethod;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class PayoutMethodResponse {
    private UUID id;
    private String methodType;
    private String displayName;
    
    // Bank Account fields (masked)
    private String bankName;
    private String maskedAccountNumber;
    private String accountHolderName;
    private String bankBranch;
    
    // M-Pesa fields (masked)
    private String maskedPhoneNumber;
    private String mpesaAccountName;
    
    private Boolean isDefault;
    private Boolean isVerified;
    private LocalDateTime createdAt;
    private LocalDateTime lastUsedAt;
    
    public static PayoutMethodResponse fromEntity(PayoutMethod method) {
        PayoutMethodResponse response = new PayoutMethodResponse();
        response.setId(method.getId());
        response.setMethodType(method.getMethodType().name());
        response.setDisplayName(method.getDisplayName());
        response.setIsDefault(method.getIsDefault());
        response.setIsVerified(method.getIsVerified());
        response.setCreatedAt(method.getCreatedAt());
        response.setLastUsedAt(method.getLastUsedAt());
        
        if (method.getMethodType() == PayoutMethod.PayoutMethodType.BANK_ACCOUNT) {
            response.setBankName(method.getBankName());
            response.setMaskedAccountNumber(method.getMaskedAccountNumber());
            response.setAccountHolderName(method.getAccountHolderName());
            response.setBankBranch(method.getBankBranch());
        } else if (method.getMethodType() == PayoutMethod.PayoutMethodType.MPESA) {
            response.setMaskedPhoneNumber(method.getMaskedPhoneNumber());
            response.setMpesaAccountName(method.getMpesaAccountName());
        }
        
        return response;
    }
}

