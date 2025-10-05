package com.spinwish.backend.controllers;

import com.spinwish.backend.services.DataPopulationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin/data")
@Tag(name = "Data Population", description = "Admin endpoints for populating test data")
@Slf4j
public class DataPopulationController {

    @Autowired
    private DataPopulationService dataPopulationService;

    @Operation(
            summary = "Populate test data",
            description = "Populate the database with sample DJs, artists, and songs for testing purposes"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Data populated successfully"),
            @ApiResponse(responseCode = "500", description = "Error during data population")
    })
    @PostMapping("/populate")
    public ResponseEntity<Map<String, Object>> populateTestData() {
        try {
            log.info("Received request to populate test data");
            
            dataPopulationService.populateTestData();
            
            Map<String, Object> response = new HashMap<>();
            response.put("message", "Test data populated successfully");
            response.put("djCount", dataPopulationService.getDJCount());
            response.put("songCount", dataPopulationService.getSongCount());
            response.put("artistCount", dataPopulationService.getArtistCount());
            response.put("timestamp", System.currentTimeMillis());
            
            log.info("Test data population completed. DJs: {}, Songs: {}, Artists: {}", 
                    response.get("djCount"), response.get("songCount"), response.get("artistCount"));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error populating test data: ", e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to populate test data");
            errorResponse.put("message", e.getMessage());
            errorResponse.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    @Operation(
            summary = "Get data statistics",
            description = "Get current count of DJs, songs, and artists in the database"
    )
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getDataStats() {
        try {
            Map<String, Object> stats = new HashMap<>();
            stats.put("djCount", dataPopulationService.getDJCount());
            stats.put("songCount", dataPopulationService.getSongCount());
            stats.put("artistCount", dataPopulationService.getArtistCount());
            stats.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(stats);
            
        } catch (Exception e) {
            log.error("Error getting data stats: ", e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to get data statistics");
            errorResponse.put("message", e.getMessage());
            errorResponse.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
}
