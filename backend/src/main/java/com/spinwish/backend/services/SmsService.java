package com.spinwish.backend.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.HashMap;
import java.util.Map;

@Service
public class SmsService {

    private static final Logger logger = LoggerFactory.getLogger(SmsService.class);

    @Value("${sms.api.url:https://api.africastalking.com/version1/messaging}")
    private String smsApiUrl;

    @Value("${sms.api.key:}")
    private String apiKey;

    @Value("${sms.api.username:}")
    private String username;

    @Value("${sms.sender.id:SpinWish}")
    private String senderId;

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public boolean sendVerificationCode(String phoneNumber, String verificationCode, String userName) {
        try {
            // For development/testing, we'll simulate SMS sending
            if (apiKey.isEmpty() || username.isEmpty()) {
                logger.info("SMS API not configured. Simulating SMS send to: {} with code: {}", 
                    maskPhoneNumber(phoneNumber), verificationCode);
                return true;
            }

            String message = String.format(
                "Hello %s! Your SpinWish verification code is: %s. This code expires in 10 minutes. Do not share this code with anyone.",
                userName, verificationCode
            );

            // Prepare request for Africa's Talking API (example)
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
            headers.set("apiKey", apiKey);

            Map<String, String> requestBody = new HashMap<>();
            requestBody.put("username", username);
            requestBody.put("to", phoneNumber);
            requestBody.put("message", message);
            requestBody.put("from", senderId);

            HttpEntity<Map<String, String>> request = new HttpEntity<>(requestBody, headers);

            // Send SMS
            var response = restTemplate.exchange(smsApiUrl, HttpMethod.POST, request, String.class);
            
            if (response.getStatusCode().is2xxSuccessful()) {
                logger.info("SMS verification code sent successfully to: {}", maskPhoneNumber(phoneNumber));
                return true;
            } else {
                logger.error("Failed to send SMS. Status: {}, Response: {}", 
                    response.getStatusCode(), response.getBody());
                return false;
            }

        } catch (Exception e) {
            logger.error("Failed to send SMS verification code to: {}", maskPhoneNumber(phoneNumber), e);
            return false;
        }
    }

    public boolean sendWelcomeSms(String phoneNumber, String userName) {
        try {
            // For development/testing, we'll simulate SMS sending
            if (apiKey.isEmpty() || username.isEmpty()) {
                logger.info("SMS API not configured. Simulating welcome SMS to: {}", 
                    maskPhoneNumber(phoneNumber));
                return true;
            }

            String message = String.format(
                "Welcome to SpinWish, %s! Your phone number has been verified. Start requesting your favorite songs from DJs now!",
                userName
            );

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
            headers.set("apiKey", apiKey);

            Map<String, String> requestBody = new HashMap<>();
            requestBody.put("username", username);
            requestBody.put("to", phoneNumber);
            requestBody.put("message", message);
            requestBody.put("from", senderId);

            HttpEntity<Map<String, String>> request = new HttpEntity<>(requestBody, headers);

            var response = restTemplate.exchange(smsApiUrl, HttpMethod.POST, request, String.class);
            
            if (response.getStatusCode().is2xxSuccessful()) {
                logger.info("Welcome SMS sent successfully to: {}", maskPhoneNumber(phoneNumber));
                return true;
            } else {
                logger.error("Failed to send welcome SMS. Status: {}, Response: {}", 
                    response.getStatusCode(), response.getBody());
                return false;
            }

        } catch (Exception e) {
            logger.error("Failed to send welcome SMS to: {}", maskPhoneNumber(phoneNumber), e);
            return false;
        }
    }

    private String maskPhoneNumber(String phoneNumber) {
        if (phoneNumber == null || phoneNumber.length() < 4) {
            return "****";
        }
        return phoneNumber.substring(0, 3) + "****" + phoneNumber.substring(phoneNumber.length() - 2);
    }
}
