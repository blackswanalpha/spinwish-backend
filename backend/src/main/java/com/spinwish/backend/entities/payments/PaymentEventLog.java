package com.spinwish.backend.entities.payments;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

/**
 * Entity for tracking all payment-related events.
 * Provides a complete audit trail of payment state changes.
 */
@Entity
@Getter
@Setter
@Table(name = "payment_event_logs")
public class PaymentEventLog {
    
    @Id
    @GeneratedValue
    private UUID id;
    
    @Column(name = "checkout_request_id", nullable = false)
    private String checkoutRequestId;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "event_type", nullable = false)
    private EventType eventType;
    
    @Column(name = "event_timestamp", nullable = false)
    private LocalDateTime eventTimestamp = LocalDateTime.now();
    
    @Column(name = "payment_type")
    private String paymentType; // REQUEST or TIP
    
    @Column(name = "amount")
    private Double amount;
    
    @Column(name = "phone_number")
    private String phoneNumber;
    
    @Column(name = "result_code")
    private Integer resultCode;
    
    @Column(name = "result_description")
    private String resultDescription;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "event_details", columnDefinition = "json")
    private Map<String, Object> eventDetails;
    
    @Column(name = "user_id")
    private UUID userId;
    
    @Column(name = "dj_id")
    private UUID djId;
    
    @Column(name = "request_id")
    private UUID requestId;
    
    /**
     * Event types for payment lifecycle.
     */
    public enum EventType {
        INITIATED,          // Payment request initiated
        STK_PUSH_SENT,      // STK push sent to M-Pesa
        PROCESSING,         // Payment is being processed
        CALLBACK_RECEIVED,  // Callback received from M-Pesa
        COMPLETED,          // Payment completed successfully
        FAILED,             // Payment failed
        CANCELLED,          // Payment cancelled by user
        TIMEOUT,            // Payment timed out
        QUERY_SENT,         // Status query sent
        QUERY_RESPONSE,     // Status query response received
        RETRY_ATTEMPTED     // Retry attempted
    }
    
    /**
     * Create a new event log entry.
     */
    public static PaymentEventLog create(String checkoutRequestId, EventType eventType) {
        PaymentEventLog log = new PaymentEventLog();
        log.setCheckoutRequestId(checkoutRequestId);
        log.setEventType(eventType);
        log.setEventTimestamp(LocalDateTime.now());
        return log;
    }
    
    /**
     * Create event log with details.
     */
    public static PaymentEventLog create(String checkoutRequestId, EventType eventType, 
                                         Map<String, Object> details) {
        PaymentEventLog log = create(checkoutRequestId, eventType);
        log.setEventDetails(details);
        return log;
    }
    
    /**
     * Create event log for payment initiation.
     */
    public static PaymentEventLog forInitiation(String checkoutRequestId, String paymentType,
                                                 Double amount, String phoneNumber,
                                                 UUID userId) {
        PaymentEventLog log = create(checkoutRequestId, EventType.INITIATED);
        log.setPaymentType(paymentType);
        log.setAmount(amount);
        log.setPhoneNumber(phoneNumber);
        log.setUserId(userId);
        return log;
    }

    /**
     * Create event log for payment completion.
     */
    public static PaymentEventLog forCompletion(String checkoutRequestId, String paymentType,
                                                 Double amount, Integer resultCode,
                                                 String resultDescription) {
        PaymentEventLog log = create(checkoutRequestId, EventType.COMPLETED);
        log.setPaymentType(paymentType);
        log.setAmount(amount);
        log.setResultCode(resultCode);
        log.setResultDescription(resultDescription);
        return log;
    }

    /**
     * Create event log for payment failure.
     */
    public static PaymentEventLog forFailure(String checkoutRequestId, String paymentType,
                                             Integer resultCode, String resultDescription) {
        PaymentEventLog log = create(checkoutRequestId, EventType.FAILED);
        log.setPaymentType(paymentType);
        log.setResultCode(resultCode);
        log.setResultDescription(resultDescription);
        return log;
    }
}

