package com.spinwish.backend.utils;

import lombok.Data;
import lombok.experimental.UtilityClass;

import java.util.HashMap;
import java.util.Map;

/**
 * Thread-local context holder for error handling information
 */
@UtilityClass
public class ErrorContextHolder {
    
    private static final ThreadLocal<ErrorContext> CONTEXT_HOLDER = new ThreadLocal<>();
    
    /**
     * Get the current error context
     */
    public static ErrorContext getContext() {
        ErrorContext context = CONTEXT_HOLDER.get();
        if (context == null) {
            context = new ErrorContext();
            CONTEXT_HOLDER.set(context);
        }
        return context;
    }
    
    /**
     * Set the error context
     */
    public static void setContext(ErrorContext context) {
        CONTEXT_HOLDER.set(context);
    }
    
    /**
     * Clear the error context
     */
    public static void clear() {
        CONTEXT_HOLDER.remove();
    }
    
    /**
     * Get correlation ID from context
     */
    public static String getCorrelationId() {
        return getContext().getCorrelationId();
    }
    
    /**
     * Set correlation ID in context
     */
    public static void setCorrelationId(String correlationId) {
        getContext().setCorrelationId(correlationId);
    }
    
    /**
     * Get user ID from context
     */
    public static String getUserId() {
        return getContext().getUserId();
    }
    
    /**
     * Set user ID in context
     */
    public static void setUserId(String userId) {
        getContext().setUserId(userId);
    }
    
    /**
     * Get session ID from context
     */
    public static String getSessionId() {
        return getContext().getSessionId();
    }
    
    /**
     * Set session ID in context
     */
    public static void setSessionId(String sessionId) {
        getContext().setSessionId(sessionId);
    }
    
    /**
     * Add metadata to context
     */
    public static void addMetadata(String key, Object value) {
        getContext().addMetadata(key, value);
    }
    
    /**
     * Get metadata from context
     */
    public static Map<String, Object> getMetadata() {
        return getContext().getMetadata();
    }
    
    /**
     * Error context data structure
     */
    @Data
    public static class ErrorContext {
        private String correlationId;
        private String userId;
        private String sessionId;
        private String requestPath;
        private String requestMethod;
        private String userAgent;
        private String clientIp;
        private Map<String, Object> metadata = new HashMap<>();
        
        public void addMetadata(String key, Object value) {
            this.metadata.put(key, value);
        }
        
        public Object getMetadata(String key) {
            return this.metadata.get(key);
        }
        
        public void clearMetadata() {
            this.metadata.clear();
        }
    }
}
