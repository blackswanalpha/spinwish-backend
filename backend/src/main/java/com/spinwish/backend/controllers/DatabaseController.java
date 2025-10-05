package com.spinwish.backend.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controller for database verification and analysis
 */
@RestController
@RequestMapping("/api/v1/database")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Database", description = "Database verification and analysis endpoints")
public class DatabaseController {

    private final DataSource dataSource;
    
    @Operation(
        summary = "Verify database connection",
        description = "Test PostgreSQL database connection and return connection details"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Database connection verified successfully"),
        @ApiResponse(responseCode = "500", description = "Database connection failed")
    })
    @GetMapping("/verify")
    public ResponseEntity<Map<String, Object>> verifyDatabase() {
        Map<String, Object> response = new HashMap<>();
        
        try (Connection connection = dataSource.getConnection()) {
            DatabaseMetaData metaData = connection.getMetaData();
            
            // Basic connection info
            response.put("connected", true);
            response.put("databaseProductName", metaData.getDatabaseProductName());
            response.put("databaseProductVersion", metaData.getDatabaseProductVersion());
            response.put("driverName", metaData.getDriverName());
            response.put("driverVersion", metaData.getDriverVersion());
            response.put("url", metaData.getURL());
            response.put("userName", metaData.getUserName());
            response.put("schema", connection.getSchema());
            response.put("catalog", connection.getCatalog());
            
            // Verify it's PostgreSQL
            boolean isPostgreSQL = metaData.getDatabaseProductName().toLowerCase().contains("postgresql");
            response.put("isPostgreSQL", isPostgreSQL);
            
            if (!isPostgreSQL) {
                response.put("warning", "Expected PostgreSQL but connected to: " + metaData.getDatabaseProductName());
            }
            
            // Connection properties
            response.put("autoCommit", connection.getAutoCommit());
            response.put("readOnly", connection.isReadOnly());
            response.put("transactionIsolation", getTransactionIsolationName(connection.getTransactionIsolation()));
            
            response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            response.put("status", "success");
            
            return ResponseEntity.ok(response);
            
        } catch (SQLException e) {
            log.error("Database verification failed", e);
            response.put("connected", false);
            response.put("error", e.getMessage());
            response.put("sqlState", e.getSQLState());
            response.put("errorCode", e.getErrorCode());
            response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            response.put("status", "error");
            
            return ResponseEntity.status(500).body(response);
        }
    }
    
    @Operation(
        summary = "Get database schema information",
        description = "Retrieve information about database tables and their structure"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Schema information retrieved successfully"),
        @ApiResponse(responseCode = "500", description = "Failed to retrieve schema information")
    })
    @GetMapping("/schema")
    public ResponseEntity<Map<String, Object>> getDatabaseSchema() {
        Map<String, Object> response = new HashMap<>();
        
        try (Connection connection = dataSource.getConnection()) {
            DatabaseMetaData metaData = connection.getMetaData();
            
            // Get all tables
            List<Map<String, Object>> tables = new ArrayList<>();
            try (ResultSet tableResultSet = metaData.getTables(null, null, "%", new String[]{"TABLE"})) {
                while (tableResultSet.next()) {
                    Map<String, Object> tableInfo = new HashMap<>();
                    String tableName = tableResultSet.getString("TABLE_NAME");
                    tableInfo.put("name", tableName);
                    tableInfo.put("type", tableResultSet.getString("TABLE_TYPE"));
                    tableInfo.put("schema", tableResultSet.getString("TABLE_SCHEM"));
                    
                    // Get column count
                    try (ResultSet columnResultSet = metaData.getColumns(null, null, tableName, "%")) {
                        int columnCount = 0;
                        while (columnResultSet.next()) {
                            columnCount++;
                        }
                        tableInfo.put("columnCount", columnCount);
                    }
                    
                    // Get record count
                    try (var statement = connection.prepareStatement("SELECT COUNT(*) FROM " + tableName);
                         var resultSet = statement.executeQuery()) {
                        if (resultSet.next()) {
                            tableInfo.put("recordCount", resultSet.getInt(1));
                        }
                    } catch (SQLException e) {
                        tableInfo.put("recordCount", "N/A");
                        tableInfo.put("countError", e.getMessage());
                    }
                    
                    tables.add(tableInfo);
                }
            }
            
            response.put("tables", tables);
            response.put("tableCount", tables.size());
            response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            response.put("status", "success");
            
            return ResponseEntity.ok(response);
            
        } catch (SQLException e) {
            log.error("Failed to retrieve database schema", e);
            response.put("error", e.getMessage());
            response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            response.put("status", "error");
            
            return ResponseEntity.status(500).body(response);
        }
    }
    
    @Operation(
        summary = "Get table details",
        description = "Get detailed information about specific application tables"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Table details retrieved successfully"),
        @ApiResponse(responseCode = "500", description = "Failed to retrieve table details")
    })
    @GetMapping("/tables")
    public ResponseEntity<Map<String, Object>> getTableDetails() {
        Map<String, Object> response = new HashMap<>();
        String[] appTables = {"users", "roles", "artists", "songs", "requests", "clubs", "sessions", "profile", 
                             "request_payments", "tip_payments", "stk_push_sessions", "playback_history"};
        
        try (Connection connection = dataSource.getConnection()) {
            Map<String, Object> tableDetails = new HashMap<>();
            
            for (String tableName : appTables) {
                Map<String, Object> tableInfo = new HashMap<>();
                
                // Check if table exists
                boolean exists = tableExists(connection, tableName);
                tableInfo.put("exists", exists);
                
                if (exists) {
                    // Get record count
                    try (var statement = connection.prepareStatement("SELECT COUNT(*) FROM " + tableName);
                         var resultSet = statement.executeQuery()) {
                        if (resultSet.next()) {
                            tableInfo.put("recordCount", resultSet.getInt(1));
                        }
                    } catch (SQLException e) {
                        tableInfo.put("recordCount", "Error: " + e.getMessage());
                    }
                    
                    // Get column information
                    List<Map<String, Object>> columns = new ArrayList<>();
                    try (ResultSet columnResultSet = connection.getMetaData().getColumns(null, null, tableName, "%")) {
                        while (columnResultSet.next()) {
                            Map<String, Object> columnInfo = new HashMap<>();
                            columnInfo.put("name", columnResultSet.getString("COLUMN_NAME"));
                            columnInfo.put("type", columnResultSet.getString("TYPE_NAME"));
                            columnInfo.put("size", columnResultSet.getInt("COLUMN_SIZE"));
                            columnInfo.put("nullable", columnResultSet.getBoolean("NULLABLE"));
                            columns.add(columnInfo);
                        }
                    }
                    tableInfo.put("columns", columns);
                    tableInfo.put("columnCount", columns.size());
                }
                
                tableDetails.put(tableName, tableInfo);
            }
            
            response.put("tables", tableDetails);
            response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            response.put("status", "success");
            
            return ResponseEntity.ok(response);
            
        } catch (SQLException e) {
            log.error("Failed to retrieve table details", e);
            response.put("error", e.getMessage());
            response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            response.put("status", "error");
            
            return ResponseEntity.status(500).body(response);
        }
    }
    
    private boolean tableExists(Connection connection, String tableName) {
        try (ResultSet resultSet = connection.getMetaData().getTables(null, null, tableName, null)) {
            return resultSet.next();
        } catch (SQLException e) {
            return false;
        }
    }
    
    private String getTransactionIsolationName(int level) {
        return switch (level) {
            case Connection.TRANSACTION_NONE -> "NONE";
            case Connection.TRANSACTION_READ_UNCOMMITTED -> "READ_UNCOMMITTED";
            case Connection.TRANSACTION_READ_COMMITTED -> "READ_COMMITTED";
            case Connection.TRANSACTION_REPEATABLE_READ -> "REPEATABLE_READ";
            case Connection.TRANSACTION_SERIALIZABLE -> "SERIALIZABLE";
            default -> "UNKNOWN (" + level + ")";
        };
    }


}
