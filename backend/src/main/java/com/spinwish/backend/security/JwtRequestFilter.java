package com.spinwish.backend.security;

import com.spinwish.backend.services.UserService;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class JwtRequestFilter extends OncePerRequestFilter {

    @Autowired
    private UserService userService;

    @Autowired
    private JwtTokenUtil jwtUtil;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {

        final String authorizationHeader = request.getHeader("Authorization");

        String email = null;
        String jwt = null;

        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            jwt = authorizationHeader.substring(7);
            try {
                email = jwtUtil.extractEmail(jwt);
            } catch (ExpiredJwtException e) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("Token expired, please login again");
                return;
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("Invalid token");
                return;
            }
        }

        if (email != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            try {
                UserDetails userDetails = this.userService.loadUserByUsername(email);
                logger.debug("Loaded user details for email: " + email + ", username: " + userDetails.getUsername());

                if (jwtUtil.validateToken(jwt, userDetails.getUsername())) {
                    logger.debug("JWT token validation successful for user: " + userDetails.getUsername());
                    Claims claims = jwtUtil.extractAllClaims(jwt);
                    Object rolesObject = claims.get("roles");

                    List<GrantedAuthority> authorities = new ArrayList<>();
                    if (rolesObject instanceof List<?>) {
                        authorities = ((List<?>) rolesObject).stream()
                                .filter(role -> role instanceof String)
                                .map(role -> (String) role)
                                .map(role -> role.startsWith("ROLE_") ? role : "ROLE_" + role)
                                .map(SimpleGrantedAuthority::new)
                                .collect(Collectors.toList());
                    }

                    UsernamePasswordAuthenticationToken usernamePasswordAuthenticationToken = new UsernamePasswordAuthenticationToken(
                            userDetails, null, authorities);
                    usernamePasswordAuthenticationToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(usernamePasswordAuthenticationToken);
                    logger.debug("Authentication set in SecurityContext for user: " + userDetails.getUsername());
                } else {
                    logger.debug("JWT token validation failed for user: " + userDetails.getUsername());
                }
            } catch (org.springframework.security.core.userdetails.UsernameNotFoundException e) {
                // User not found - this is OK for demo/public endpoints
                // Just continue without authentication
                logger.debug("User not found for email: " + email + " - continuing without authentication");
            } catch (Exception e) {
                // Any other exception during user loading - log and continue
                logger.warn("Error loading user details for email: " + email + " - " + e.getMessage());
            }
        }
        chain.doFilter(request, response);
    }
}

