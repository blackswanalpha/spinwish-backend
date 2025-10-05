package com.spinwish.backend.services;

import com.spinwish.backend.entities.payments.PaymentEventLog;
import com.spinwish.backend.repositories.PaymentEventLogRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Service for managing payment event logs.
 * Provides methods to log and query payment events.
 */
@Service
@Slf4j
public class PaymentEventLogService {
    
    @Autowired
    private PaymentEventLogRepository eventLogRepository;
    
    /**
     * Log a payment event.
     */
    @Transactional
    public PaymentEventLog logEvent(PaymentEventLog event) {
        try {
            return eventLogRepository.save(event);
        } catch (Exception e) {
            log.error("Failed to save payment event log: {}", e.getMessage(), e);
            return null;
        }
    }
    
    /**
     * Log payment initiation.
     */
    public void logInitiation(String checkoutRequestId, String paymentType, Double amount,
                              String phoneNumber, UUID userId) {
        PaymentEventLog event = PaymentEventLog.forInitiation(
                checkoutRequestId, paymentType, amount, phoneNumber, userId);
        logEvent(event);
        log.info("📝 Logged payment initiation: {} - Type: {} - Amount: {}",
                checkoutRequestId, paymentType, amount);
    }

    /**
     * Log payment completion.
     */
    public void logCompletion(String checkoutRequestId, String paymentType, Double amount,
                             Integer resultCode, String resultDescription) {
        PaymentEventLog event = PaymentEventLog.forCompletion(
                checkoutRequestId, paymentType, amount, resultCode, resultDescription);
        logEvent(event);
        log.info("📝 Logged payment completion: {} - Type: {} - Result: {}",
                checkoutRequestId, paymentType, resultCode);
    }

    /**
     * Log payment failure.
     */
    public void logFailure(String checkoutRequestId, String paymentType, Integer resultCode,
                          String resultDescription) {
        PaymentEventLog event = PaymentEventLog.forFailure(
                checkoutRequestId, paymentType, resultCode, resultDescription);
        logEvent(event);
        log.info("📝 Logged payment failure: {} - Type: {} - Reason: {}",
                checkoutRequestId, paymentType, resultDescription);
    }
    
    /**
     * Log a custom event with details.
     */
    public void logCustomEvent(String checkoutRequestId, PaymentEventLog.EventType eventType,
                               Map<String, Object> details) {
        PaymentEventLog event = PaymentEventLog.create(checkoutRequestId, eventType, details);
        logEvent(event);
        log.debug("📝 Logged custom event: {} - Type: {}", checkoutRequestId, eventType);
    }
    
    /**
     * Get all events for a checkout request.
     */
    public List<PaymentEventLog> getEventsForCheckoutRequest(String checkoutRequestId) {
        return eventLogRepository.findByCheckoutRequestIdOrderByEventTimestampDesc(checkoutRequestId);
    }
    
    /**
     * Get events for a user.
     */
    public List<PaymentEventLog> getEventsForUser(UUID userId) {
        return eventLogRepository.findByUserIdOrderByEventTimestampDesc(userId);
    }
    
    /**
     * Get events for a DJ.
     */
    public List<PaymentEventLog> getEventsForDJ(UUID djId) {
        return eventLogRepository.findByDjIdOrderByEventTimestampDesc(djId);
    }
    
    /**
     * Get events within a time range.
     */
    public List<PaymentEventLog> getEventsBetween(LocalDateTime startTime, LocalDateTime endTime) {
        return eventLogRepository.findByEventTimestampBetweenOrderByEventTimestampDesc(startTime, endTime);
    }
    
    /**
     * Get events by type.
     */
    public List<PaymentEventLog> getEventsByType(PaymentEventLog.EventType eventType) {
        return eventLogRepository.findByEventTypeOrderByEventTimestampDesc(eventType);
    }
    
    /**
     * Get payment timeline (all events for a payment).
     */
    public List<PaymentEventLog> getPaymentTimeline(String checkoutRequestId) {
        List<PaymentEventLog> events = getEventsForCheckoutRequest(checkoutRequestId);
        log.info("📝 Retrieved {} events for payment {}", events.size(), checkoutRequestId);
        return events;
    }
    
    /**
     * Get recent events (last N events).
     */
    public List<PaymentEventLog> getRecentEvents(int limit) {
        return eventLogRepository.findAll().stream()
                .sorted((e1, e2) -> e2.getEventTimestamp().compareTo(e1.getEventTimestamp()))
                .limit(limit)
                .toList();
    }
}

