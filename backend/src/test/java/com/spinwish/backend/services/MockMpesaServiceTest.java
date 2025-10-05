package com.spinwish.backend.services;

import com.spinwish.backend.config.MockMpesaConfig;
import com.spinwish.backend.models.MockPaymentSession;
import com.spinwish.backend.models.responses.payments.MpesaCallbackResponse;
import org.json.JSONObject;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests for MockMpesaService.
 */
@ExtendWith(MockitoExtension.class)
class MockMpesaServiceTest {

    @Mock
    private MockMpesaConfig mockConfig;

    @InjectMocks
    private MockMpesaService mockMpesaService;

    @BeforeEach
    void setUp() {
        // Setup default mock config behavior
        when(mockConfig.getMinDelaySeconds()).thenReturn(5);
        when(mockConfig.getMaxDelaySeconds()).thenReturn(15);
        when(mockConfig.getSuccessRate()).thenReturn(0.85);
        when(mockConfig.isTestNumber("254712345678")).thenReturn(true);
        when(mockConfig.isFailNumber("254745678901")).thenReturn(true);
    }

    @Test
    void testGenerateMockStkPushResponse_Success() throws Exception {
        // Arrange
        String phoneNumber = "254712345678";
        String amount = "100";
        String description = "Test payment";

        // Act
        String response = mockMpesaService.generateMockStkPushResponse(phoneNumber, amount, description);

        // Assert
        assertNotNull(response);
        JSONObject json = new JSONObject(response);
        assertEquals("0", json.getString("ResponseCode"));
        assertTrue(json.has("CheckoutRequestID"));
        assertTrue(json.has("MerchantRequestID"));
        assertEquals("Success. Request accepted for processing", json.getString("ResponseDescription"));
    }

    @Test
    void testGenerateMockStkPushResponse_CreatesSession() throws Exception {
        // Arrange
        String phoneNumber = "254712345678";
        String amount = "100";
        String description = "Test payment";

        // Act
        String response = mockMpesaService.generateMockStkPushResponse(phoneNumber, amount, description);
        JSONObject json = new JSONObject(response);
        String checkoutRequestId = json.getString("CheckoutRequestID");

        // Assert
        List<MockPaymentSession> pending = mockMpesaService.getPendingPayments();
        assertTrue(pending.stream().anyMatch(s -> s.getCheckoutRequestId().equals(checkoutRequestId)));
    }

    @Test
    void testGenerateMockCallback_TestNumber_Success() {
        // Arrange
        String phoneNumber = "254712345678";
        String checkoutRequestId = mockMpesaService.generateMockStkPushResponse(phoneNumber, "100", "Test");
        JSONObject json = new JSONObject(checkoutRequestId);
        String actualCheckoutId = json.getString("CheckoutRequestID");

        // Act
        MpesaCallbackResponse callback = mockMpesaService.generateMockCallback(actualCheckoutId);

        // Assert
        assertNotNull(callback);
        assertNotNull(callback.getBody());
        assertNotNull(callback.getBody().getStkCallback());
        assertEquals(0, callback.getBody().getStkCallback().getResultCode());
        assertEquals("The service request is processed successfully.", 
                     callback.getBody().getStkCallback().getResultDesc());
    }

    @Test
    void testGenerateMockCallback_FailNumber_Failure() {
        // Arrange
        String phoneNumber = "254745678901";
        String response = mockMpesaService.generateMockStkPushResponse(phoneNumber, "100", "Test");
        JSONObject json = new JSONObject(response);
        String checkoutRequestId = json.getString("CheckoutRequestID");

        // Act
        MpesaCallbackResponse callback = mockMpesaService.generateMockCallback(checkoutRequestId);

        // Assert
        assertNotNull(callback);
        assertNotNull(callback.getBody());
        assertNotNull(callback.getBody().getStkCallback());
        assertNotEquals(0, callback.getBody().getStkCallback().getResultCode());
    }

    @Test
    void testGetPendingPayments_ReturnsAllPending() {
        // Arrange
        mockMpesaService.generateMockStkPushResponse("254712345678", "100", "Test 1");
        mockMpesaService.generateMockStkPushResponse("254723456789", "200", "Test 2");

        // Act
        List<MockPaymentSession> pending = mockMpesaService.getPendingPayments();

        // Assert
        assertEquals(2, pending.size());
    }

    @Test
    void testForceCompletePayment_Success() {
        // Arrange
        String response = mockMpesaService.generateMockStkPushResponse("254712345678", "100", "Test");
        JSONObject json = new JSONObject(response);
        String checkoutRequestId = json.getString("CheckoutRequestID");

        // Act
        MpesaCallbackResponse callback = mockMpesaService.forceCompletePayment(checkoutRequestId, true);

        // Assert
        assertNotNull(callback);
        assertEquals(0, callback.getBody().getStkCallback().getResultCode());
    }

    @Test
    void testForceCompletePayment_Failure() {
        // Arrange
        String response = mockMpesaService.generateMockStkPushResponse("254712345678", "100", "Test");
        JSONObject json = new JSONObject(response);
        String checkoutRequestId = json.getString("CheckoutRequestID");

        // Act
        MpesaCallbackResponse callback = mockMpesaService.forceCompletePayment(checkoutRequestId, false);

        // Assert
        assertNotNull(callback);
        assertNotEquals(0, callback.getBody().getStkCallback().getResultCode());
    }

    @Test
    void testRemovePaymentSession() {
        // Arrange
        String response = mockMpesaService.generateMockStkPushResponse("254712345678", "100", "Test");
        JSONObject json = new JSONObject(response);
        String checkoutRequestId = json.getString("CheckoutRequestID");

        // Act
        mockMpesaService.removePaymentSession(checkoutRequestId);
        List<MockPaymentSession> pending = mockMpesaService.getPendingPayments();

        // Assert
        assertTrue(pending.stream().noneMatch(s -> s.getCheckoutRequestId().equals(checkoutRequestId)));
    }

    @Test
    void testClearAllSessions() {
        // Arrange
        mockMpesaService.generateMockStkPushResponse("254712345678", "100", "Test 1");
        mockMpesaService.generateMockStkPushResponse("254723456789", "200", "Test 2");

        // Act
        mockMpesaService.clearAllSessions();
        List<MockPaymentSession> pending = mockMpesaService.getPendingPayments();

        // Assert
        assertEquals(0, pending.size());
    }

    @Test
    void testGenerateMockQueryResponse_ExistingSession() {
        // Arrange
        String response = mockMpesaService.generateMockStkPushResponse("254712345678", "100", "Test");
        JSONObject json = new JSONObject(response);
        String checkoutRequestId = json.getString("CheckoutRequestID");

        // Act
        MpesaCallbackResponse queryResponse = mockMpesaService.generateMockQueryResponse(checkoutRequestId);

        // Assert
        assertNotNull(queryResponse);
        assertNotNull(queryResponse.getBody());
        assertNotNull(queryResponse.getBody().getStkCallback());
    }

    @Test
    void testGenerateMockQueryResponse_NonExistentSession() {
        // Act
        MpesaCallbackResponse queryResponse = mockMpesaService.generateMockQueryResponse("INVALID_ID");

        // Assert
        assertNotNull(queryResponse);
        assertEquals(1037, queryResponse.getBody().getStkCallback().getResultCode());
    }

    @Test
    void testPaymentSession_IsReadyToProcess() throws InterruptedException {
        // Arrange
        when(mockConfig.getMinDelaySeconds()).thenReturn(1);
        when(mockConfig.getMaxDelaySeconds()).thenReturn(1);
        
        String response = mockMpesaService.generateMockStkPushResponse("254712345678", "100", "Test");
        JSONObject json = new JSONObject(response);
        String checkoutRequestId = json.getString("CheckoutRequestID");

        // Act - wait for scheduled time
        Thread.sleep(2000);
        List<MockPaymentSession> pending = mockMpesaService.getPendingPayments();
        MockPaymentSession session = pending.stream()
                .filter(s -> s.getCheckoutRequestId().equals(checkoutRequestId))
                .findFirst()
                .orElse(null);

        // Assert
        assertNotNull(session);
        assertTrue(session.isReadyToProcess());
    }

    @Test
    void testPaymentSession_MarkAsProcessed() {
        // Arrange
        String response = mockMpesaService.generateMockStkPushResponse("254712345678", "100", "Test");
        JSONObject json = new JSONObject(response);
        String checkoutRequestId = json.getString("CheckoutRequestID");
        
        List<MockPaymentSession> pending = mockMpesaService.getPendingPayments();
        MockPaymentSession session = pending.stream()
                .filter(s -> s.getCheckoutRequestId().equals(checkoutRequestId))
                .findFirst()
                .orElse(null);

        // Act
        assertNotNull(session);
        session.markAsProcessed();

        // Assert
        assertTrue(session.isProcessed());
        assertNotNull(session.getProcessedAt());
    }
}

