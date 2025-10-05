package com.spinwish.backend.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.spinwish.backend.config.MpesaConfig;
import com.spinwish.backend.entities.payments.RequestsPayment;
import com.spinwish.backend.entities.Users;
import com.spinwish.backend.entities.payments.StkPushSession;
import com.spinwish.backend.entities.payments.TipPayments;
import com.spinwish.backend.exceptions.MpesaException;
import com.spinwish.backend.models.requests.payments.MpesaRequest;
import com.spinwish.backend.models.responses.payments.MpesaCallbackResponse;
import com.spinwish.backend.models.responses.payments.MpesaQueryResponse;
import com.spinwish.backend.models.responses.payments.PaymentResponse;
import com.spinwish.backend.repositories.*;
import com.spinwish.backend.utils.MpesaValidationUtils;
import com.spinwish.backend.monitoring.PaymentMetrics;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.SocketTimeoutException;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@Slf4j
public class PaymentService {

    private final MpesaConfig mpesaConfig;

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private RequestsRepository requestRepository;

    @Autowired
    private UsersRepository userRepository;

    @Autowired
    private StkPushSessionRepository stkPushSessionRepository;

    @Autowired
    private RequestsPaymentRepository requestsPaymentRepository;

    @Autowired
    private TipPaymentsRepository tipPaymentsRepository;

    @Autowired
    private MpesaValidationUtils validationUtils;

    @Autowired
    private ReceiptService receiptService;

    @Autowired
    private PaymentMetrics paymentMetrics;

    @Autowired
    private PaymentEventLogService eventLogService;

    public PaymentService(MpesaConfig mpesaConfig) {
        this.mpesaConfig = mpesaConfig;
    }



    @Transactional
    public String pushStk(MpesaRequest mpesaRequest) throws IOException {
        var timer = paymentMetrics.startStkPushTimer();
        String paymentType = mpesaRequest.isRequestPayment() ? "REQUEST" : "TIP";

        try {
            // Record payment initiation
            paymentMetrics.recordPaymentInitiated(paymentType);

            // Validate input parameters
            validateMpesaRequest(mpesaRequest);

            // Require authenticated user
            String emailAddress = SecurityContextHolder.getContext().getAuthentication().getName();
            Users payer = userRepository.findByEmailAddress(emailAddress);

            if (payer == null) {
                throw new MpesaException.ValidationException("User not found");
            }

            String accessToken = getAccessToken();

        JSONObject payload = new JSONObject();
        payload.put("BusinessShortCode", mpesaConfig.getShortCode());
        payload.put("Password", generatePassword());
        payload.put("Timestamp", getTimestamp());
        payload.put("TransactionType", "CustomerPayBillOnline");
        payload.put("Amount", mpesaRequest.getAmount());
        payload.put("PartyA", mpesaRequest.getPhoneNumber());
        payload.put("PartyB", mpesaConfig.getShortCode());
        payload.put("PhoneNumber", mpesaRequest.getPhoneNumber());
        payload.put("CallBackURL", mpesaConfig.getCallbackUrl());
        payload.put("AccountReference", "SpinWish");

        // Transaction description and type handling
        String transactionDesc;
        StkPushSession session = new StkPushSession();

        if (mpesaRequest.isRequestPayment()) {
            UUID requestUuid = mpesaRequest.getRequestIdAsUuid();
            if (requestUuid == null) {
                throw new MpesaException.ValidationException("Invalid request ID format");
            }
            transactionDesc = "Payment for request " + mpesaRequest.getRequestId();
            session.setRequest(requestRepository.findById(requestUuid).orElseThrow(
                () -> new MpesaException.ValidationException("Request not found: " + requestUuid)
            ));
        } else if (mpesaRequest.isTipPayment()) {
            transactionDesc = "Tip for DJ " + mpesaRequest.getDjName();
            session.setDj(userRepository.findByActualUsernameIgnoreCase(mpesaRequest.getDjName()).orElseThrow(
                () -> new MpesaException.ValidationException("DJ not found: " + mpesaRequest.getDjName())
            ));
        } else {
            throw new MpesaException.ValidationException("Either requestId or djName must be provided");
        }

        payload.put("TransactionDesc", transactionDesc);

        // Send request to Safaricom
        HttpURLConnection conn = (HttpURLConnection) new URL(mpesaConfig.getBaseUrl()).openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        conn.setRequestProperty("Content-Type", "application/json");
        conn.getOutputStream().write(payload.toString().getBytes());

        BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        StringBuilder response = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            response.append(line);
        }

        JSONObject json = new JSONObject(response.toString());
        String checkoutRequestId = json.getString("CheckoutRequestID");

        // Save STK Push Session
        session.setCheckoutRequestId(checkoutRequestId);
        session.setPhoneNumber(mpesaRequest.getPhoneNumber());
        session.setAmount(Double.valueOf(mpesaRequest.getAmount()));
        session.setPayer(payer);
        stkPushSessionRepository.save(session);

        paymentMetrics.stopStkPushTimer(timer, true);
        return response.toString();

        } catch (SocketTimeoutException e) {
            paymentMetrics.stopStkPushTimer(timer, false);
            paymentMetrics.recordPaymentFailed(paymentType, "TIMEOUT");
            log.error("M-Pesa API timeout: {}", e.getMessage());
            throw new MpesaException.NetworkException("Request timeout", e);
        } catch (IOException e) {
            paymentMetrics.stopStkPushTimer(timer, false);
            paymentMetrics.recordPaymentFailed(paymentType, "NETWORK_ERROR");
            log.error("M-Pesa API network error: {}", e.getMessage());
            throw new MpesaException.NetworkException("Network error", e);
        } catch (MpesaException e) {
            paymentMetrics.stopStkPushTimer(timer, false);
            paymentMetrics.recordValidationError(e.getClass().getSimpleName());
            log.error("M-Pesa validation error: {}", e.getMessage());
            throw e;
        } catch (Exception e) {
            paymentMetrics.stopStkPushTimer(timer, false);
            paymentMetrics.recordPaymentFailed(paymentType, "UNEXPECTED_ERROR");
            log.error("Unexpected error during STK push: {}", e.getMessage(), e);
            throw new MpesaException("Unexpected error occurred", e);
        }
    }

    /**
     * Validate M-Pesa request parameters
     */
    private void validateMpesaRequest(MpesaRequest mpesaRequest) {
        if (mpesaRequest == null) {
            throw new MpesaException.ValidationException("M-Pesa request cannot be null");
        }

        // Validate that either requestId or djName is provided
        if (!mpesaRequest.isRequestPayment() && !mpesaRequest.isTipPayment()) {
            throw new MpesaException.ValidationException("Either requestId or djName must be provided");
        }

        // Validate phone number
        String validatedPhone = validationUtils.validateAndFormatPhoneNumber(mpesaRequest.getPhoneNumber());
        mpesaRequest.setPhoneNumber(validatedPhone);

        // Validate amount
        Double amount = Double.valueOf(mpesaRequest.getAmount());
        validationUtils.validateTransactionAmount(amount);

        // Validate business short code
        validationUtils.validateBusinessShortCode(mpesaConfig.getShortCode());

        log.info("M-Pesa request validation passed for phone: {}, amount: {}, type: {}",
                validatedPhone, amount, mpesaRequest.isRequestPayment() ? "REQUEST" : "TIP");
    }

    private String generatePassword() {
        String timestamp = getTimestamp();
        String raw = mpesaConfig.getShortCode() + mpesaConfig.getPasskey() + timestamp;
        return Base64.getEncoder().encodeToString(raw.getBytes());
    }

    private String getTimestamp() {
        return new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
    }

    public String getAccessToken() throws IOException {
        String credentials = mpesaConfig.getConsumerKey() + ":" + mpesaConfig.getConsumerSecret();
        String encoded = Base64.getEncoder().encodeToString(credentials.getBytes());

        HttpURLConnection conn = (HttpURLConnection) new URL(mpesaConfig.getTokenUrl()).openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Basic " + encoded);

        try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
            StringBuilder result = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                result.append(line);
            }
            JSONObject json = new JSONObject(result.toString());
            return json.getString("access_token");
        }
    }

    @Transactional
    public void saveMpesaTransaction(MpesaCallbackResponse payload) {
        var timer = paymentMetrics.startCallbackProcessingTimer();

        try {
            // Record callback received
            var callback = payload.getBody().getStkCallback();
            paymentMetrics.recordCallbackReceived(String.valueOf(callback.getResultCode()));

            // Validate callback payload
            validateCallbackPayload(payload);

            log.info("📲 Received STK Callback: {}", callback);

            // Update session status first
            updateSessionStatus(callback.getCheckoutRequestID(), callback.getResultCode());

            // Handle failed transactions
            if (callback.getResultCode() != 0) {
                String paymentType = determinePaymentType(callback.getCheckoutRequestID());
                if (callback.getResultCode() == 1032) {
                    paymentMetrics.recordPaymentCancelled(paymentType);
                } else {
                    paymentMetrics.recordPaymentFailed(paymentType, String.valueOf(callback.getResultCode()));
                }
                log.warn("❌ Transaction failed: {}", callback.getResultDesc());
                paymentMetrics.stopCallbackProcessingTimer(timer, true);
                return;
            }

        String receipt = null, phone = null, transDate = null;
        Double amount = null;

        // Extract values from metadata
        for (var item : callback.getCallbackMetadata().getItem()) {
            switch (item.getName()) {
                case "MpesaReceiptNumber" -> receipt = item.getValue().toString();
                case "PhoneNumber" -> phone = item.getValue().toString();
                case "TransactionDate" -> transDate = item.getValue().toString();
                case "Amount" -> amount = Double.parseDouble(item.getValue().toString());
            }
        }

        if (receipt == null || phone == null || transDate == null || amount == null) {
            log.error("⚠️ Incomplete STK metadata: receipt={}, phone={}, date={}, amount={}", receipt, phone, transDate, amount);
            return;
        }

        String checkoutId = callback.getCheckoutRequestID();
        LocalDateTime date;
        try {
            date = LocalDateTime.parse(transDate, DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        } catch (Exception e) {
            log.error("❌ Failed to parse transaction date: {}", transDate, e);
            return;
        }

        Optional<StkPushSession> sessionOpt = stkPushSessionRepository.findByCheckoutRequestId(checkoutId);
        if (sessionOpt.isEmpty()) {
            log.error("❌ No STK session found for checkout ID: {}", checkoutId);
            return;
        }

        StkPushSession session = sessionOpt.get();

        // Determine type based on presence of request or DJ
        if (session.getRequest() != null) {
            RequestsPayment payment = new RequestsPayment();
            payment.setReceiptNumber(receipt);
            payment.setPhoneNumber(phone);
            payment.setAmount(amount);
            payment.setTransactionDate(date);
            payment.setPayer(session.getPayer());
            payment.setPayerName(session.getPayer() != null ? session.getPayer().getActualUsername() : "M-Pesa User");
            payment.setRequest(session.getRequest());

            requestsPaymentRepository.save(payment);
            paymentMetrics.recordPaymentCompleted("REQUEST", amount);
            log.info("💾 Saved request payment for request ID {}", session.getRequest().getId());

        } else if (session.getDj() != null) {
            TipPayments tip = new TipPayments();
            tip.setReceiptNumber(receipt);
            tip.setPhoneNumber(phone);
            tip.setAmount(amount);
            tip.setTransactionDate(date);
            tip.setPayer(session.getPayer());
            tip.setPayerName(session.getPayer() != null ? session.getPayer().getActualUsername() : "M-Pesa User");
            tip.setDj(session.getDj());

            tipPaymentsRepository.save(tip);
            paymentMetrics.recordPaymentCompleted("TIP", amount);
            log.info("💾 Saved tip payment for DJ ID {}", session.getDj().getId());

        } else {
            log.error("⚠️ STK session found but neither request nor DJ is set. Session ID: {}", session.getId());
        }

        paymentMetrics.stopCallbackProcessingTimer(timer, true);
        paymentMetrics.recordCallbackProcessed(true);

        } catch (Exception e) {
            paymentMetrics.stopCallbackProcessingTimer(timer, false);
            paymentMetrics.recordCallbackProcessed(false);
            log.error("Error processing M-Pesa callback: {}", e.getMessage(), e);
            throw new MpesaException("Failed to process payment callback", e);
        }
    }

    /**
     * Validate M-Pesa callback payload
     */
    private void validateCallbackPayload(MpesaCallbackResponse payload) {
        if (payload == null || payload.getBody() == null || payload.getBody().getStkCallback() == null) {
            throw new MpesaException.CallbackValidationException("Invalid callback payload structure");
        }

        var callback = payload.getBody().getStkCallback();

        // Validate checkout request ID
        validationUtils.validateCheckoutRequestId(callback.getCheckoutRequestID());

        log.debug("Callback payload validation passed for checkout ID: {}", callback.getCheckoutRequestID());
    }

    /**
     * Update STK push session status
     */
    private void updateSessionStatus(String checkoutRequestId, int resultCode) {
        Optional<StkPushSession> sessionOpt = stkPushSessionRepository.findByCheckoutRequestId(checkoutRequestId);

        if (sessionOpt.isPresent()) {
            StkPushSession session = sessionOpt.get();
            String status = resultCode == 0 ? "COMPLETED" : "FAILED";
            session.setStatus(status);
            stkPushSessionRepository.save(session);

            log.info("Updated session status to {} for checkout ID: {}", status, checkoutRequestId);
        } else {
            log.warn("No session found to update for checkout ID: {}", checkoutRequestId);
        }
    }

    /**
     * Determine payment type from checkout request ID
     */
    private String determinePaymentType(String checkoutRequestId) {
        Optional<StkPushSession> sessionOpt = stkPushSessionRepository.findByCheckoutRequestId(checkoutRequestId);
        if (sessionOpt.isPresent()) {
            StkPushSession session = sessionOpt.get();
            return session.getRequest() != null ? "REQUEST" : "TIP";
        }
        return "UNKNOWN";
    }

    public MpesaQueryResponse queryStkPushStatus(String checkoutRequestId) throws IOException {
        String accessToken = getAccessToken();

        HttpURLConnection conn = (HttpURLConnection) new URL(mpesaConfig.getStkQueryUrl()).openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        conn.setRequestProperty("Content-Type", "application/json");

        JSONObject payload = new JSONObject();
        payload.put("BusinessShortCode", mpesaConfig.getShortCode());
        payload.put("Password", generatePassword());
        payload.put("Timestamp", getTimestamp());
        payload.put("CheckoutRequestID", checkoutRequestId);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(payload.toString().getBytes());
        }

        StringBuilder response;
        try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
            response = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                response.append(line);
            }
        }

        return new ObjectMapper().readValue(response.toString(), MpesaQueryResponse.class);
    }

    public MpesaCallbackResponse queryStkPush(String checkoutRequestId) throws IOException {
        Optional<StkPushSession> sessionOpt = stkPushSessionRepository.findByCheckoutRequestId(checkoutRequestId);

        if (sessionOpt.isEmpty()) {
            throw new RuntimeException("No STK session found for checkout ID: " + checkoutRequestId);
        }

        StkPushSession session = sessionOpt.get();

        MpesaQueryResponse queryResponse = queryStkPushStatus(checkoutRequestId); // You should already have this client built
        return buildCallbackFromQuery(queryResponse, session); // Reuse the builder method we worked on
    }


    public MpesaCallbackResponse buildCallbackFromQuery(MpesaQueryResponse query, StkPushSession session) {
        MpesaCallbackResponse response = new MpesaCallbackResponse();

        // Use the nested Item class
        List<MpesaCallbackResponse.Body.StkCallback.CallbackMetadata.Item> items = new ArrayList<>();

        if (query.getAmount() != null) {
            items.add(new MpesaCallbackResponse.Body.StkCallback.CallbackMetadata.Item("Amount", query.getAmount()));
        }
        if (query.getMpesaReceiptNumber() != null) {
            items.add(new MpesaCallbackResponse.Body.StkCallback.CallbackMetadata.Item("MpesaReceiptNumber", query.getMpesaReceiptNumber()));
        }
        if (query.getTransactionDate() != null) {
            items.add(new MpesaCallbackResponse.Body.StkCallback.CallbackMetadata.Item("TransactionDate", Long.parseLong(query.getTransactionDate())));
        }
        if (query.getPhoneNumber() != null) {
            items.add(new MpesaCallbackResponse.Body.StkCallback.CallbackMetadata.Item("PhoneNumber", Long.parseLong(query.getPhoneNumber())));
        }

        MpesaCallbackResponse.Body.StkCallback.CallbackMetadata metadata = new MpesaCallbackResponse.Body.StkCallback.CallbackMetadata();
        metadata.setItem(items);

        MpesaCallbackResponse.Body.StkCallback stkCallback = new MpesaCallbackResponse.Body.StkCallback();
        stkCallback.setMerchantRequestID(query.getMerchantRequestId());
        stkCallback.setCheckoutRequestID(query.getCheckoutRequestID());
        stkCallback.setResultCode(query.getResultCode());
        stkCallback.setResultDesc(query.getResultDesc());
        stkCallback.setCallbackMetadata(metadata);

        MpesaCallbackResponse.Body body = new MpesaCallbackResponse.Body();
        body.setStkCallback(stkCallback);

        response.setBody(body);
        return response;
    }

    public List<PaymentResponse> getAllPayments() {
        List<RequestsPayment> requestPayments = requestsPaymentRepository.findAll();
        List<TipPayments> tipPayments = tipPaymentsRepository.findAll();

        List<PaymentResponse> requestResponses = requestPayments.stream()
                .map(this::convertRequestToResponse)
                .toList();

        List<PaymentResponse> tipResponses = tipPayments.stream()
                .map(this::convertTipToResponse)
                .toList();

        List<PaymentResponse> allResponses = new ArrayList<>();
        allResponses.addAll(requestResponses);
        allResponses.addAll(tipResponses);

        return allResponses;
    }


    public PaymentResponse getPaymentById(UUID id) {
        Optional<RequestsPayment> requestPaymentOpt = requestsPaymentRepository.findById(id);
        if (requestPaymentOpt.isPresent()) {
            return convertRequestToResponse(requestPaymentOpt.get());
        }

        Optional<TipPayments> tipPaymentOpt = tipPaymentsRepository.findById(id);
        // Or throw an exception if preferred
        return tipPaymentOpt.map(this::convertTipToResponse).orElse(null);

    }



    private PaymentResponse convertRequestToResponse(RequestsPayment payment) {
        PaymentResponse response = new PaymentResponse();
        response.setAmount(payment.getAmount());
        response.setPhoneNumber(payment.getPhoneNumber());
        response.setReceiptNumber(payment.getReceiptNumber());
        response.setTransactionDate(payment.getTransactionDate());
        response.setPayerName(payment.getPayerName());
        response.setType("REQUEST");
        response.setRequestId(payment.getRequest().getId());
        return response;
    }

    private PaymentResponse convertTipToResponse(TipPayments tip) {
        PaymentResponse response = new PaymentResponse();
        response.setAmount(tip.getAmount());
        response.setPhoneNumber(tip.getPhoneNumber());
        response.setReceiptNumber(tip.getReceiptNumber());
        response.setTransactionDate(tip.getTransactionDate());
        response.setType("TIP");
        response.setPayerName(tip.getPayerName());
        response.setDjName(tip.getDj().getActualUsername() != null ? tip.getDj().getActualUsername() : null);
        return response;
    }

    /**
     * Get receipt data for request payment
     */
    public Map<String, Object> getRequestPaymentReceipt(UUID paymentId) {
        Optional<RequestsPayment> paymentOpt = requestsPaymentRepository.findById(paymentId);
        if (paymentOpt.isEmpty()) {
            throw new RuntimeException("Request payment not found: " + paymentId);
        }
        return receiptService.generateRequestPaymentReceipt(paymentOpt.get());
    }

    /**
     * Get receipt data for tip payment
     */
    public Map<String, Object> getTipPaymentReceipt(UUID paymentId) {
        Optional<TipPayments> paymentOpt = tipPaymentsRepository.findById(paymentId);
        if (paymentOpt.isEmpty()) {
            throw new RuntimeException("Tip payment not found: " + paymentId);
        }
        return receiptService.generateTipPaymentReceipt(paymentOpt.get());
    }

    /**
     * Get HTML receipt for request payment
     */
    public String getRequestPaymentReceiptHtml(UUID paymentId) {
        Map<String, Object> receiptData = getRequestPaymentReceipt(paymentId);
        return receiptService.generateHtmlReceipt(receiptData);
    }

    /**
     * Get HTML receipt for tip payment
     */
    public String getTipPaymentReceiptHtml(UUID paymentId) {
        Map<String, Object> receiptData = getTipPaymentReceipt(paymentId);
        return receiptService.generateHtmlReceipt(receiptData);
    }

    /**
     * Get all request payments for a specific DJ
     */
    public List<Map<String, Object>> getRequestPaymentsByDjId(UUID djId) {
        List<RequestsPayment> payments = requestsPaymentRepository.findByRequestDjId(djId);

        return payments.stream().map(payment -> {
            Map<String, Object> paymentData = new HashMap<>();
            paymentData.put("id", payment.getId());
            paymentData.put("receiptNumber", payment.getReceiptNumber());
            paymentData.put("payerName", payment.getPayerName());
            paymentData.put("phoneNumber", payment.getPhoneNumber());
            paymentData.put("amount", payment.getAmount());
            paymentData.put("transactionDate", payment.getTransactionDate());

            if (payment.getRequest() != null) {
                Map<String, Object> requestData = new HashMap<>();
                requestData.put("id", payment.getRequest().getId());
                requestData.put("songId", payment.getRequest().getSongId());
                requestData.put("status", payment.getRequest().getStatus());
                requestData.put("message", payment.getRequest().getMessage());
                requestData.put("createdAt", payment.getRequest().getCreatedAt());
                paymentData.put("request", requestData);
            }

            if (payment.getPayer() != null) {
                Map<String, Object> payerData = new HashMap<>();
                payerData.put("id", payment.getPayer().getId());
                payerData.put("username", payment.getPayer().getActualUsername());
                payerData.put("email", payment.getPayer().getEmailAddress());
                paymentData.put("payer", payerData);
            }

            return paymentData;
        }).toList();
    }

}
