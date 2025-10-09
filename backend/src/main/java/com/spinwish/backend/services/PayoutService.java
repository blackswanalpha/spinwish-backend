package com.spinwish.backend.services;

import com.spinwish.backend.entities.Users;
import com.spinwish.backend.entities.payments.PayoutMethod;
import com.spinwish.backend.entities.payments.PayoutRequest;
import com.spinwish.backend.models.requests.payments.AddPayoutMethodRequest;
import com.spinwish.backend.models.requests.payments.CreatePayoutRequest;
import com.spinwish.backend.repositories.PayoutMethodRepository;
import com.spinwish.backend.repositories.PayoutRequestRepository;
import com.spinwish.backend.repositories.UsersRepository;
import com.spinwish.backend.utils.MpesaValidationUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Service
@Slf4j
public class PayoutService {
    
    @Autowired
    private PayoutMethodRepository payoutMethodRepository;
    
    @Autowired
    private PayoutRequestRepository payoutRequestRepository;
    
    @Autowired
    private UsersRepository usersRepository;
    
    @Autowired
    private MpesaValidationUtils mpesaValidationUtils;
    
    private static final double MINIMUM_PAYOUT_AMOUNT = 50.0;
    private static final double MAXIMUM_PAYOUT_AMOUNT = 500000.0;
    
    /**
     * Get current authenticated user
     */
    private Users getCurrentUser() {
        String emailAddress = SecurityContextHolder.getContext().getAuthentication().getName();
        Users user = usersRepository.findByEmailAddress(emailAddress);
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        return user;
    }
    
    /**
     * Add a new payout method
     */
    @Transactional
    public PayoutMethod addPayoutMethod(AddPayoutMethodRequest request) {
        Users user = getCurrentUser();
        
        // Validate DJ role
        if (!"DJ".equals(user.getRole().getRoleName())) {
            throw new RuntimeException("Only DJs can add payout methods");
        }
        
        // Validate request
        validatePayoutMethodRequest(request);
        
        PayoutMethod method = new PayoutMethod();
        method.setUser(user);
        method.setMethodType(request.getMethodType());
        method.setDisplayName(request.getDisplayName());
        method.setNotes(request.getNotes());
        
        if (request.getMethodType() == PayoutMethod.PayoutMethodType.BANK_ACCOUNT) {
            method.setBankName(request.getBankName());
            method.setAccountNumber(request.getAccountNumber());
            method.setAccountHolderName(request.getAccountHolderName());
            method.setBankBranch(request.getBankBranch());
            method.setBankCode(request.getBankCode());
        } else if (request.getMethodType() == PayoutMethod.PayoutMethodType.MPESA) {
            // Validate and format M-Pesa phone number
            String formattedPhone = mpesaValidationUtils.validateAndFormatPhoneNumber(request.getMpesaPhoneNumber());
            method.setMpesaPhoneNumber(formattedPhone);
            method.setMpesaAccountName(request.getMpesaAccountName());
        }
        
        // Handle default setting
        if (request.getSetAsDefault() != null && request.getSetAsDefault()) {
            // Unset any existing default
            payoutMethodRepository.findByUserAndIsDefaultTrue(user)
                .ifPresent(existingDefault -> {
                    existingDefault.setIsDefault(false);
                    payoutMethodRepository.save(existingDefault);
                });
            method.setIsDefault(true);
        } else if (!payoutMethodRepository.existsByUserAndIsDefaultTrue(user)) {
            // If this is the first method, make it default
            method.setIsDefault(true);
        }
        
        return payoutMethodRepository.save(method);
    }
    
    /**
     * Get all payout methods for current user
     */
    public List<PayoutMethod> getPayoutMethods() {
        Users user = getCurrentUser();
        return payoutMethodRepository.findByUserOrderByCreatedAtDesc(user);
    }
    
    /**
     * Get default payout method
     */
    public PayoutMethod getDefaultPayoutMethod() {
        Users user = getCurrentUser();
        return payoutMethodRepository.findByUserAndIsDefaultTrue(user)
            .orElseThrow(() -> new RuntimeException("No default payout method found"));
    }
    
    /**
     * Set a payout method as default
     */
    @Transactional
    public PayoutMethod setDefaultPayoutMethod(UUID methodId) {
        Users user = getCurrentUser();
        
        PayoutMethod method = payoutMethodRepository.findByIdAndUser(methodId, user)
            .orElseThrow(() -> new RuntimeException("Payout method not found"));
        
        // Unset any existing default
        payoutMethodRepository.findByUserAndIsDefaultTrue(user)
            .ifPresent(existingDefault -> {
                existingDefault.setIsDefault(false);
                payoutMethodRepository.save(existingDefault);
            });
        
        method.setIsDefault(true);
        return payoutMethodRepository.save(method);
    }
    
    /**
     * Delete a payout method
     */
    @Transactional
    public void deletePayoutMethod(UUID methodId) {
        Users user = getCurrentUser();
        
        PayoutMethod method = payoutMethodRepository.findByIdAndUser(methodId, user)
            .orElseThrow(() -> new RuntimeException("Payout method not found"));
        
        // Check if there are pending payouts using this method
        List<PayoutRequest> pendingPayouts = payoutRequestRepository.findByUserAndStatusIn(
            user, 
            Arrays.asList(PayoutRequest.PayoutStatus.PENDING, PayoutRequest.PayoutStatus.PROCESSING)
        );
        
        boolean hasMethodInUse = pendingPayouts.stream()
            .anyMatch(p -> p.getPayoutMethod().getId().equals(methodId));
        
        if (hasMethodInUse) {
            throw new RuntimeException("Cannot delete payout method with pending payouts");
        }
        
        payoutMethodRepository.delete(method);
    }
    
    /**
     * Create a payout request
     */
    @Transactional
    public PayoutRequest createPayoutRequest(CreatePayoutRequest request) {
        Users user = getCurrentUser();
        
        // Validate DJ role
        if (!"DJ".equals(user.getRole().getRoleName())) {
            throw new RuntimeException("Only DJs can request payouts");
        }
        
        // Validate amount
        if (request.getAmount() == null || request.getAmount() < MINIMUM_PAYOUT_AMOUNT) {
            throw new RuntimeException("Minimum payout amount is KES " + MINIMUM_PAYOUT_AMOUNT);
        }
        
        if (request.getAmount() > MAXIMUM_PAYOUT_AMOUNT) {
            throw new RuntimeException("Maximum payout amount is KES " + MAXIMUM_PAYOUT_AMOUNT);
        }
        
        // Get payout method
        PayoutMethod method = payoutMethodRepository.findByIdAndUser(request.getPayoutMethodId(), user)
            .orElseThrow(() -> new RuntimeException("Payout method not found"));
        
        // Check available balance (this would integrate with earnings service)
        // For now, we'll skip this check
        
        // Calculate processing fee (2% for demo)
        double processingFee = request.getAmount() * 0.02;
        double netAmount = request.getAmount() - processingFee;
        
        PayoutRequest payoutRequest = new PayoutRequest();
        payoutRequest.setUser(user);
        payoutRequest.setPayoutMethod(method);
        payoutRequest.setAmount(request.getAmount());
        payoutRequest.setProcessingFee(processingFee);
        payoutRequest.setNetAmount(netAmount);
        payoutRequest.setNotes(request.getNotes());
        payoutRequest.setStatus(PayoutRequest.PayoutStatus.PENDING);
        
        // Update last used date on payout method
        method.setLastUsedAt(LocalDateTime.now());
        payoutMethodRepository.save(method);
        
        return payoutRequestRepository.save(payoutRequest);
    }
    
    /**
     * Get payout requests for current user
     */
    public Page<PayoutRequest> getPayoutRequests(Pageable pageable) {
        Users user = getCurrentUser();
        return payoutRequestRepository.findByUserOrderByRequestedAtDesc(user, pageable);
    }
    
    /**
     * Get payout request by ID
     */
    public PayoutRequest getPayoutRequest(UUID requestId) {
        Users user = getCurrentUser();
        PayoutRequest request = payoutRequestRepository.findById(requestId)
            .orElseThrow(() -> new RuntimeException("Payout request not found"));
        
        if (!request.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized access to payout request");
        }
        
        return request;
    }
    
    /**
     * Process a payout request (for admin/system use)
     */
    @Transactional
    public PayoutRequest processPayoutRequest(UUID requestId, String transactionId, String receiptNumber) {
        PayoutRequest request = payoutRequestRepository.findById(requestId)
            .orElseThrow(() -> new RuntimeException("Payout request not found"));
        
        if (request.getStatus() != PayoutRequest.PayoutStatus.PENDING) {
            throw new RuntimeException("Payout request is not in pending status");
        }
        
        request.markAsProcessing();
        payoutRequestRepository.save(request);
        
        // Simulate processing delay
        request.markAsCompleted(transactionId, receiptNumber);
        return payoutRequestRepository.save(request);
    }
    
    /**
     * Validate payout method request
     */
    private void validatePayoutMethodRequest(AddPayoutMethodRequest request) {
        if (request.getMethodType() == null) {
            throw new RuntimeException("Method type is required");
        }
        
        if (request.getDisplayName() == null || request.getDisplayName().trim().isEmpty()) {
            throw new RuntimeException("Display name is required");
        }
        
        if (request.getMethodType() == PayoutMethod.PayoutMethodType.BANK_ACCOUNT) {
            if (request.getBankName() == null || request.getBankName().trim().isEmpty()) {
                throw new RuntimeException("Bank name is required");
            }
            if (request.getAccountNumber() == null || request.getAccountNumber().trim().isEmpty()) {
                throw new RuntimeException("Account number is required");
            }
            if (request.getAccountHolderName() == null || request.getAccountHolderName().trim().isEmpty()) {
                throw new RuntimeException("Account holder name is required");
            }
        } else if (request.getMethodType() == PayoutMethod.PayoutMethodType.MPESA) {
            if (request.getMpesaPhoneNumber() == null || request.getMpesaPhoneNumber().trim().isEmpty()) {
                throw new RuntimeException("M-Pesa phone number is required");
            }
            if (request.getMpesaAccountName() == null || request.getMpesaAccountName().trim().isEmpty()) {
                throw new RuntimeException("M-Pesa account name is required");
            }
        }
    }
}

