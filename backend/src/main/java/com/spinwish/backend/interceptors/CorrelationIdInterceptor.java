package com.spinwish.backend.interceptors;

import com.spinwish.backend.utils.CorrelationIdGenerator;
import com.spinwish.backend.utils.ErrorContextHolder;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * Interceptor to handle correlation ID generation and context setup
 */
@Component
@Slf4j
public class CorrelationIdInterceptor implements HandlerInterceptor {
    
    public static final String CORRELATION_ID_HEADER = "X-Correlation-ID";
    public static final String REQUEST_ID_HEADER = "X-Request-ID";
    
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        // Generate or extract correlation ID
        String correlationId = extractCorrelationId(request);
        if (correlationId == null) {
            correlationId = CorrelationIdGenerator.generateForRequest("REQ");
        }
        
        // Set up error context
        ErrorContextHolder.ErrorContext context = new ErrorContextHolder.ErrorContext();
        context.setCorrelationId(correlationId);
        context.setRequestPath(request.getRequestURI());
        context.setRequestMethod(request.getMethod());
        context.setUserAgent(request.getHeader("User-Agent"));
        context.setClientIp(getClientIpAddress(request));
        
        // Extract user information if authenticated
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated() && 
            !"anonymousUser".equals(authentication.getName())) {
            context.setUserId(authentication.getName());
        }
        
        // Extract session ID
        if (request.getSession(false) != null) {
            context.setSessionId(request.getSession().getId());
        }
        
        ErrorContextHolder.setContext(context);
        
        // Add correlation ID to response headers
        response.setHeader(CORRELATION_ID_HEADER, correlationId);
        response.setHeader(REQUEST_ID_HEADER, correlationId);
        
        // Log request start
        log.debug("Request started - Method: {}, Path: {}, CorrelationId: {}, UserId: {}, ClientIP: {}",
                request.getMethod(), request.getRequestURI(), correlationId, 
                context.getUserId(), context.getClientIp());
        
        return true;
    }
    
    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, 
                               Object handler, Exception ex) {
        String correlationId = ErrorContextHolder.getCorrelationId();
        
        // Log request completion
        log.debug("Request completed - Method: {}, Path: {}, Status: {}, CorrelationId: {}",
                request.getMethod(), request.getRequestURI(), response.getStatus(), correlationId);
        
        // Clear context
        ErrorContextHolder.clear();
    }
    
    /**
     * Extract correlation ID from request headers
     */
    private String extractCorrelationId(HttpServletRequest request) {
        // Try different header names
        String correlationId = request.getHeader(CORRELATION_ID_HEADER);
        if (correlationId == null) {
            correlationId = request.getHeader(REQUEST_ID_HEADER);
        }
        if (correlationId == null) {
            correlationId = request.getHeader("X-Trace-ID");
        }
        
        // Validate correlation ID
        if (correlationId != null && CorrelationIdGenerator.isValid(correlationId)) {
            return correlationId;
        }
        
        return null;
    }
    
    /**
     * Get client IP address from request
     */
    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }
        
        return request.getRemoteAddr();
    }
}
