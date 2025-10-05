package com.spinwish.backend.services;

import com.spinwish.backend.entities.payments.StkPushSession;
import com.spinwish.backend.models.responses.payments.MpesaCallbackResponse;
import com.spinwish.backend.models.responses.payments.MpesaQueryResponse;
import com.spinwish.backend.repositories.StkPushSessionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
public class MpesaReconciliationService {

    private final StkPushSessionRepository stkPushSessionRepository;
    private final PaymentService mpesaCallbackService;

    @Scheduled(cron = "0 */5 * * * *")
    public void reconcilePendingTransactions() {
        List<StkPushSession> pendingSessions = stkPushSessionRepository.findByStatus("PENDING");

        for (StkPushSession session : pendingSessions) {
            try {
                log.info("Reconciling STK push session: {}", session.getCheckoutRequestId());

                MpesaQueryResponse queryResponse = mpesaCallbackService.queryStkPushStatus(session.getCheckoutRequestId());

                if (queryResponse.getResultCode() == 0) {
                    log.info("Payment confirmed for {}", session.getCheckoutRequestId());

                    // Simulate a callback
                    MpesaCallbackResponse simulatedCallback = mpesaCallbackService.buildCallbackFromQuery(queryResponse, session);

                    // Use existing logic to persist it
                    mpesaCallbackService.saveMpesaTransaction(simulatedCallback);

                    // Update session status
                    session.setStatus("SUCCESS");
                } else if (queryResponse.getResultCode() != 0 && !queryResponse.getResultDesc().toLowerCase().contains("pending")) {
                    log.warn("Payment failed or expired for {}", session.getCheckoutRequestId());
                    session.setStatus("FAILED");
                }

                stkPushSessionRepository.save(session);
            } catch (Exception e) {
                log.error("Error reconciling checkout ID {}: {}", session.getCheckoutRequestId(), e.getMessage());
            }
        }
    }
}
