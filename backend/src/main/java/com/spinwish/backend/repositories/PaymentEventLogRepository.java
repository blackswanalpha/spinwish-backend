package com.spinwish.backend.repositories;

import com.spinwish.backend.entities.payments.PaymentEventLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Repository for PaymentEventLog entity.
 */
@Repository
public interface PaymentEventLogRepository extends JpaRepository<PaymentEventLog, UUID> {
    
    /**
     * Find all events for a specific checkout request ID.
     */
    List<PaymentEventLog> findByCheckoutRequestIdOrderByEventTimestampDesc(String checkoutRequestId);
    
    /**
     * Find events by type.
     */
    List<PaymentEventLog> findByEventTypeOrderByEventTimestampDesc(PaymentEventLog.EventType eventType);
    
    /**
     * Find events within a time range.
     */
    List<PaymentEventLog> findByEventTimestampBetweenOrderByEventTimestampDesc(
            LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * Find events for a specific user.
     */
    List<PaymentEventLog> findByUserIdOrderByEventTimestampDesc(UUID userId);
    
    /**
     * Find events for a specific DJ.
     */
    List<PaymentEventLog> findByDjIdOrderByEventTimestampDesc(UUID djId);

    /**
     * Find events by payment type.
     */
    List<PaymentEventLog> findByPaymentTypeOrderByEventTimestampDesc(String paymentType);
}

