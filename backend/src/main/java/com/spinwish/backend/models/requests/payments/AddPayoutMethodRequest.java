package com.spinwish.backend.models.requests.payments;

import com.spinwish.backend.entities.payments.PayoutMethod.PayoutMethodType;
import lombok.Data;

@Data
public class AddPayoutMethodRequest {
    private PayoutMethodType methodType;
    private String displayName;
    
    // Bank Account fields
    private String bankName;
    private String accountNumber;
    private String accountHolderName;
    private String bankBranch;
    private String bankCode;
    
    // M-Pesa fields
    private String mpesaPhoneNumber;
    private String mpesaAccountName;
    
    private Boolean setAsDefault = false;
    private String notes;
}

