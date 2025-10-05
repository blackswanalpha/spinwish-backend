package com.spinwish.backend.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "mpesa")
@Getter
@Setter
public class MpesaConfig {
    private String baseUrl;
    private String consumerKey;
    private String consumerSecret;
    private String shortCode;
    private String passkey;
    private String initiatorName;
    private String tokenUrl;
    private String stkQueryUrl;
    private String callbackUrl;
}
