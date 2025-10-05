package com.spinwish.backend.config;

import com.spinwish.backend.entities.Roles;
import com.spinwish.backend.repositories.RoleRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

@Component
@Slf4j
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private RoleRepository roleRepository;

    @Override
    public void run(String... args) throws Exception {
        initializeRoles();
    }

    private void initializeRoles() {
        log.info("Initializing default roles...");
        
        List<String> defaultRoles = Arrays.asList("CLIENT", "DJ", "ADMIN");
        
        for (String roleName : defaultRoles) {
            try {
                // Check if role already exists
                Roles existingRole = roleRepository.findByRoleName(roleName);
                if (existingRole == null) {
                    // Create new role
                    Roles role = new Roles();
                    role.setRoleName(roleName);
                    role.setCreatedAt(LocalDateTime.now());
                    role.setUpdatedAt(LocalDateTime.now());
                    roleRepository.save(role);
                    log.info("Created role: {}", roleName);
                } else {
                    log.info("Role already exists: {}", roleName);
                }
            } catch (Exception e) {
                log.error("Error creating role {}: {}", roleName, e.getMessage());
            }
        }
        
        log.info("Role initialization completed. Total roles: {}", roleRepository.count());
    }
}
