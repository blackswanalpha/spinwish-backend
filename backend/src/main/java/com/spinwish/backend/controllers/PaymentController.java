package com.spinwish.backend.controllers;

import com.spinwish.backend.models.requests.payments.MpesaRequest;
import com.spinwish.backend.models.responses.payments.MpesaCallbackResponse;
import com.spinwish.backend.models.responses.payments.PaymentResponse;
import com.spinwish.backend.services.PaymentService;
import com.spinwish.backend.services.ReceiptService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping(path = "api/v1/payment")
@Slf4j
public class PaymentController {
    @Autowired
    private PaymentService paymentService;

    @Autowired
    private ReceiptService receiptService;

    @PostMapping("/mpesa/stkpush")
    public ResponseEntity<String> initiateStkPush(@RequestBody MpesaRequest mpesaRequest) {
        try {
            String responsePayload = paymentService.pushStk(mpesaRequest);
            return ResponseEntity.ok(responsePayload);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }

    @PostMapping("/mpesa/callback")
    public ResponseEntity<String> handleCallback(@RequestBody MpesaCallbackResponse payload) {
        paymentService.saveMpesaTransaction(payload);
        System.out.println(payload);
        log.info("Received M-PESA Callback: {}", payload);
        return ResponseEntity.ok("Callback received");
    }

    @GetMapping("/stk/query/{checkoutRequestId}")
    public ResponseEntity<MpesaCallbackResponse> queryStkPush(@PathVariable String checkoutRequestId) {
        try {
            MpesaCallbackResponse response = paymentService.queryStkPush(checkoutRequestId);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @GetMapping
    public ResponseEntity<List<PaymentResponse>> getPayments(){
        List<PaymentResponse> paymentResponse = paymentService.getAllPayments();
        return new ResponseEntity<>(paymentResponse, HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<PaymentResponse> getPayment(UUID id){
        PaymentResponse paymentResponse = paymentService.getPaymentById(id);
        return new ResponseEntity<>(paymentResponse, HttpStatus.OK);
    }

    @GetMapping("/receipt/request/{paymentId}")
    public ResponseEntity<Map<String, Object>> getRequestPaymentReceipt(@PathVariable UUID paymentId) {
        try {
            Map<String, Object> receiptData = paymentService.getRequestPaymentReceipt(paymentId);
            return ResponseEntity.ok(receiptData);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }

    @PostMapping("/payme/demo")
    public ResponseEntity<Map<String, Object>> initiatePaymeDemo(@RequestBody Map<String, Object> request) {
        try {
            String accountNumber = (String) request.get("accountNumber");
            String pin = (String) request.get("pin");
            Double amount = ((Number) request.get("amount")).doubleValue();
            String requestId = (String) request.get("requestId");
            String djName = (String) request.get("djName");

            // Generate demo transaction ID
            String transactionId = "PAYME" + System.currentTimeMillis();

            Map<String, Object> response = Map.of(
                "isSuccess", true,
                "transactionId", transactionId,
                "message", "Demo payment initiated successfully",
                "accountNumber", accountNumber,
                "amount", amount
            );

            log.info("PayMe demo payment initiated: {}", transactionId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("PayMe demo payment failed", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("isSuccess", false, "message", "Payment failed: " + e.getMessage()));
        }
    }

    @GetMapping("/payme/status/{transactionId}")
    public ResponseEntity<Map<String, Object>> queryPaymeStatus(@PathVariable String transactionId) {
        try {
            Map<String, Object> response = Map.of(
                "transactionId", transactionId,
                "isSuccess", true,
                "status", "COMPLETED",
                "message", "Payment completed successfully"
            );
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("isSuccess", false, "message", "Transaction not found"));
        }
    }

    @GetMapping("/requests/dj/{djId}")
    public ResponseEntity<List<Map<String, Object>>> getDjRequestPayments(@PathVariable UUID djId) {
        try {
            List<Map<String, Object>> payments = paymentService.getRequestPaymentsByDjId(djId);
            return ResponseEntity.ok(payments);
        } catch (Exception e) {
            log.error("Failed to get DJ request payments", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @GetMapping("/receipt/tip/{paymentId}")
    public ResponseEntity<Map<String, Object>> getTipPaymentReceipt(@PathVariable UUID paymentId) {
        try {
            Map<String, Object> receiptData = paymentService.getTipPaymentReceipt(paymentId);
            return ResponseEntity.ok(receiptData);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }

    @GetMapping("/receipt/html/request/{paymentId}")
    public ResponseEntity<String> getRequestPaymentReceiptHtml(@PathVariable UUID paymentId) {
        try {
            String htmlReceipt = paymentService.getRequestPaymentReceiptHtml(paymentId);
            return ResponseEntity.ok()
                    .header("Content-Type", "text/html")
                    .body(htmlReceipt);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("<html><body><h1>Receipt not found</h1></body></html>");
        }
    }

    @GetMapping("/receipt/html/tip/{paymentId}")
    public ResponseEntity<String> getTipPaymentReceiptHtml(@PathVariable UUID paymentId) {
        try {
            String htmlReceipt = paymentService.getTipPaymentReceiptHtml(paymentId);
            return ResponseEntity.ok()
                    .header("Content-Type", "text/html")
                    .body(htmlReceipt);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("<html><body><h1>Receipt not found</h1></body></html>");
        }
    }
}
