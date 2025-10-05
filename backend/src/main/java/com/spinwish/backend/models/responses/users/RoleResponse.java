package com.spinwish.backend.models.responses.users;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class RoleResponse {
    private UUID id;
    private String roleName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
