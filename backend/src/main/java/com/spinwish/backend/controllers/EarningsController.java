package com.spinwish.backend.controllers;

import com.spinwish.backend.services.EarningsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping(path = "api/v1/earnings")
@Tag(name = "Earnings Management", description = "APIs for managing DJ earnings and payouts")
public class EarningsController {

    @Autowired
    private EarningsService earningsService;

    @Operation(
            summary = "Get DJ earnings summary",
            description = "Get earnings summary for a specific DJ",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Earnings summary retrieved successfully"
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "DJ not found"
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized - JWT token required"
            )
    })
    @GetMapping("/dj/{djId}/summary")
    public ResponseEntity<?> getDJEarningsSummary(
            @Parameter(description = "DJ ID", required = true)
            @PathVariable UUID djId,
            @Parameter(description = "Period (today, week, month, all)", required = false)
            @RequestParam(defaultValue = "month") String period) {
        try {
            EarningsService.EarningsSummary summary = earningsService.getDJEarningsSummary(djId, period);
            return new ResponseEntity<>(summary, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to get earnings summary: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Get current DJ earnings summary",
            description = "Get earnings summary for the currently authenticated DJ",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/me/summary")
    public ResponseEntity<?> getCurrentDJEarningsSummary(
            @Parameter(description = "Period (today, week, month, all)", required = false)
            @RequestParam(defaultValue = "month") String period) {
        try {
            EarningsService.EarningsSummary summary = earningsService.getCurrentDJEarningsSummary(period);
            return new ResponseEntity<>(summary, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to get earnings summary: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Get DJ tip history",
            description = "Get tip payment history for a specific DJ",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/dj/{djId}/tips")
    public ResponseEntity<?> getDJTipHistory(
            @Parameter(description = "DJ ID", required = true)
            @PathVariable UUID djId,
            @Parameter(description = "Page number", required = false)
            @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "Page size", required = false)
            @RequestParam(defaultValue = "20") int size) {
        try {
            var tipHistory = earningsService.getDJTipHistory(djId, page, size);
            return new ResponseEntity<>(tipHistory, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to get tip history: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Get DJ request payment history",
            description = "Get request payment history for a specific DJ",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/dj/{djId}/requests")
    public ResponseEntity<?> getDJRequestPaymentHistory(
            @Parameter(description = "DJ ID", required = true)
            @PathVariable UUID djId,
            @Parameter(description = "Page number", required = false)
            @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "Page size", required = false)
            @RequestParam(defaultValue = "20") int size) {
        try {
            var requestHistory = earningsService.getDJRequestPaymentHistory(djId, page, size);
            return new ResponseEntity<>(requestHistory, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to get request payment history: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Get current DJ tip history",
            description = "Get tip payment history for the currently authenticated DJ",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/me/tips")
    public ResponseEntity<?> getCurrentDJTipHistory(
            @Parameter(description = "Page number", required = false)
            @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "Page size", required = false)
            @RequestParam(defaultValue = "20") int size) {
        try {
            var tipHistory = earningsService.getCurrentDJTipHistory(page, size);
            return new ResponseEntity<>(tipHistory, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to get tip history: " + e.getMessage());
        }
    }

    @Operation(
            summary = "Get current DJ request payment history",
            description = "Get request payment history for the currently authenticated DJ",
            security = @SecurityRequirement(name = "Bearer Authentication")
    )
    @GetMapping("/me/requests")
    public ResponseEntity<?> getCurrentDJRequestPaymentHistory(
            @Parameter(description = "Page number", required = false)
            @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "Page size", required = false)
            @RequestParam(defaultValue = "20") int size) {
        try {
            var requestHistory = earningsService.getCurrentDJRequestPaymentHistory(page, size);
            return new ResponseEntity<>(requestHistory, HttpStatus.OK);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to get request payment history: " + e.getMessage());
        }
    }
}
