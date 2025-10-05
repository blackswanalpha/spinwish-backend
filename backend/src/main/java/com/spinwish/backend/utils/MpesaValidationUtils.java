package com.spinwish.backend.utils;

import com.spinwish.backend.exceptions.MpesaException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.regex.Pattern;

/**
 * Utility class for M-Pesa transaction validation
 */
@Component
@Slf4j
public class MpesaValidationUtils {

    // Kenyan mobile number patterns
    private static final Pattern KENYAN_MOBILE_PATTERN = Pattern.compile("^254[17][0-9]{8}$");
    private static final Pattern KENYAN_MOBILE_WITH_ZERO = Pattern.compile("^0[17][0-9]{8}$");
    
    // M-Pesa transaction limits (in KES)
    private static final double MIN_TRANSACTION_AMOUNT = 1.0;
    private static final double MAX_TRANSACTION_AMOUNT = 300000.0;
    
    // M-Pesa receipt number pattern
    private static final Pattern RECEIPT_PATTERN = Pattern.compile("^[A-Z0-9]{10}$");

    /**
     * Validate and format Kenyan phone number for M-Pesa
     * @param phoneNumber The phone number to validate
     * @return Formatted phone number (254XXXXXXXXX)
     * @throws MpesaException.InvalidPhoneNumberException if invalid
     */
    public String validateAndFormatPhoneNumber(String phoneNumber) {
        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            throw new MpesaException.InvalidPhoneNumberException("Phone number is required");
        }

        // Remove all non-digit characters
        String cleaned = phoneNumber.replaceAll("[^0-9]", "");
        
        // Handle different formats
        String formatted;
        if (cleaned.startsWith("254")) {
            formatted = cleaned;
        } else if (cleaned.startsWith("0")) {
            formatted = "254" + cleaned.substring(1);
        } else if (cleaned.length() == 9) {
            formatted = "254" + cleaned;
        } else {
            throw new MpesaException.InvalidPhoneNumberException(phoneNumber);
        }

        // Validate the formatted number
        if (!KENYAN_MOBILE_PATTERN.matcher(formatted).matches()) {
            throw new MpesaException.InvalidPhoneNumberException(phoneNumber);
        }

        return formatted;
    }

    /**
     * Validate transaction amount
     * @param amount The amount to validate
     * @throws MpesaException.ValidationException if invalid
     */
    public void validateTransactionAmount(Double amount) {
        if (amount == null) {
            throw new MpesaException.ValidationException("Transaction amount is required");
        }

        if (amount < MIN_TRANSACTION_AMOUNT) {
            throw new MpesaException.ValidationException(
                String.format("Minimum transaction amount is KES %.2f", MIN_TRANSACTION_AMOUNT)
            );
        }

        if (amount > MAX_TRANSACTION_AMOUNT) {
            throw new MpesaException.ValidationException(
                String.format("Maximum transaction amount is KES %.2f", MAX_TRANSACTION_AMOUNT)
            );
        }

        // Check for reasonable decimal places (M-Pesa supports up to 2 decimal places)
        if (amount * 100 != Math.floor(amount * 100)) {
            throw new MpesaException.ValidationException("Amount cannot have more than 2 decimal places");
        }
    }

    /**
     * Validate M-Pesa receipt number format
     * @param receiptNumber The receipt number to validate
     * @return true if valid, false otherwise
     */
    public boolean isValidReceiptNumber(String receiptNumber) {
        if (receiptNumber == null || receiptNumber.trim().isEmpty()) {
            return false;
        }
        return RECEIPT_PATTERN.matcher(receiptNumber.trim()).matches();
    }

    /**
     * Validate business short code
     * @param shortCode The business short code to validate
     * @throws MpesaException.ValidationException if invalid
     */
    public void validateBusinessShortCode(String shortCode) {
        if (shortCode == null || shortCode.trim().isEmpty()) {
            throw new MpesaException.ValidationException("Business short code is required");
        }

        // M-Pesa short codes are typically 5-6 digits
        if (!shortCode.matches("^[0-9]{5,6}$")) {
            throw new MpesaException.ValidationException("Invalid business short code format");
        }
    }

    /**
     * Validate checkout request ID format
     * @param checkoutRequestId The checkout request ID to validate
     * @throws MpesaException.ValidationException if invalid
     */
    public void validateCheckoutRequestId(String checkoutRequestId) {
        if (checkoutRequestId == null || checkoutRequestId.trim().isEmpty()) {
            throw new MpesaException.ValidationException("Checkout request ID is required");
        }

        // M-Pesa checkout request IDs are typically in format: ws_CO_DDMMYYYY_HHMMSS_XXXXXXXXX
        if (!checkoutRequestId.matches("^ws_CO_[0-9]{8}_[0-9]{6}_[0-9]+$")) {
            log.warn("Checkout request ID format may be invalid: {}", checkoutRequestId);
        }
    }

    /**
     * Check if phone number belongs to Safaricom network (M-Pesa)
     * @param phoneNumber The phone number to check (should be in 254XXXXXXXXX format)
     * @return true if it's a Safaricom number, false otherwise
     */
    public boolean isSafaricomNumber(String phoneNumber) {
        if (phoneNumber == null || phoneNumber.length() != 12) {
            return false;
        }

        // Safaricom prefixes: 254700-254799, 254110-254115
        String prefix = phoneNumber.substring(0, 6);
        return (prefix.compareTo("254700") >= 0 && prefix.compareTo("254799") <= 0) ||
               (prefix.compareTo("254110") >= 0 && prefix.compareTo("254115") <= 0);
    }

    /**
     * Sanitize account reference for M-Pesa
     * @param accountReference The account reference to sanitize
     * @return Sanitized account reference
     */
    public String sanitizeAccountReference(String accountReference) {
        if (accountReference == null) {
            return "SpinWish";
        }

        // Remove special characters and limit length
        String sanitized = accountReference.replaceAll("[^a-zA-Z0-9\\s]", "").trim();
        
        // Limit to 12 characters (M-Pesa limit)
        if (sanitized.length() > 12) {
            sanitized = sanitized.substring(0, 12);
        }

        return sanitized.isEmpty() ? "SpinWish" : sanitized;
    }
}
