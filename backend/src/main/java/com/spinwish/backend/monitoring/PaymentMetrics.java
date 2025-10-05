package com.spinwish.backend.monitoring;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

/**
 * Metrics collection for payment operations
 */
@Component
@RequiredArgsConstructor
public class PaymentMetrics {

    private final MeterRegistry meterRegistry;

    // Counters for payment events
    private static final String PAYMENT_INITIATED = "payment.initiated";
    private static final String PAYMENT_COMPLETED = "payment.completed";
    private static final String PAYMENT_FAILED = "payment.failed";
    private static final String PAYMENT_CANCELLED = "payment.cancelled";
    private static final String CALLBACK_RECEIVED = "payment.callback.received";
    private static final String CALLBACK_PROCESSED = "payment.callback.processed";
    private static final String VALIDATION_ERROR = "payment.validation.error";

    // Timers for performance monitoring
    private static final String STK_PUSH_DURATION = "payment.stk.push.duration";
    private static final String CALLBACK_PROCESSING_DURATION = "payment.callback.processing.duration";
    private static final String PAYMENT_QUERY_DURATION = "payment.query.duration";

    /**
     * Record payment initiation
     */
    public void recordPaymentInitiated(String paymentType) {
        Counter.builder(PAYMENT_INITIATED)
                .tag("type", paymentType)
                .register(meterRegistry)
                .increment();
    }

    /**
     * Record successful payment completion
     */
    public void recordPaymentCompleted(String paymentType, double amount) {
        Counter.builder(PAYMENT_COMPLETED)
                .tag("type", paymentType)
                .register(meterRegistry)
                .increment();

        // Record payment amount distribution
        meterRegistry.summary("payment.amount", "type", paymentType)
                .record(amount);
    }

    /**
     * Record payment failure
     */
    public void recordPaymentFailed(String paymentType, String errorCode) {
        Counter.builder(PAYMENT_FAILED)
                .tag("type", paymentType)
                .tag("error_code", errorCode)
                .register(meterRegistry)
                .increment();
    }

    /**
     * Record payment cancellation
     */
    public void recordPaymentCancelled(String paymentType) {
        Counter.builder(PAYMENT_CANCELLED)
                .tag("type", paymentType)
                .register(meterRegistry)
                .increment();
    }

    /**
     * Record callback received
     */
    public void recordCallbackReceived(String resultCode) {
        Counter.builder(CALLBACK_RECEIVED)
                .tag("result_code", resultCode)
                .register(meterRegistry)
                .increment();
    }

    /**
     * Record callback processing completion
     */
    public void recordCallbackProcessed(boolean success) {
        Counter.builder(CALLBACK_PROCESSED)
                .tag("success", String.valueOf(success))
                .register(meterRegistry)
                .increment();
    }

    /**
     * Record validation error
     */
    public void recordValidationError(String errorType) {
        Counter.builder(VALIDATION_ERROR)
                .tag("error_type", errorType)
                .register(meterRegistry)
                .increment();
    }

    /**
     * Time STK push operation
     */
    public Timer.Sample startStkPushTimer() {
        return Timer.start(meterRegistry);
    }

    /**
     * Stop STK push timer
     */
    public void stopStkPushTimer(Timer.Sample sample, boolean success) {
        sample.stop(Timer.builder(STK_PUSH_DURATION)
                .tag("success", String.valueOf(success))
                .register(meterRegistry));
    }

    /**
     * Time callback processing
     */
    public Timer.Sample startCallbackProcessingTimer() {
        return Timer.start(meterRegistry);
    }

    /**
     * Stop callback processing timer
     */
    public void stopCallbackProcessingTimer(Timer.Sample sample, boolean success) {
        sample.stop(Timer.builder(CALLBACK_PROCESSING_DURATION)
                .tag("success", String.valueOf(success))
                .register(meterRegistry));
    }

    /**
     * Time payment query operation
     */
    public Timer.Sample startPaymentQueryTimer() {
        return Timer.start(meterRegistry);
    }

    /**
     * Stop payment query timer
     */
    public void stopPaymentQueryTimer(Timer.Sample sample, boolean success) {
        sample.stop(Timer.builder(PAYMENT_QUERY_DURATION)
                .tag("success", String.valueOf(success))
                .register(meterRegistry));
    }

    /**
     * Record custom metric
     */
    public void recordCustomMetric(String metricName, String tagKey, String tagValue, double value) {
        meterRegistry.counter(metricName, tagKey, tagValue).increment(value);
    }

    /**
     * Record gauge metric (for current values)
     */
    public void recordGauge(String metricName, String tagKey, String tagValue, double value) {
        meterRegistry.gauge(metricName,
            io.micrometer.core.instrument.Tags.of(tagKey, tagValue),
            value);
    }

    /**
     * Get payment success rate
     */
    public double getPaymentSuccessRate() {
        double completed = getCounterValue(PAYMENT_COMPLETED);
        double failed = getCounterValue(PAYMENT_FAILED);
        double cancelled = getCounterValue(PAYMENT_CANCELLED);
        
        double total = completed + failed + cancelled;
        return total > 0 ? (completed / total) * 100 : 0;
    }

    /**
     * Get average payment processing time
     */
    public double getAverageProcessingTime() {
        Timer timer = meterRegistry.find(STK_PUSH_DURATION).timer();
        return timer != null ? timer.mean(java.util.concurrent.TimeUnit.MILLISECONDS) : 0;
    }

    private double getCounterValue(String counterName) {
        Counter counter = meterRegistry.find(counterName).counter();
        return counter != null ? counter.count() : 0;
    }
}
