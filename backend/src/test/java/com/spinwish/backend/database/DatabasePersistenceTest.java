package com.spinwish.backend.database;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.Statement;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Test to verify database persistence configuration
 */
@SpringBootTest
@ActiveProfiles("dev")
public class DatabasePersistenceTest {

    @Autowired
    private DataSource dataSource;

    @Test
    void testDatabaseIsPersistent() throws Exception {
        try (Connection connection = dataSource.getConnection()) {
            DatabaseMetaData metaData = connection.getMetaData();
            String url = metaData.getURL();
            
            // Verify that we're not using in-memory database
            assertFalse(url.contains("jdbc:h2:mem:"), 
                "Database should not be in-memory. Current URL: " + url);
            
            // Verify that we're using file-based H2 or PostgreSQL
            assertTrue(url.contains("jdbc:h2:file:") || url.contains("jdbc:postgresql:"), 
                "Database should be file-based H2 or PostgreSQL. Current URL: " + url);
            
            System.out.println("Database URL: " + url);
            System.out.println("Database Product: " + metaData.getDatabaseProductName());
        }
    }

    @Test
    @Transactional
    void testDataPersistence() throws Exception {
        try (Connection connection = dataSource.getConnection();
             Statement statement = connection.createStatement()) {
            
            // Create a test table if it doesn't exist
            statement.execute("""
                CREATE TABLE IF NOT EXISTS test_persistence (
                    id BIGINT PRIMARY KEY,
                    test_data VARCHAR(255)
                )
            """);
            
            // Insert test data (using MERGE for H2 compatibility)
            statement.execute("MERGE INTO test_persistence (id, test_data) VALUES (1, 'persistence_test')");
            
            // Verify data exists
            ResultSet resultSet = statement.executeQuery("SELECT test_data FROM test_persistence WHERE id = 1");
            assertTrue(resultSet.next(), "Test data should exist");
            assertEquals("persistence_test", resultSet.getString("test_data"));
            
            System.out.println("Data persistence test passed - data was successfully stored and retrieved");
        }
    }

    @Test
    void testH2FileBasedConfiguration() throws Exception {
        try (Connection connection = dataSource.getConnection()) {
            DatabaseMetaData metaData = connection.getMetaData();
            String url = metaData.getURL();
            
            if (url.contains("h2:file:")) {
                // Verify H2 file-based configuration parameters
                assertTrue(url.contains("DB_CLOSE_DELAY=-1"),
                    "H2 should have DB_CLOSE_DELAY=-1 to keep database open");

                System.out.println("H2 file-based configuration verified successfully");
            } else {
                System.out.println("Using PostgreSQL - H2 configuration test skipped");
            }
        }
    }
}
