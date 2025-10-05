package com.spinwish.backend.entities.payments;

import com.spinwish.backend.entities.Request;
import com.spinwish.backend.entities.Users;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Getter
@Setter
@Table(name = "stk_push_sessions")
public class StkPushSession {
    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "checkout_request_id", nullable = false, unique = true)
    private String checkoutRequestId;

    @ManyToOne
    @JoinColumn(name = "request_id") // nullable: it will be null if it's a tip
    private Request request;

    @ManyToOne
    @JoinColumn(name = "dj_id") // nullable: it will be null if it's a request payment
    private Users dj;

    @ManyToOne
    @JoinColumn(name = "payer_id") // who paid
    private Users payer;

    @Column(name = "phone_number")
    private String phoneNumber;

    @Column(name = "amount")
    private Double amount;

    @Column(name = "status")
    private String status = "PENDING";

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "last_updated")
    private LocalDateTime lastUpdated;

    @Column(name = "failure_reason")
    private String failureReason;

    @Column(name = "retry_count")
    private Integer retryCount = 0;

    @Column(name = "result_code")
    private Integer resultCode;

    @Column(name = "result_description")
    private String resultDescription;

    @Column(name = "mpesa_receipt_number")
    private String mpesaReceiptNumber;

    @Column(name = "transaction_date")
    private LocalDateTime transactionDate;

    /**
     * Update the session status and last updated timestamp.
     */
    public void updateStatus(String newStatus) {
        this.status = newStatus;
        this.lastUpdated = LocalDateTime.now();
    }

    /**
     * Increment retry count.
     */
    public void incrementRetryCount() {
        this.retryCount = (this.retryCount == null ? 0 : this.retryCount) + 1;
        this.lastUpdated = LocalDateTime.now();
    }

    /**
     * Mark as failed with reason.
     */
    public void markAsFailed(String reason, Integer code) {
        this.status = "FAILED";
        this.failureReason = reason;
        this.resultCode = code;
        this.lastUpdated = LocalDateTime.now();
    }

    /**
     * Mark as completed.
     */
    public void markAsCompleted(String receiptNumber, LocalDateTime transDate) {
        this.status = "COMPLETED";
        this.mpesaReceiptNumber = receiptNumber;
        this.transactionDate = transDate;
        this.resultCode = 0;
        this.lastUpdated = LocalDateTime.now();
    }
}
