package com.spinwish.backend.controllers;

import com.spinwish.backend.entities.payments.PayoutMethod;
import com.spinwish.backend.entities.payments.PayoutRequest;
import com.spinwish.backend.models.requests.payments.AddPayoutMethodRequest;
import com.spinwish.backend.models.requests.payments.CreatePayoutRequest;
import com.spinwish.backend.models.responses.payments.PayoutMethodResponse;
import com.spinwish.backend.models.responses.payments.PayoutRequestResponse;
import com.spinwish.backend.services.PayoutService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping(path = "api/v1/payouts")
@Tag(name = "Payout Management", description = "APIs for managing DJ payout methods and requests")
@Slf4j
public class PayoutController {
    
    @Autowired
    private PayoutService payoutService;
    
    // ==================== Payout Methods ====================
    
    @Operation(
        summary = "Add payout method",
        description = "Add a new payout method (bank account or M-Pesa) for the current DJ",
        security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @PostMapping("/methods")
    public ResponseEntity<?> addPayoutMethod(@RequestBody AddPayoutMethodRequest request) {
        try {
            PayoutMethod method = payoutService.addPayoutMethod(request);
            PayoutMethodResponse response = PayoutMethodResponse.fromEntity(method);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            log.error("Failed to add payout method: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
    
    @Operation(
        summary = "Get payout methods",
        description = "Get all payout methods for the current DJ",
        security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/methods")
    public ResponseEntity<?> getPayoutMethods() {
        try {
            List<PayoutMethod> methods = payoutService.getPayoutMethods();
            List<PayoutMethodResponse> responses = methods.stream()
                .map(PayoutMethodResponse::fromEntity)
                .collect(Collectors.toList());
            return new ResponseEntity<>(responses, HttpStatus.OK);
        } catch (RuntimeException e) {
            log.error("Failed to get payout methods: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
    
    @Operation(
        summary = "Get default payout method",
        description = "Get the default payout method for the current DJ",
        security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/methods/default")
    public ResponseEntity<?> getDefaultPayoutMethod() {
        try {
            PayoutMethod method = payoutService.getDefaultPayoutMethod();
            PayoutMethodResponse response = PayoutMethodResponse.fromEntity(method);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            log.error("Failed to get default payout method: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }
    
    @Operation(
        summary = "Set default payout method",
        description = "Set a payout method as the default for the current DJ",
        security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @PutMapping("/methods/{methodId}/default")
    public ResponseEntity<?> setDefaultPayoutMethod(
        @Parameter(description = "Payout method ID", required = true)
        @PathVariable UUID methodId
    ) {
        try {
            PayoutMethod method = payoutService.setDefaultPayoutMethod(methodId);
            PayoutMethodResponse response = PayoutMethodResponse.fromEntity(method);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            log.error("Failed to set default payout method: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
    
    @Operation(
        summary = "Delete payout method",
        description = "Delete a payout method for the current DJ",
        security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @DeleteMapping("/methods/{methodId}")
    public ResponseEntity<?> deletePayoutMethod(
        @Parameter(description = "Payout method ID", required = true)
        @PathVariable UUID methodId
    ) {
        try {
            payoutService.deletePayoutMethod(methodId);
            return ResponseEntity.ok("Payout method deleted successfully");
        } catch (RuntimeException e) {
            log.error("Failed to delete payout method: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
    
    // ==================== Payout Requests ====================
    
    @Operation(
        summary = "Create payout request",
        description = "Create a new payout request for the current DJ",
        security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @PostMapping("/requests")
    public ResponseEntity<?> createPayoutRequest(@RequestBody CreatePayoutRequest request) {
        try {
            PayoutRequest payoutRequest = payoutService.createPayoutRequest(request);
            PayoutRequestResponse response = PayoutRequestResponse.fromEntity(payoutRequest);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            log.error("Failed to create payout request: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
    
    @Operation(
        summary = "Get payout requests",
        description = "Get all payout requests for the current DJ",
        security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/requests")
    public ResponseEntity<?> getPayoutRequests(
        @Parameter(description = "Page number", required = false)
        @RequestParam(defaultValue = "0") int page,
        @Parameter(description = "Page size", required = false)
        @RequestParam(defaultValue = "20") int size
    ) {
        try {
            Pageable pageable = PageRequest.of(page, size);
            Page<PayoutRequest> requests = payoutService.getPayoutRequests(pageable);
            Page<PayoutRequestResponse> responses = requests.map(PayoutRequestResponse::fromEntity);
            return new ResponseEntity<>(responses, HttpStatus.OK);
        } catch (RuntimeException e) {
            log.error("Failed to get payout requests: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
    
    @Operation(
        summary = "Get payout request",
        description = "Get a specific payout request by ID",
        security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/requests/{requestId}")
    public ResponseEntity<?> getPayoutRequest(
        @Parameter(description = "Payout request ID", required = true)
        @PathVariable UUID requestId
    ) {
        try {
            PayoutRequest request = payoutService.getPayoutRequest(requestId);
            PayoutRequestResponse response = PayoutRequestResponse.fromEntity(request);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            log.error("Failed to get payout request: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }
    
    @Operation(
        summary = "Process payout request (Demo)",
        description = "Process a payout request using PayMe simulation",
        security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @PostMapping("/requests/{requestId}/process")
    public ResponseEntity<?> processPayoutRequest(
        @Parameter(description = "Payout request ID", required = true)
        @PathVariable UUID requestId
    ) {
        try {
            // Generate demo transaction ID
            String transactionId = "PAYME" + System.currentTimeMillis();
            String receiptNumber = "RCP" + System.currentTimeMillis();
            
            PayoutRequest request = payoutService.processPayoutRequest(requestId, transactionId, receiptNumber);
            PayoutRequestResponse response = PayoutRequestResponse.fromEntity(request);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            log.error("Failed to process payout request: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
}

