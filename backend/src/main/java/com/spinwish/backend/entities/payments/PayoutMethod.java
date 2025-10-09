package com.spinwish.backend.entities.payments;

import com.spinwish.backend.entities.Users;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Entity representing a payout method for DJs
 * Supports bank accounts and M-Pesa
 */
@Entity
@Getter
@Setter
@Table(name = "payout_methods")
public class PayoutMethod {
    
    @Id
    @GeneratedValue
    private UUID id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private Users user;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "method_type", nullable = false)
    private PayoutMethodType methodType;
    
    @Column(name = "display_name", nullable = false)
    private String displayName;
    
    // Bank Account fields
    @Column(name = "bank_name")
    private String bankName;
    
    @Column(name = "account_number")
    private String accountNumber;
    
    @Column(name = "account_holder_name")
    private String accountHolderName;
    
    @Column(name = "bank_branch")
    private String bankBranch;
    
    @Column(name = "bank_code")
    private String bankCode;
    
    // M-Pesa fields
    @Column(name = "mpesa_phone_number")
    private String mpesaPhoneNumber;
    
    @Column(name = "mpesa_account_name")
    private String mpesaAccountName;
    
    @Column(name = "is_default")
    private Boolean isDefault = false;
    
    @Column(name = "is_verified")
    private Boolean isVerified = false;
    
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @Column(name = "last_used_at")
    private LocalDateTime lastUsedAt;
    
    @Column(name = "verification_date")
    private LocalDateTime verificationDate;
    
    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;
    
    public enum PayoutMethodType {
        BANK_ACCOUNT,
        MPESA
    }
    
    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
    
    /**
     * Get masked account number for display
     */
    public String getMaskedAccountNumber() {
        if (accountNumber != null && accountNumber.length() > 4) {
            return "****" + accountNumber.substring(accountNumber.length() - 4);
        }
        return accountNumber;
    }
    
    /**
     * Get masked phone number for display
     */
    public String getMaskedPhoneNumber() {
        if (mpesaPhoneNumber != null && mpesaPhoneNumber.length() > 4) {
            return "****" + mpesaPhoneNumber.substring(mpesaPhoneNumber.length() - 4);
        }
        return mpesaPhoneNumber;
    }
}

