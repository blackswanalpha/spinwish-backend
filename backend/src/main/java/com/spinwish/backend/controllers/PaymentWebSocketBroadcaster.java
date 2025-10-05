package com.spinwish.backend.controllers;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * WebSocket broadcaster for real-time payment notifications.
 * Sends payment updates to connected clients via WebSocket.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class PaymentWebSocketBroadcaster {

    private final SimpMessagingTemplate messagingTemplate;

    /**
     * Broadcast payment initiation to all subscribers.
     */
    public void broadcastPaymentInitiated(String checkoutRequestId, String paymentType,
                                          Double amount, String phoneNumber) {
        Map<String, Object> message = new HashMap<>();
        message.put("event", "PAYMENT_INITIATED");
        message.put("checkoutRequestId", checkoutRequestId);
        message.put("paymentType", paymentType);
        message.put("amount", amount);
        message.put("phoneNumber", phoneNumber);
        message.put("timestamp", LocalDateTime.now().toString());

        messagingTemplate.convertAndSend("/topic/payments", message);
        log.debug("📡 Broadcasted payment initiation: {}", checkoutRequestId);
    }

    /**
     * Broadcast payment processing status.
     */
    public void broadcastPaymentProcessing(String checkoutRequestId, String status) {
        Map<String, Object> message = new HashMap<>();
        message.put("event", "PAYMENT_PROCESSING");
        message.put("checkoutRequestId", checkoutRequestId);
        message.put("status", status);
        message.put("timestamp", LocalDateTime.now().toString());

        messagingTemplate.convertAndSend("/topic/payments", message);
        log.debug("📡 Broadcasted payment processing: {} - {}", checkoutRequestId, status);
    }

    /**
     * Broadcast payment completion.
     */
    public void broadcastPaymentCompleted(String checkoutRequestId, String paymentType,
                                          Double amount, String receiptNumber) {
        Map<String, Object> message = new HashMap<>();
        message.put("event", "PAYMENT_COMPLETED");
        message.put("checkoutRequestId", checkoutRequestId);
        message.put("paymentType", paymentType);
        message.put("amount", amount);
        message.put("receiptNumber", receiptNumber);
        message.put("timestamp", LocalDateTime.now().toString());

        messagingTemplate.convertAndSend("/topic/payments", message);
        log.info("📡 Broadcasted payment completion: {} - Amount: {}", checkoutRequestId, amount);
    }

    /**
     * Broadcast payment failure.
     */
    public void broadcastPaymentFailed(String checkoutRequestId, String paymentType,
                                       Integer resultCode, String resultDescription) {
        Map<String, Object> message = new HashMap<>();
        message.put("event", "PAYMENT_FAILED");
        message.put("checkoutRequestId", checkoutRequestId);
        message.put("paymentType", paymentType);
        message.put("resultCode", resultCode);
        message.put("resultDescription", resultDescription);
        message.put("timestamp", LocalDateTime.now().toString());

        messagingTemplate.convertAndSend("/topic/payments", message);
        log.info("📡 Broadcasted payment failure: {} - Reason: {}", checkoutRequestId, resultDescription);
    }

    /**
     * Broadcast payment notification to specific DJ.
     */
    public void broadcastPaymentToDJ(UUID djId, String paymentType, Double amount,
                                     String fromUser) {
        Map<String, Object> message = new HashMap<>();
        message.put("event", "DJ_PAYMENT_RECEIVED");
        message.put("paymentType", paymentType);
        message.put("amount", amount);
        message.put("fromUser", fromUser);
        message.put("timestamp", LocalDateTime.now().toString());

        // Send to DJ-specific topic
        messagingTemplate.convertAndSend("/topic/dj/" + djId + "/payments", message);
        log.info("📡 Broadcasted payment to DJ {}: {} KES from {}", djId, amount, fromUser);
    }

    /**
     * Broadcast payment status query result.
     */
    public void broadcastPaymentStatusQuery(String checkoutRequestId, String status,
                                            Integer resultCode, String resultDescription) {
        Map<String, Object> message = new HashMap<>();
        message.put("event", "PAYMENT_STATUS_QUERY");
        message.put("checkoutRequestId", checkoutRequestId);
        message.put("status", status);
        message.put("resultCode", resultCode);
        message.put("resultDescription", resultDescription);
        message.put("timestamp", LocalDateTime.now().toString());

        messagingTemplate.convertAndSend("/topic/payments", message);
        log.debug("📡 Broadcasted payment status query: {} - {}", checkoutRequestId, status);
    }

    /**
     * Broadcast general payment event.
     */
    public void broadcastPaymentEvent(String eventType, Map<String, Object> eventData) {
        Map<String, Object> message = new HashMap<>();
        message.put("event", eventType);
        message.putAll(eventData);
        message.put("timestamp", LocalDateTime.now().toString());

        messagingTemplate.convertAndSend("/topic/payments", message);
        log.debug("📡 Broadcasted payment event: {}", eventType);
    }
}

