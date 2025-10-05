package com.spinwish.backend.controllers;

import com.spinwish.backend.models.requests.users.RoleRequest;
import com.spinwish.backend.models.responses.users.RoleResponse;
import com.spinwish.backend.services.RoleService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping(path = "api/v1/roles")
public class RoleController {

    @Autowired
    private RoleService roleService;

    // Create
    @PostMapping
    public ResponseEntity<RoleResponse> createNewRole(@RequestBody RoleRequest roleRequest) {
        try {
            RoleResponse roleResponse = roleService.createRole(roleRequest);
            return new ResponseEntity<>(roleResponse, HttpStatus.CREATED);
        } catch (Exception e) {
            log.error("Failed to create role: {}", e.getMessage());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // Read all
    @GetMapping
    public ResponseEntity<List<RoleResponse>> getAllRoles() {
        try {
            List<RoleResponse> roles = roleService.getAllRoles();
            return new ResponseEntity<>(roles, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Failed to fetch roles: {}", e.getMessage());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // Read by ID
    @GetMapping("/{id}")
    public ResponseEntity<RoleResponse> getRoleById(@PathVariable UUID id) {
        try {
            RoleResponse role = roleService.getRoleById(id);
            return new ResponseEntity<>(role, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Failed to fetch role by ID: {}", e.getMessage());
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    // Update
    @PutMapping("/{id}")
    public ResponseEntity<RoleResponse> updateRole(
            @PathVariable UUID id,
            @RequestBody RoleRequest roleRequest
    ) {
        try {
            RoleResponse updatedRole = roleService.updateRole(id, roleRequest);
            return new ResponseEntity<>(updatedRole, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Failed to update role: {}", e.getMessage());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // Delete
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRole(@PathVariable UUID id) {
        try {
            roleService.deleteRole(id);
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } catch (Exception e) {
            log.error("Failed to delete role: {}", e.getMessage());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
