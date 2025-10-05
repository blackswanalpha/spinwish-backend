package com.spinwish.backend.exceptions;

/**
 * Base exception class for all payment-related errors
 */
public class PaymentException extends RuntimeException {
    private final String errorCode;
    private final String userMessage;

    public PaymentException(String message) {
        super(message);
        this.errorCode = "PAYMENT_ERROR";
        this.userMessage = "Payment processing failed. Please try again.";
    }

    public PaymentException(String message, String errorCode, String userMessage) {
        super(message);
        this.errorCode = errorCode;
        this.userMessage = userMessage;
    }

    public PaymentException(String message, Throwable cause) {
        super(message, cause);
        this.errorCode = "PAYMENT_ERROR";
        this.userMessage = "Payment processing failed. Please try again.";
    }

    public PaymentException(String message, Throwable cause, String errorCode, String userMessage) {
        super(message, cause);
        this.errorCode = errorCode;
        this.userMessage = userMessage;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public String getUserMessage() {
        return userMessage;
    }
}
