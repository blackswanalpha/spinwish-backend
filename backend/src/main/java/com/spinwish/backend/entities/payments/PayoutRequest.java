package com.spinwish.backend.entities.payments;

import com.spinwish.backend.entities.Users;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Entity representing a payout request from a DJ
 */
@Entity
@Getter
@Setter
@Table(name = "payout_requests")
public class PayoutRequest {
    
    @Id
    @GeneratedValue
    private UUID id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private Users user;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "payout_method_id", nullable = false)
    private PayoutMethod payoutMethod;
    
    @Column(name = "amount", nullable = false)
    private Double amount;
    
    @Column(name = "currency", nullable = false)
    private String currency = "KES";
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private PayoutStatus status = PayoutStatus.PENDING;
    
    @Column(name = "requested_at", nullable = false)
    private LocalDateTime requestedAt = LocalDateTime.now();
    
    @Column(name = "processed_at")
    private LocalDateTime processedAt;
    
    @Column(name = "completed_at")
    private LocalDateTime completedAt;
    
    @Column(name = "failed_at")
    private LocalDateTime failedAt;
    
    @Column(name = "external_transaction_id")
    private String externalTransactionId;
    
    @Column(name = "receipt_number")
    private String receiptNumber;
    
    @Column(name = "failure_reason", columnDefinition = "TEXT")
    private String failureReason;
    
    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;
    
    @Column(name = "processing_fee")
    private Double processingFee = 0.0;
    
    @Column(name = "net_amount")
    private Double netAmount;
    
    @Column(name = "processed_by")
    private String processedBy; // System or admin user ID
    
    public enum PayoutStatus {
        PENDING,
        PROCESSING,
        COMPLETED,
        FAILED,
        CANCELLED
    }
    
    @PrePersist
    protected void onCreate() {
        if (netAmount == null) {
            netAmount = amount - (processingFee != null ? processingFee : 0.0);
        }
    }
    
    /**
     * Mark payout as processing
     */
    public void markAsProcessing() {
        this.status = PayoutStatus.PROCESSING;
        this.processedAt = LocalDateTime.now();
    }
    
    /**
     * Mark payout as completed
     */
    public void markAsCompleted(String transactionId, String receiptNum) {
        this.status = PayoutStatus.COMPLETED;
        this.completedAt = LocalDateTime.now();
        this.externalTransactionId = transactionId;
        this.receiptNumber = receiptNum;
    }
    
    /**
     * Mark payout as failed
     */
    public void markAsFailed(String reason) {
        this.status = PayoutStatus.FAILED;
        this.failedAt = LocalDateTime.now();
        this.failureReason = reason;
    }
    
    /**
     * Mark payout as cancelled
     */
    public void markAsCancelled(String reason) {
        this.status = PayoutStatus.CANCELLED;
        this.failureReason = reason;
    }
}

