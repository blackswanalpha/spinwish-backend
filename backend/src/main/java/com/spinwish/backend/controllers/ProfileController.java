package com.spinwish.backend.controllers;

import com.spinwish.backend.models.requests.users.ProfileRequest;
import com.spinwish.backend.models.responses.users.ProfileResponse;
import com.spinwish.backend.services.ProfileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping(path = "api/v1/profile")
public class ProfileController {
    @Autowired
    private ProfileService profileService;

    @PostMapping
    public ResponseEntity<ProfileResponse> addProfile(
            @ModelAttribute ProfileRequest profileRequest) throws IOException {
        ProfileResponse profileResponse = profileService.createOrUpdateProfile(profileRequest);
        return new ResponseEntity<>(profileResponse, HttpStatus.CREATED);
    }

    @GetMapping
    public ResponseEntity<ProfileResponse> fetchProfile(){
        ProfileResponse profileResponse = profileService.getProfile();
        return new ResponseEntity<>(profileResponse, HttpStatus.OK);
    }

    @PutMapping
    public ResponseEntity<ProfileResponse> updateProfile(
            @ModelAttribute ProfileRequest profileRequest) throws IOException {
        ProfileResponse profileResponse = profileService.createOrUpdateProfile(profileRequest);
        return new ResponseEntity<>(profileResponse, HttpStatus.OK);
    }

    // Payment Methods endpoints
    @GetMapping("/payment-methods")
    public ResponseEntity<Map<String, Object>> getPaymentMethods() {
        // TODO: Implement actual payment methods retrieval
        Map<String, Object> response = new HashMap<>();
        response.put("paymentMethods", new ArrayList<>());
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @PostMapping("/payment-methods")
    public ResponseEntity<Map<String, Object>> addPaymentMethod(@RequestBody Map<String, Object> request) {
        // TODO: Implement actual payment method creation
        Map<String, Object> response = new HashMap<>();
        response.put("id", "temp-id");
        response.put("message", "Payment method functionality not yet implemented");
        return new ResponseEntity<>(response, HttpStatus.NOT_IMPLEMENTED);
    }

    @PutMapping("/payment-methods/{id}/set-default")
    public ResponseEntity<Map<String, Object>> setDefaultPaymentMethod(@PathVariable String id) {
        // TODO: Implement set default payment method
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Set default payment method functionality not yet implemented");
        return new ResponseEntity<>(response, HttpStatus.NOT_IMPLEMENTED);
    }

    @DeleteMapping("/payment-methods/{id}")
    public ResponseEntity<Void> deletePaymentMethod(@PathVariable String id) {
        // TODO: Implement payment method deletion
        return new ResponseEntity<>(HttpStatus.NOT_IMPLEMENTED);
    }

    // Request History endpoints
    @GetMapping("/request-history")
    public ResponseEntity<Map<String, Object>> getRequestHistory(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String status) {
        // TODO: Implement actual request history retrieval
        Map<String, Object> response = new HashMap<>();
        response.put("history", new ArrayList<>());
        response.put("totalPages", 0);
        response.put("currentPage", page);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @GetMapping("/request-history/{id}")
    public ResponseEntity<Map<String, Object>> getRequestHistoryItem(@PathVariable String id) {
        // TODO: Implement actual request history item retrieval
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Request history item functionality not yet implemented");
        return new ResponseEntity<>(response, HttpStatus.NOT_IMPLEMENTED);
    }
}
