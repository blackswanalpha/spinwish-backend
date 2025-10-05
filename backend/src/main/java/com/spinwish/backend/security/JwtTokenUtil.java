package com.spinwish.backend.security;

import com.spinwish.backend.entities.Users;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.cglib.core.internal.Function;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Component;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

import static com.spinwish.backend.utils.Constants.JWT_TOKEN_VALIDITY_MS;
import static com.spinwish.backend.utils.Constants.SIGNING_KEY_BYTES;

@Component
public class JwtTokenUtil {

    public String generateToken(Users user) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("roles", user.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.toList()));

        claims.put("id", user.getId());
        return createToken(claims, user.getEmailAddress());
    }

    private String createToken(Map<String, Object> claims, String subject) {
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(subject)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + JWT_TOKEN_VALIDITY_MS))
                .signWith(Keys.hmacShaKeyFor(SIGNING_KEY_BYTES), SignatureAlgorithm.HS256)
                .compact();
    }

    public String extractEmail(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    Claims extractAllClaims(String token) {
        Claims claims = Jwts.parser()
                .setSigningKey(SIGNING_KEY_BYTES)
                .parseClaimsJws(token)
                .getBody();
        return claims;
    }

    public Boolean validateToken(String token, String emailAddress) {
        final String extractedEmail = extractEmail(token);
        return (extractedEmail.equalsIgnoreCase(emailAddress) && !isTokenExpired(token));
    }

    private Boolean isTokenExpired(String token) {
        final Date expiration = getExpirationDateFromToken(token);
        return expiration.before(new Date());
    }

    private Date getExpirationDateFromToken(String token) {
        return extractAllClaims(token).getExpiration();
    }

    public String extractUserId(String token) {
        Claims claims = extractAllClaims(token);
        return claims.get("id", String.class); // Extract the "id" claim as String (UUID)
    }

    public String generateRefreshToken(Users user) {
        return Jwts.builder()
                .setSubject(user.getUsername())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + 7 * 24 * 60 * 60 * 1000)) // 7 days
                .signWith(SignatureAlgorithm.HS256, SIGNING_KEY_BYTES)
                .compact();
    }

    public boolean validateRefreshToken(String token) {
        try {
            Jwts.parser()
                    .setSigningKey(SIGNING_KEY_BYTES)
                    .parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }
}

