package com.spinwish.backend.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

@Entity
@Getter
@Setter
public class Users implements UserDetails {
    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "emailAddress", unique = true, nullable = false)
    private String emailAddress;

    @Column(name = "username", unique = true, nullable = false)
    private String actualUsername;

    @Column(name = "password", nullable = false)
    private String password;

    @Column(name = "phone_number")
    private String phoneNumber;

    @Column(nullable = false)
    private Boolean isActive = false;

    @Column(name = "email_verified")
    private Boolean emailVerified = false;

    @Column(name = "phone_verified")
    private Boolean phoneVerified = false;

    @Column(name = "verification_code")
    private String verificationCode;

    @Column(name = "verification_code_expiry")
    private LocalDateTime verificationCodeExpiry;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // DJ-specific fields
    @Column(name = "bio", columnDefinition = "TEXT")
    private String bio;

    @Column(name = "profile_image")
    private String profileImage;

    @ElementCollection
    @CollectionTable(name = "user_genres", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "genre")
    private List<String> genres;

    @Column(name = "rating")
    private Double rating;

    @Column(name = "instagram_handle")
    private String instagramHandle;

    @Column(name = "is_live")
    private Boolean isLive;

    @Column(name = "followers")
    private Integer followers;

    @Column(name = "credits")
    private Double credits;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "role_id", nullable = false)
    private Roles role;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        String roleName = role.getRoleName();
        if (!roleName.startsWith("ROLE_")) {
            roleName = "ROLE_" + roleName;
        }
        return List.of(new SimpleGrantedAuthority(roleName));
    }

    @Override
    public String getPassword() {
        return this.password;
    }

    @Override
    public String getUsername() {
        return this.emailAddress;
    }

    @Override
    public boolean isAccountNonExpired() {
        return UserDetails.super.isAccountNonExpired();
    }

    @Override
    public boolean isAccountNonLocked() {
        return UserDetails.super.isAccountNonLocked();
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return UserDetails.super.isCredentialsNonExpired();
    }

    @Override
    public boolean isEnabled() {
        return this.isActive != null ? this.isActive : false;
    }
}
