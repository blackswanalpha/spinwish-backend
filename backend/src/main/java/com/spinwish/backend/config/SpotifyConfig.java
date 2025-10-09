package com.spinwish.backend.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import se.michaelthelin.spotify.SpotifyApi;

/**
 * Configuration class for Spotify Web API integration.
 * Sets up the SpotifyApi bean with client credentials for authentication.
 */
@Configuration
@Slf4j
public class SpotifyConfig {

    private static final String CLIENT_ID = "b7f3b06480734fad9f7a877da42b7f8b";
    private static final String CLIENT_SECRET = "a00eaebfe18d49e593ce6156fb39082d";

    /**
     * Creates and configures a SpotifyApi bean.
     * This bean is used throughout the application to interact with Spotify's API.
     *
     * @return Configured SpotifyApi instance
     */
    @Bean
    public SpotifyApi spotifyApi() {
        log.info("Initializing Spotify API with client ID: {}...", CLIENT_ID.substring(0, 8));

        return new SpotifyApi.Builder()
                .setClientId(CLIENT_ID)
                .setClientSecret(CLIENT_SECRET)
                .build();
    }
}

