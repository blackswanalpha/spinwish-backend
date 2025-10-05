package com.spinwish.backend.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.spinwish.backend.interceptors.CorrelationIdInterceptor;
import com.spinwish.backend.interceptors.RequestLoggingInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.filter.CommonsRequestLoggingFilter;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Web configuration for interceptors, CORS, and request logging
 */
@Configuration
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {
    
    private final CorrelationIdInterceptor correlationIdInterceptor;
    private final ObjectMapper objectMapper;
    
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // Add correlation ID interceptor first
        registry.addInterceptor(correlationIdInterceptor)
                .addPathPatterns("/api/**")
                .order(1);
        
        // Add request logging interceptor
        registry.addInterceptor(new RequestLoggingInterceptor(objectMapper))
                .addPathPatterns("/api/**")
                .excludePathPatterns("/api/v1/health", "/api/v1/metrics")
                .order(2);
    }
    
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOriginPatterns("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH")
                .allowedHeaders("*")
                .allowCredentials(true)
                .exposedHeaders("X-Correlation-ID", "X-Request-ID", "Authorization")
                .maxAge(3600);

        // Add CORS mapping for WebSocket endpoints
        registry.addMapping("/ws/**")
                .allowedOriginPatterns("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }
    
    /**
     * Configure request logging filter for detailed request/response logging
     */
    @Bean
    public CommonsRequestLoggingFilter requestLoggingFilter() {
        CommonsRequestLoggingFilter filter = new CommonsRequestLoggingFilter();
        filter.setIncludeClientInfo(true);
        filter.setIncludeQueryString(true);
        filter.setIncludePayload(true);
        filter.setIncludeHeaders(false); // Handled by our custom interceptor
        filter.setMaxPayloadLength(1000);
        filter.setAfterMessagePrefix("REQUEST DATA: ");
        return filter;
    }
}
