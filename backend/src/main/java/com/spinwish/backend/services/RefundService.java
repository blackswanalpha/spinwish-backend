package com.spinwish.backend.services;

import com.spinwish.backend.entities.Request;
import com.spinwish.backend.entities.payments.RequestsPayment;
import com.spinwish.backend.entities.payments.Refund;
import com.spinwish.backend.repositories.RequestsPaymentRepository;
import com.spinwish.backend.repositories.RefundRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

/**
 * Service for handling refunds for rejected song requests
 */
@Service
@Slf4j
public class RefundService {

    @Autowired
    private RequestsPaymentRepository requestsPaymentRepository;

    @Autowired
    private RefundRepository refundRepository;

    /**
     * Process refund for a rejected request
     * This method initiates a refund for the payment associated with a rejected request
     * 
     * @param request The rejected request
     * @return true if refund was processed successfully, false otherwise
     */
    @Transactional
    public boolean processRefundForRejectedRequest(Request request) {
        try {
            log.info("🔄 Processing refund for rejected request ID: {}", request.getId());

            // Find the payment associated with this request
            Optional<RequestsPayment> paymentOpt = findPaymentByRequestId(request.getId());
            
            if (paymentOpt.isEmpty()) {
                log.warn("⚠️ No payment found for request ID: {}. Request may not have been paid yet.", request.getId());
                return false;
            }

            RequestsPayment payment = paymentOpt.get();

            // Check if refund already exists
            if (refundRepository.existsByRequestPayment(payment)) {
                log.warn("⚠️ Refund already exists for payment ID: {}", payment.getId());
                return false;
            }

            // Create refund record
            Refund refund = new Refund();
            refund.setRequestPayment(payment);
            refund.setAmount(payment.getAmount());
            refund.setReason("Song request rejected by DJ");
            refund.setStatus(Refund.RefundStatus.PENDING);
            refund.setInitiatedAt(LocalDateTime.now());
            refund.setRefundMethod("MPESA"); // Default to M-Pesa for now

            // In a real implementation, you would call M-Pesa B2C API here
            // For now, we'll mark it as processing and simulate the refund
            boolean refundSuccess = initiateRefundTransaction(payment, refund);

            if (refundSuccess) {
                refund.setStatus(Refund.RefundStatus.COMPLETED);
                refund.setCompletedAt(LocalDateTime.now());
                refund.setTransactionId("REFUND_" + UUID.randomUUID().toString().substring(0, 8));
                log.info("✅ Refund completed successfully for request ID: {}, Amount: KSH {}", 
                         request.getId(), payment.getAmount());
            } else {
                refund.setStatus(Refund.RefundStatus.FAILED);
                refund.setFailureReason("Failed to process M-Pesa refund");
                log.error("❌ Refund failed for request ID: {}", request.getId());
            }

            refundRepository.save(refund);
            return refundSuccess;

        } catch (Exception e) {
            log.error("❌ Error processing refund for request ID: {}", request.getId(), e);
            return false;
        }
    }

    /**
     * Find payment by request ID
     */
    private Optional<RequestsPayment> findPaymentByRequestId(UUID requestId) {
        return requestsPaymentRepository.findAll().stream()
                .filter(payment -> payment.getRequest() != null && 
                                   payment.getRequest().getId().equals(requestId))
                .findFirst();
    }

    /**
     * Initiate refund transaction via M-Pesa B2C API
     * TODO: Implement actual M-Pesa B2C API integration
     * 
     * @param payment The original payment
     * @param refund The refund record
     * @return true if refund was initiated successfully
     */
    private boolean initiateRefundTransaction(RequestsPayment payment, Refund refund) {
        try {
            log.info("💳 Initiating M-Pesa refund for payment ID: {}, Amount: KSH {}", 
                     payment.getId(), payment.getAmount());

            // TODO: Implement M-Pesa B2C API call here
            // For now, we'll simulate a successful refund
            // In production, you would:
            // 1. Call M-Pesa B2C API with payment.getPhoneNumber() and payment.getAmount()
            // 2. Store the transaction ID from M-Pesa response
            // 3. Handle callback to update refund status

            // Simulate successful refund for now
            return true;

        } catch (Exception e) {
            log.error("❌ Failed to initiate refund transaction: {}", e.getMessage(), e);
            return false;
        }
    }

    /**
     * Get refund status for a request
     */
    public Optional<Refund> getRefundByRequestId(UUID requestId) {
        Optional<RequestsPayment> paymentOpt = findPaymentByRequestId(requestId);
        if (paymentOpt.isEmpty()) {
            return Optional.empty();
        }
        return refundRepository.findByRequestPayment(paymentOpt.get());
    }

    /**
     * Check if a request has been refunded
     */
    public boolean isRequestRefunded(UUID requestId) {
        return getRefundByRequestId(requestId)
                .map(refund -> refund.getStatus() == Refund.RefundStatus.COMPLETED)
                .orElse(false);
    }
}

