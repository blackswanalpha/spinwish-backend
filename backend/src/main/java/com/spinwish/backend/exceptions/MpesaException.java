package com.spinwish.backend.exceptions;

/**
 * Exception class for M-Pesa specific errors
 */
public class MpesaException extends PaymentException {

    public MpesaException(String message) {
        super(message, "MPESA_ERROR", "M-Pesa payment failed. Please try again.");
    }

    public MpesaException(String message, String userMessage) {
        super(message, "MPESA_ERROR", userMessage);
    }

    public MpesaException(String message, Throwable cause) {
        super(message, cause, "MPESA_ERROR", "M-Pesa payment failed. Please try again.");
    }

    public MpesaException(String message, Throwable cause, String userMessage) {
        super(message, cause, "MPESA_ERROR", userMessage);
    }

    // Specific M-Pesa error scenarios
    public static class NetworkException extends MpesaException {
        public NetworkException(String message, Throwable cause) {
            super(message, cause, "Network connection failed. Please check your internet connection and try again.");
        }
    }

    public static class ValidationException extends MpesaException {
        public ValidationException(String message) {
            super(message, "Invalid payment details. Please check your information and try again.");
        }
    }

    public static class InsufficientFundsException extends MpesaException {
        public InsufficientFundsException() {
            super("Insufficient funds in M-Pesa account", "Insufficient funds. Please top up your M-Pesa account and try again.");
        }
    }

    public static class InvalidPhoneNumberException extends MpesaException {
        public InvalidPhoneNumberException(String phoneNumber) {
            super("Invalid phone number: " + phoneNumber, "Invalid phone number. Please enter a valid Kenyan mobile number.");
        }
    }

    public static class TransactionTimeoutException extends MpesaException {
        public TransactionTimeoutException() {
            super("Transaction timed out", "Transaction timed out. Please try again.");
        }
    }

    public static class DuplicateTransactionException extends MpesaException {
        public DuplicateTransactionException(String transactionId) {
            super("Duplicate transaction: " + transactionId, "This transaction has already been processed.");
        }
    }

    public static class CallbackValidationException extends MpesaException {
        public CallbackValidationException(String message) {
            super("Callback validation failed: " + message, "Payment verification failed. Please contact support.");
        }
    }
}
