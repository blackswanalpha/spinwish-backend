package com.spinwish.backend.utils;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.UUID;

/**
 * Utility class for generating correlation IDs for request tracking
 */
public class CorrelationIdGenerator {
    
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final String ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    private static final int SHORT_ID_LENGTH = 8;
    
    /**
     * Generate a UUID-based correlation ID
     */
    public static String generateUUID() {
        return UUID.randomUUID().toString();
    }
    
    /**
     * Generate a short alphanumeric correlation ID
     */
    public static String generateShort() {
        StringBuilder sb = new StringBuilder(SHORT_ID_LENGTH);
        for (int i = 0; i < SHORT_ID_LENGTH; i++) {
            sb.append(ALPHABET.charAt(RANDOM.nextInt(ALPHABET.length())));
        }
        return sb.toString();
    }
    
    /**
     * Generate a timestamp-based correlation ID
     */
    public static String generateTimestamped() {
        long timestamp = Instant.now().toEpochMilli();
        String randomSuffix = generateShort();
        return timestamp + "-" + randomSuffix;
    }
    
    /**
     * Generate a prefixed correlation ID
     */
    public static String generateWithPrefix(String prefix) {
        return prefix + "-" + generateShort();
    }
    
    /**
     * Generate correlation ID for specific request type
     */
    public static String generateForRequest(String requestType) {
        return generateWithPrefix(requestType.toUpperCase());
    }
    
    /**
     * Validate correlation ID format
     */
    public static boolean isValid(String correlationId) {
        if (correlationId == null || correlationId.trim().isEmpty()) {
            return false;
        }
        
        // Check if it's a valid UUID
        try {
            UUID.fromString(correlationId);
            return true;
        } catch (IllegalArgumentException e) {
            // Not a UUID, check other formats
        }
        
        // Check if it matches our custom formats
        return correlationId.matches("^[A-Z0-9-]+$") && correlationId.length() >= 8;
    }
}
