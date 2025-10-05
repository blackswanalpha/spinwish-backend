package com.spinwish.backend.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.boot.jdbc.DataSourceBuilder;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * Database fallback configuration for intelligent database selection
 * Tries remote PostgreSQL first, then local PostgreSQL, then H2
 */
@Configuration
@Slf4j
public class DatabaseFallbackConfig {

    @Value("${spinwish.database.fallback.enabled:true}")
    private boolean fallbackEnabled;

    // Remote PostgreSQL Configuration
    @Value("${spinwish.database.remote.url:jdbc:postgresql://dpg-d1ulgcemcj7s73el4o9g-a.oregon-postgres.render.com:5432/spinwish}")
    private String remoteUrl;

    @Value("${spinwish.database.remote.username:spinwish_user}")
    private String remoteUsername;

    @Value("${spinwish.database.remote.password:XvoPi9gDsXd2xw81RmQHBKVonIlrC7q5}")
    private String remotePassword;

    @Value("${spinwish.database.remote.driver:org.postgresql.Driver}")
    private String remoteDriver;

    // Local PostgreSQL Configuration
    @Value("${spinwish.database.local.url:jdbc:postgresql://localhost:5432/spinwish_dev}")
    private String localUrl;

    @Value("${spinwish.database.local.username:spinwish_user}")
    private String localUsername;

    @Value("${spinwish.database.local.password:spinwish_password}")
    private String localPassword;

    @Value("${spinwish.database.local.driver:org.postgresql.Driver}")
    private String localDriver;

    /**
     * Test database connection
     */
    private boolean testConnection(String url, String username, String password, String driverClassName) {
        try {
            DataSource testDataSource = DataSourceBuilder.create()
                    .url(url)
                    .username(username)
                    .password(password)
                    .driverClassName(driverClassName)
                    .build();

            try (Connection connection = testDataSource.getConnection()) {
                boolean isValid = connection.isValid(5); // 5 second timeout
                log.info("Database connection test for {}: {}", url, isValid ? "SUCCESS" : "FAILED");
                return isValid;
            }
        } catch (SQLException e) {
            log.warn("Database connection test failed for {}: {}", url, e.getMessage());
            return false;
        }
    }

    /**
     * Smart DataSource configuration for production profile
     * Tries remote PostgreSQL with local fallback
     */
    @Bean
    @Primary
    @Profile("prod")
    public DataSource productionDataSource() {
        log.info("Configuring production DataSource with fallback...");

        if (!fallbackEnabled) {
            log.info("Fallback disabled, using remote PostgreSQL directly");
            return DataSourceBuilder.create()
                    .url(remoteUrl)
                    .username(remoteUsername)
                    .password(remotePassword)
                    .driverClassName(remoteDriver)
                    .build();
        }

        // Test remote connection first
        if (testConnection(remoteUrl, remoteUsername, remotePassword, remoteDriver)) {
            log.info("Using remote PostgreSQL database (Render)");
            return DataSourceBuilder.create()
                    .url(remoteUrl)
                    .username(remoteUsername)
                    .password(remotePassword)
                    .driverClassName(remoteDriver)
                    .build();
        }

        // Fallback to local PostgreSQL
        if (testConnection(localUrl, localUsername, localPassword, localDriver)) {
            log.warn("Remote PostgreSQL unavailable, falling back to local PostgreSQL");
            return DataSourceBuilder.create()
                    .url(localUrl)
                    .username(localUsername)
                    .password(localPassword)
                    .driverClassName(localDriver)
                    .build();
        }

        // Final fallback to H2 file-based (persistent)
        log.error("Both remote and local PostgreSQL unavailable, falling back to persistent H2");
        String h2Url = "jdbc:h2:file:./data/spinwish_prod_fallback;DB_CLOSE_DELAY=-1";
        String h2Driver = "org.h2.Driver";

        return DataSourceBuilder.create()
                .url(h2Url)
                .username("sa")
                .password("")
                .driverClassName(h2Driver)
                .build();
    }

    /**
     * Smart DataSource configuration for local profile
     * Tries local PostgreSQL with H2 fallback
     */
    @Bean
    @Primary
    @Profile("local")
    public DataSource localDataSource() {
        log.info("Configuring local DataSource with fallback...");

        if (!fallbackEnabled) {
            log.info("Fallback disabled, using local PostgreSQL directly");
            return DataSourceBuilder.create()
                    .url(localUrl)
                    .username(localUsername)
                    .password(localPassword)
                    .driverClassName(localDriver)
                    .build();
        }

        if (testConnection(localUrl, localUsername, localPassword, localDriver)) {
            log.info("Using local PostgreSQL database");
            return DataSourceBuilder.create()
                    .url(localUrl)
                    .username(localUsername)
                    .password(localPassword)
                    .driverClassName(localDriver)
                    .build();
        }

        // Fallback to H2 file-based (persistent)
        log.warn("Local PostgreSQL unavailable, falling back to persistent H2");
        String h2Url = "jdbc:h2:file:./data/spinwish_local_fallback;DB_CLOSE_DELAY=-1";
        String h2Driver = "org.h2.Driver";

        return DataSourceBuilder.create()
                .url(h2Url)
                .username("sa")
                .password("")
                .driverClassName(h2Driver)
                .build();
    }

    /**
     * Development profile uses H2 file-based by default (persistent storage)
     */
    @Bean
    @Primary
    @Profile("dev")
    public DataSource developmentDataSource() {
        log.info("Using H2 file-based database for development (persistent)");
        return DataSourceBuilder.create()
                .url("jdbc:h2:file:./data/spinwish_dev;DB_CLOSE_DELAY=-1")
                .username("sa")
                .password("")
                .driverClassName("org.h2.Driver")
                .build();
    }

    /**
     * Default DataSource configuration (no profile specified)
     * Uses intelligent fallback: Remote PostgreSQL -> Local PostgreSQL -> H2
     */
    @Bean
    @Primary
    @Profile("default")
    public DataSource defaultDataSource() {
        log.info("Configuring default DataSource with intelligent fallback...");

        if (!fallbackEnabled) {
            log.info("Fallback disabled, using persistent H2 directly");
            return DataSourceBuilder.create()
                    .url("jdbc:h2:file:./data/spinwish_dev;DB_CLOSE_DELAY=-1")
                    .username("sa")
                    .password("")
                    .driverClassName("org.h2.Driver")
                    .build();
        }

        // Try remote PostgreSQL first
        if (testConnection(remoteUrl, remoteUsername, remotePassword, remoteDriver)) {
            log.info("Using remote PostgreSQL database (Render)");
            return DataSourceBuilder.create()
                    .url(remoteUrl)
                    .username(remoteUsername)
                    .password(remotePassword)
                    .driverClassName(remoteDriver)
                    .build();
        }

        // Try local PostgreSQL
        if (testConnection(localUrl, localUsername, localPassword, localDriver)) {
            log.warn("Remote PostgreSQL unavailable, using local PostgreSQL");
            return DataSourceBuilder.create()
                    .url(localUrl)
                    .username(localUsername)
                    .password(localPassword)
                    .driverClassName(localDriver)
                    .build();
        }

        // Final fallback to H2 file-based (persistent)
        log.warn("Both PostgreSQL databases unavailable, falling back to persistent H2");
        return DataSourceBuilder.create()
                .url("jdbc:h2:file:./data/spinwish_dev;DB_CLOSE_DELAY=-1")
                .username("sa")
                .password("")
                .driverClassName("org.h2.Driver")
                .build();
    }
}
