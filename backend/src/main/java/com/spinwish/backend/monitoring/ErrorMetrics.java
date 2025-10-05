package com.spinwish.backend.monitoring;

import com.spinwish.backend.enums.ErrorCode;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Component for tracking error metrics and monitoring
 */
@Component
@Slf4j
@RequiredArgsConstructor
public class ErrorMetrics {
    
    private final MeterRegistry meterRegistry;
    private final ConcurrentHashMap<String, Counter> errorCounters = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<String, Timer> errorTimers = new ConcurrentHashMap<>();
    private final AtomicLong totalErrors = new AtomicLong(0);
    
    /**
     * Record an error occurrence
     */
    public void recordError(ErrorCode errorCode, String endpoint, int httpStatus) {
        // Increment total error count
        totalErrors.incrementAndGet();
        
        // Record error by type
        getErrorCounter("error.type", errorCode.name()).increment();
        
        // Record error by HTTP status
        getErrorCounter("error.status", String.valueOf(httpStatus)).increment();
        
        // Record error by endpoint
        if (endpoint != null) {
            getErrorCounter("error.endpoint", sanitizeEndpoint(endpoint)).increment();
        }
        
        // Record error by category
        String category = getErrorCategory(errorCode);
        getErrorCounter("error.category", category).increment();
        
        log.debug("Recorded error metric - Code: {}, Status: {}, Endpoint: {}, Category: {}", 
                 errorCode, httpStatus, endpoint, category);
    }
    
    /**
     * Record error resolution time
     */
    public void recordErrorResolutionTime(ErrorCode errorCode, Duration duration) {
        getErrorTimer("error.resolution.time", errorCode.name()).record(duration);
    }
    
    /**
     * Record retry attempt
     */
    public void recordRetryAttempt(ErrorCode errorCode) {
        getErrorCounter("error.retry", errorCode.name()).increment();
    }
    
    /**
     * Record correlation ID usage
     */
    public void recordCorrelationIdUsage(String correlationId) {
        if (correlationId != null && !correlationId.isEmpty()) {
            getErrorCounter("correlation.id.usage", "generated").increment();
        }
    }
    
    /**
     * Get current error statistics
     */
    public ErrorStatistics getErrorStatistics() {
        return ErrorStatistics.builder()
                .totalErrors(totalErrors.get())
                .errorsByType(getCounterValues("error.type"))
                .errorsByStatus(getCounterValues("error.status"))
                .errorsByCategory(getCounterValues("error.category"))
                .build();
    }
    
    /**
     * Get or create error counter
     */
    private Counter getErrorCounter(String name, String tag) {
        String key = name + ":" + tag;
        return errorCounters.computeIfAbsent(key, k -> 
            Counter.builder(name)
                   .tag("type", tag)
                   .description("Count of errors by " + name)
                   .register(meterRegistry));
    }
    
    /**
     * Get or create error timer
     */
    private Timer getErrorTimer(String name, String tag) {
        String key = name + ":" + tag;
        return errorTimers.computeIfAbsent(key, k ->
            Timer.builder(name)
                 .tag("type", tag)
                 .description("Timer for " + name)
                 .register(meterRegistry));
    }
    
    /**
     * Get error category from error code
     */
    private String getErrorCategory(ErrorCode errorCode) {
        String codeName = errorCode.name();
        if (codeName.startsWith("AUTH_")) return "authentication";
        if (codeName.startsWith("USER_")) return "user_management";
        if (codeName.startsWith("VAL_")) return "validation";
        if (codeName.startsWith("BIZ_")) return "business_logic";
        if (codeName.startsWith("PAY_")) return "payment";
        if (codeName.startsWith("FILE_")) return "file_handling";
        if (codeName.startsWith("NET_")) return "network";
        if (codeName.startsWith("RATE_")) return "rate_limiting";
        if (codeName.startsWith("SYS_")) return "system";
        if (codeName.startsWith("DATA_")) return "data_integrity";
        return "unknown";
    }
    
    /**
     * Sanitize endpoint for metrics
     */
    private String sanitizeEndpoint(String endpoint) {
        if (endpoint == null) return "unknown";
        
        // Replace path parameters with placeholders
        return endpoint
                .replaceAll("/\\d+", "/{id}")
                .replaceAll("/[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}", "/{uuid}")
                .replaceAll("/[a-zA-Z0-9_-]{8,}", "/{param}");
    }
    
    /**
     * Get counter values for a specific metric name
     */
    private java.util.Map<String, Double> getCounterValues(String metricName) {
        return errorCounters.entrySet().stream()
                .filter(entry -> entry.getKey().startsWith(metricName + ":"))
                .collect(java.util.stream.Collectors.toMap(
                    entry -> entry.getKey().substring(metricName.length() + 1),
                    entry -> entry.getValue().count()
                ));
    }
    
    /**
     * Error statistics data structure
     */
    @lombok.Builder
    @lombok.Data
    public static class ErrorStatistics {
        private long totalErrors;
        private java.util.Map<String, Double> errorsByType;
        private java.util.Map<String, Double> errorsByStatus;
        private java.util.Map<String, Double> errorsByCategory;
    }
}
