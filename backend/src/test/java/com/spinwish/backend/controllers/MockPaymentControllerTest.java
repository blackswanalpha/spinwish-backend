package com.spinwish.backend.controllers;

import com.spinwish.backend.config.MockMpesaConfig;
import com.spinwish.backend.services.MockMpesaService;
import org.json.JSONObject;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.hamcrest.Matchers.*;

/**
 * Integration tests for MockPaymentController.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class MockPaymentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private MockMpesaService mockMpesaService;

    @Autowired
    private MockMpesaConfig mockConfig;

    @BeforeEach
    void setUp() {
        // Clear all sessions before each test
        mockMpesaService.clearAllSessions();
    }

    @Test
    void testGetMockStatus_Success() throws Exception {
        mockMvc.perform(get("/api/v1/mock-payment/status"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.mockEnabled").exists())
                .andExpect(jsonPath("$.autoProcess").exists())
                .andExpect(jsonPath("$.successRate").exists())
                .andExpect(jsonPath("$.pendingPaymentsCount").isNumber());
    }

    @Test
    void testGetPendingPayments_Empty() throws Exception {
        mockMvc.perform(get("/api/v1/mock-payment/pending"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$", hasSize(0)));
    }

    @Test
    void testGetPendingPayments_WithPayments() throws Exception {
        // Arrange - create a mock payment
        mockMpesaService.generateMockStkPushResponse("254712345678", "100", "Test payment");

        // Act & Assert
        mockMvc.perform(get("/api/v1/mock-payment/pending"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].phoneNumber").value("254712345678"))
                .andExpect(jsonPath("$[0].amount").value(100.0));
    }

    @Test
    void testGetPaymentSession_Exists() throws Exception {
        // Arrange
        String response = mockMpesaService.generateMockStkPushResponse("254712345678", "100", "Test");
        JSONObject json = new JSONObject(response);
        String checkoutRequestId = json.getString("CheckoutRequestID");

        // Act & Assert
        mockMvc.perform(get("/api/v1/mock-payment/session/" + checkoutRequestId))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.checkoutRequestId").value(checkoutRequestId))
                .andExpect(jsonPath("$.phoneNumber").value("254712345678"))
                .andExpect(jsonPath("$.amount").value(100.0));
    }

    @Test
    void testGetPaymentSession_NotFound() throws Exception {
        mockMvc.perform(get("/api/v1/mock-payment/session/INVALID_ID"))
                .andExpect(status().isNotFound());
    }

    @Test
    void testApprovePayment_Success() throws Exception {
        // Arrange
        String response = mockMpesaService.generateMockStkPushResponse("254712345678", "100", "Test");
        JSONObject json = new JSONObject(response);
        String checkoutRequestId = json.getString("CheckoutRequestID");

        // Act & Assert
        mockMvc.perform(post("/api/v1/mock-payment/approve/" + checkoutRequestId))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value(containsString("approved")));
    }

    @Test
    void testApprovePayment_NotFound() throws Exception {
        mockMvc.perform(post("/api/v1/mock-payment/approve/INVALID_ID"))
                .andExpect(status().isNotFound());
    }

    @Test
    void testRejectPayment_Success() throws Exception {
        // Arrange
        String response = mockMpesaService.generateMockStkPushResponse("254712345678", "100", "Test");
        JSONObject json = new JSONObject(response);
        String checkoutRequestId = json.getString("CheckoutRequestID");

        // Act & Assert
        mockMvc.perform(post("/api/v1/mock-payment/reject/" + checkoutRequestId))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value(containsString("rejected")));
    }

    @Test
    void testRejectPayment_NotFound() throws Exception {
        mockMvc.perform(post("/api/v1/mock-payment/reject/INVALID_ID"))
                .andExpect(status().isNotFound());
    }

    @Test
    void testSimulateCallback_Success() throws Exception {
        // Arrange
        String response = mockMpesaService.generateMockStkPushResponse("254712345678", "100", "Test");
        JSONObject json = new JSONObject(response);
        String checkoutRequestId = json.getString("CheckoutRequestID");

        // Act & Assert
        mockMvc.perform(post("/api/v1/mock-payment/simulate-callback/" + checkoutRequestId))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.success").value(true));
    }

    @Test
    void testGetTestScenarios_Success() throws Exception {
        mockMvc.perform(get("/api/v1/mock-payment/test-scenarios"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$", hasSize(greaterThan(0))))
                .andExpect(jsonPath("$[0].name").exists())
                .andExpect(jsonPath("$[0].description").exists())
                .andExpect(jsonPath("$[0].phoneNumber").exists())
                .andExpect(jsonPath("$[0].expectedOutcome").exists());
    }

    @Test
    void testClearAllPendingPayments_Success() throws Exception {
        // Arrange - create some payments
        mockMpesaService.generateMockStkPushResponse("254712345678", "100", "Test 1");
        mockMpesaService.generateMockStkPushResponse("254723456789", "200", "Test 2");

        // Act & Assert
        mockMvc.perform(delete("/api/v1/mock-payment/clear-all"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.success").value(true));

        // Verify all cleared
        mockMvc.perform(get("/api/v1/mock-payment/pending"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));
    }

    @Test
    void testEndToEndFlow_AutoApprove() throws Exception {
        // Step 1: Check initial status
        mockMvc.perform(get("/api/v1/mock-payment/status"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.pendingPaymentsCount").value(0));

        // Step 2: Create payment
        String response = mockMpesaService.generateMockStkPushResponse("254712345678", "100", "Test");
        JSONObject json = new JSONObject(response);
        String checkoutRequestId = json.getString("CheckoutRequestID");

        // Step 3: Verify payment is pending
        mockMvc.perform(get("/api/v1/mock-payment/pending"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)));

        // Step 4: Approve payment
        mockMvc.perform(post("/api/v1/mock-payment/approve/" + checkoutRequestId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        // Step 5: Verify payment session marked as processed
        mockMvc.perform(get("/api/v1/mock-payment/session/" + checkoutRequestId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.processed").value(true));
    }

    @Test
    void testEndToEndFlow_Reject() throws Exception {
        // Step 1: Create payment
        String response = mockMpesaService.generateMockStkPushResponse("254712345678", "100", "Test");
        JSONObject json = new JSONObject(response);
        String checkoutRequestId = json.getString("CheckoutRequestID");

        // Step 2: Reject payment
        mockMvc.perform(post("/api/v1/mock-payment/reject/" + checkoutRequestId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        // Step 3: Verify payment session marked as processed
        mockMvc.perform(get("/api/v1/mock-payment/session/" + checkoutRequestId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.processed").value(true))
                .andExpect(jsonPath("$.willSucceed").value(false));
    }

    @Test
    void testMultiplePayments_Concurrent() throws Exception {
        // Create multiple payments
        for (int i = 0; i < 5; i++) {
            mockMpesaService.generateMockStkPushResponse(
                    "25471234567" + i, 
                    String.valueOf(100 + i * 10), 
                    "Test " + i
            );
        }

        // Verify all are pending
        mockMvc.perform(get("/api/v1/mock-payment/pending"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(5)));

        // Verify status shows correct count
        mockMvc.perform(get("/api/v1/mock-payment/status"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.pendingPaymentsCount").value(5));
    }
}

