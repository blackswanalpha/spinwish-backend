package com.spinwish.backend.interceptors;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.spinwish.backend.utils.ErrorContextHolder;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.util.ContentCachingRequestWrapper;
import org.springframework.web.util.ContentCachingResponseWrapper;

import java.nio.charset.StandardCharsets;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

/**
 * Interceptor for detailed request/response logging
 */
@Component
@Slf4j
@RequiredArgsConstructor
public class RequestLoggingInterceptor implements HandlerInterceptor {
    
    private final ObjectMapper objectMapper;
    
    private static final int MAX_PAYLOAD_LENGTH = 1000;
    
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        if (log.isDebugEnabled()) {
            logRequest(request);
        }
        return true;
    }
    
    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, 
                               Object handler, Exception ex) {
        if (log.isDebugEnabled()) {
            logResponse(request, response, ex);
        }
    }
    
    /**
     * Log incoming request details
     */
    private void logRequest(HttpServletRequest request) {
        String correlationId = ErrorContextHolder.getCorrelationId();
        
        Map<String, Object> requestLog = new HashMap<>();
        requestLog.put("correlationId", correlationId);
        requestLog.put("method", request.getMethod());
        requestLog.put("uri", request.getRequestURI());
        requestLog.put("queryString", request.getQueryString());
        requestLog.put("headers", getHeaders(request));
        requestLog.put("remoteAddr", request.getRemoteAddr());
        requestLog.put("userAgent", request.getHeader("User-Agent"));
        
        // Log request body for POST/PUT requests
        if (request instanceof ContentCachingRequestWrapper && 
            ("POST".equals(request.getMethod()) || "PUT".equals(request.getMethod()))) {
            ContentCachingRequestWrapper wrapper = (ContentCachingRequestWrapper) request;
            byte[] content = wrapper.getContentAsByteArray();
            if (content.length > 0) {
                String body = new String(content, StandardCharsets.UTF_8);
                requestLog.put("body", truncatePayload(body));
            }
        }
        
        try {
            log.debug("Incoming Request: {}", objectMapper.writeValueAsString(requestLog));
        } catch (Exception e) {
            log.debug("Incoming Request: {}", requestLog.toString());
        }
    }
    
    /**
     * Log outgoing response details
     */
    private void logResponse(HttpServletRequest request, HttpServletResponse response, Exception ex) {
        String correlationId = ErrorContextHolder.getCorrelationId();
        
        Map<String, Object> responseLog = new HashMap<>();
        responseLog.put("correlationId", correlationId);
        responseLog.put("method", request.getMethod());
        responseLog.put("uri", request.getRequestURI());
        responseLog.put("status", response.getStatus());
        responseLog.put("contentType", response.getContentType());
        
        // Log response headers
        Map<String, String> responseHeaders = new HashMap<>();
        for (String headerName : response.getHeaderNames()) {
            responseHeaders.put(headerName, response.getHeader(headerName));
        }
        responseLog.put("headers", responseHeaders);
        
        // Log response body for error responses or debug level
        if (response instanceof ContentCachingResponseWrapper) {
            ContentCachingResponseWrapper wrapper = (ContentCachingResponseWrapper) response;
            byte[] content = wrapper.getContentAsByteArray();
            if (content.length > 0 && (response.getStatus() >= 400 || log.isTraceEnabled())) {
                String body = new String(content, StandardCharsets.UTF_8);
                responseLog.put("body", truncatePayload(body));
            }
        }
        
        // Log exception if present
        if (ex != null) {
            responseLog.put("exception", ex.getClass().getSimpleName());
            responseLog.put("exceptionMessage", ex.getMessage());
        }
        
        try {
            if (response.getStatus() >= 400) {
                log.warn("Outgoing Response (Error): {}", objectMapper.writeValueAsString(responseLog));
            } else {
                log.debug("Outgoing Response: {}", objectMapper.writeValueAsString(responseLog));
            }
        } catch (Exception e) {
            log.debug("Outgoing Response: {}", responseLog.toString());
        }
    }
    
    /**
     * Extract headers from request
     */
    private Map<String, String> getHeaders(HttpServletRequest request) {
        Map<String, String> headers = new HashMap<>();
        Enumeration<String> headerNames = request.getHeaderNames();
        
        while (headerNames.hasMoreElements()) {
            String headerName = headerNames.nextElement();
            // Skip sensitive headers
            if (!isSensitiveHeader(headerName)) {
                headers.put(headerName, request.getHeader(headerName));
            }
        }
        
        return headers;
    }
    
    /**
     * Check if header contains sensitive information
     */
    private boolean isSensitiveHeader(String headerName) {
        String lowerCaseName = headerName.toLowerCase();
        return lowerCaseName.contains("authorization") ||
               lowerCaseName.contains("password") ||
               lowerCaseName.contains("token") ||
               lowerCaseName.contains("secret") ||
               lowerCaseName.contains("key");
    }
    
    /**
     * Truncate payload to prevent excessive logging
     */
    private String truncatePayload(String payload) {
        if (payload == null) {
            return null;
        }
        
        if (payload.length() <= MAX_PAYLOAD_LENGTH) {
            return payload;
        }
        
        return payload.substring(0, MAX_PAYLOAD_LENGTH) + "... [truncated]";
    }
}
