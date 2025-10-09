package com.spinwish.backend.entities.payments;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Entity representing a refund for a rejected song request
 */
@Entity
@Getter
@Setter
@Table(name = "refunds")
public class Refund {
    
    @Id
    @GeneratedValue
    private UUID id;

    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "request_payment_id", nullable = false, unique = true)
    private RequestsPayment requestPayment;

    @Column(name = "amount", nullable = false)
    private Double amount;

    @Column(name = "reason", columnDefinition = "TEXT")
    private String reason;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private RefundStatus status;

    @Column(name = "refund_method")
    private String refundMethod; // MPESA, CARD, etc.

    @Column(name = "transaction_id")
    private String transactionId; // M-Pesa transaction ID or other payment gateway ID

    @Column(name = "initiated_at", nullable = false)
    private LocalDateTime initiatedAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @Column(name = "failure_reason", columnDefinition = "TEXT")
    private String failureReason;

    @PrePersist
    protected void onCreate() {
        if (initiatedAt == null) {
            initiatedAt = LocalDateTime.now();
        }
        if (status == null) {
            status = RefundStatus.PENDING;
        }
    }

    /**
     * Enum for refund status
     */
    public enum RefundStatus {
        PENDING,      // Refund initiated but not yet processed
        PROCESSING,   // Refund is being processed
        COMPLETED,    // Refund successfully completed
        FAILED;       // Refund failed

        @JsonCreator
        public static RefundStatus fromString(String value) {
            if (value == null) {
                return PENDING;
            }

            switch (value.toUpperCase()) {
                case "PENDING":
                    return PENDING;
                case "PROCESSING":
                    return PROCESSING;
                case "COMPLETED":
                    return COMPLETED;
                case "FAILED":
                    return FAILED;
                default:
                    return PENDING;
            }
        }

        @JsonValue
        public String toValue() {
            return this.name();
        }
    }
}

