package com.spinwish.backend.controllers;

import com.spinwish.backend.utils.ErrorContextHolder;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * Health check and monitoring endpoints
 */
@RestController
@RequestMapping("/api/v1/health")
@Tag(name = "Health", description = "Health check and monitoring endpoints")
@Slf4j
@RequiredArgsConstructor
public class HealthController {
    
    private final DataSource dataSource;
    
    @GetMapping
    @Operation(summary = "Basic health check", description = "Returns basic application health status")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("timestamp", LocalDateTime.now());
        health.put("correlationId", ErrorContextHolder.getCorrelationId());
        health.put("version", "1.0.0");
        
        return ResponseEntity.ok(health);
    }
    
    @GetMapping("/detailed")
    @Operation(summary = "Detailed health check", description = "Returns detailed health information including dependencies")
    public ResponseEntity<Map<String, Object>> detailedHealth() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("timestamp", LocalDateTime.now());
        health.put("correlationId", ErrorContextHolder.getCorrelationId());
        
        // Check database connectivity
        Map<String, Object> database = checkDatabase();
        health.put("database", database);
        
        // Check memory usage
        Map<String, Object> memory = checkMemory();
        health.put("memory", memory);
        
        // Check disk space
        Map<String, Object> disk = checkDisk();
        health.put("disk", disk);
        
        // Overall status
        boolean allHealthy = "UP".equals(database.get("status"));
        health.put("status", allHealthy ? "UP" : "DOWN");
        
        return ResponseEntity.ok(health);
    }
    
    @GetMapping("/ready")
    @Operation(summary = "Readiness check", description = "Returns readiness status for load balancers")
    public ResponseEntity<Map<String, Object>> ready() {
        Map<String, Object> readiness = new HashMap<>();
        
        // Check if application is ready to serve requests
        boolean databaseReady = checkDatabaseConnection();
        
        readiness.put("ready", databaseReady);
        readiness.put("timestamp", LocalDateTime.now());
        readiness.put("correlationId", ErrorContextHolder.getCorrelationId());
        
        if (databaseReady) {
            return ResponseEntity.ok(readiness);
        } else {
            return ResponseEntity.status(503).body(readiness);
        }
    }
    
    @GetMapping("/live")
    @Operation(summary = "Liveness check", description = "Returns liveness status for container orchestration")
    public ResponseEntity<Map<String, Object>> live() {
        Map<String, Object> liveness = new HashMap<>();
        liveness.put("alive", true);
        liveness.put("timestamp", LocalDateTime.now());
        liveness.put("correlationId", ErrorContextHolder.getCorrelationId());

        return ResponseEntity.ok(liveness);
    }

    @GetMapping("/ping")
    @Operation(summary = "Simple connectivity test", description = "Simple endpoint to test if the backend is reachable")
    public ResponseEntity<Map<String, String>> ping() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "pong");
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("service", "SpinWish Backend");
        return ResponseEntity.ok(response);
    }
    
    private Map<String, Object> checkDatabase() {
        Map<String, Object> database = new HashMap<>();
        
        try {
            boolean connected = checkDatabaseConnection();
            database.put("status", connected ? "UP" : "DOWN");
            database.put("type", "PostgreSQL");
        } catch (Exception e) {
            database.put("status", "DOWN");
            database.put("error", e.getMessage());
            log.warn("Database health check failed", e);
        }
        
        return database;
    }
    
    private boolean checkDatabaseConnection() {
        try (Connection connection = dataSource.getConnection()) {
            return connection.isValid(5); // 5 second timeout
        } catch (Exception e) {
            log.warn("Database connection check failed", e);
            return false;
        }
    }
    
    private Map<String, Object> checkMemory() {
        Map<String, Object> memory = new HashMap<>();
        
        Runtime runtime = Runtime.getRuntime();
        long maxMemory = runtime.maxMemory();
        long totalMemory = runtime.totalMemory();
        long freeMemory = runtime.freeMemory();
        long usedMemory = totalMemory - freeMemory;
        
        double usagePercentage = (double) usedMemory / maxMemory * 100;
        
        memory.put("max", maxMemory);
        memory.put("total", totalMemory);
        memory.put("used", usedMemory);
        memory.put("free", freeMemory);
        memory.put("usagePercentage", Math.round(usagePercentage * 100.0) / 100.0);
        memory.put("status", usagePercentage < 90 ? "UP" : "WARN");
        
        return memory;
    }
    
    private Map<String, Object> checkDisk() {
        Map<String, Object> disk = new HashMap<>();
        
        try {
            java.io.File root = new java.io.File("/");
            long totalSpace = root.getTotalSpace();
            long freeSpace = root.getFreeSpace();
            long usedSpace = totalSpace - freeSpace;
            
            double usagePercentage = (double) usedSpace / totalSpace * 100;
            
            disk.put("total", totalSpace);
            disk.put("used", usedSpace);
            disk.put("free", freeSpace);
            disk.put("usagePercentage", Math.round(usagePercentage * 100.0) / 100.0);
            disk.put("status", usagePercentage < 85 ? "UP" : "WARN");
        } catch (Exception e) {
            disk.put("status", "UNKNOWN");
            disk.put("error", e.getMessage());
        }
        
        return disk;
    }
}
