package com.spinwish.backend.integration;

import com.spinwish.backend.config.MpesaConfig;
import com.spinwish.backend.models.requests.payments.MpesaRequest;
import com.spinwish.backend.services.PaymentService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Integration tests for M-Pesa Daraja API
 * These tests verify the configuration and basic functionality
 */
@SpringBootTest
@ActiveProfiles("test")
@TestPropertySource(properties = {
    "mpesa.callback-url=http://localhost:8080/api/v1/payment/mpesa/callback"
})
public class MpesaIntegrationTest {

    @Autowired
    private MpesaConfig mpesaConfig;

    @Autowired
    private PaymentService paymentService;

    @Test
    public void testMpesaConfigurationLoaded() {
        // Verify that M-Pesa configuration is properly loaded
        assertNotNull(mpesaConfig.getConsumerKey(), "Consumer key should be loaded");
        assertNotNull(mpesaConfig.getConsumerSecret(), "Consumer secret should be loaded");
        assertNotNull(mpesaConfig.getShortCode(), "Short code should be loaded");
        assertNotNull(mpesaConfig.getPasskey(), "Passkey should be loaded");
        assertNotNull(mpesaConfig.getBaseUrl(), "Base URL should be loaded");
        assertNotNull(mpesaConfig.getTokenUrl(), "Token URL should be loaded");
        assertNotNull(mpesaConfig.getCallbackUrl(), "Callback URL should be loaded");
        
        // Verify sandbox URLs
        assertTrue(mpesaConfig.getBaseUrl().contains("sandbox.safaricom.co.ke"), 
                  "Should use sandbox environment");
        assertTrue(mpesaConfig.getTokenUrl().contains("sandbox.safaricom.co.ke"), 
                  "Should use sandbox environment for token");
    }

    @Test
    public void testMpesaRequestValidation() {
        // Test valid request
        MpesaRequest validRequest = new MpesaRequest();
        validRequest.setPhoneNumber("254712345678");
        validRequest.setAmount("100");
        validRequest.setRequestId("test-request-id");

        assertTrue(validRequest.isRequestPayment(), "Should be identified as request payment");
        assertFalse(validRequest.isTipPayment(), "Should not be identified as tip payment");

        // Test tip payment
        MpesaRequest tipRequest = new MpesaRequest();
        tipRequest.setPhoneNumber("254712345678");
        tipRequest.setAmount("50");
        tipRequest.setDjName("testdj");

        assertFalse(tipRequest.isRequestPayment(), "Should not be identified as request payment");
        assertTrue(tipRequest.isTipPayment(), "Should be identified as tip payment");
    }

    @Test
    public void testPhoneNumberFormatting() {
        MpesaRequest request = new MpesaRequest();
        
        // Test various phone number formats
        String[] phoneNumbers = {
            "0712345678",    // Local format
            "712345678",     // Without leading zero
            "254712345678",  // International format
            "+254712345678"  // With plus sign
        };

        for (String phoneNumber : phoneNumbers) {
            request.setPhoneNumber(phoneNumber);
            // The validation should handle these formats
            assertNotNull(request.getPhoneNumber(), "Phone number should not be null");
        }
    }

    @Test
    public void testAmountValidation() {
        MpesaRequest request = new MpesaRequest();
        request.setPhoneNumber("254712345678");
        
        // Test valid amounts
        String[] validAmounts = {"1", "100", "1000", "50000"};
        for (String amount : validAmounts) {
            request.setAmount(amount);
            assertNotNull(request.getAmount(), "Amount should not be null");
            assertTrue(Double.parseDouble(request.getAmount()) > 0, "Amount should be positive");
        }
    }

    @Test
    public void testCallbackUrlConfiguration() {
        // Verify that callback URL is configurable
        String callbackUrl = mpesaConfig.getCallbackUrl();
        assertNotNull(callbackUrl, "Callback URL should be configured");
        assertTrue(callbackUrl.contains("/api/v1/payment/mpesa/callback"), 
                  "Callback URL should contain the correct endpoint");
    }
}
