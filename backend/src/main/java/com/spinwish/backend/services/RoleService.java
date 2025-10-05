package com.spinwish.backend.services;

import com.spinwish.backend.entities.Roles;
import com.spinwish.backend.models.requests.users.RoleRequest;
import com.spinwish.backend.models.responses.users.RoleResponse;
import com.spinwish.backend.repositories.RoleRepository;
import jakarta.transaction.Transactional;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@Slf4j
public class RoleService {
    @Autowired
    private RoleRepository roleRepository;

    @Transactional
    public RoleResponse createRole(RoleRequest roleRequest){
        Roles existingRole = roleRepository.findByRoleName(roleRequest.getRoleName());

        if (existingRole != null) {
            return convertRoleResponse(existingRole);
        }
        Roles role = new Roles();
        role.setRoleName(roleRequest.getRoleName());
        role.setCreatedAt(LocalDateTime.now());
        role.setUpdatedAt(LocalDateTime.now());
        roleRepository.save(role);
        return convertRoleResponse(role);
    }

    public List<RoleResponse> getAllRoles() {
        List<Roles> roles = roleRepository.findAll();
        return roles.stream().map(this::convertRoleResponse).toList();
    }

    public RoleResponse getRoleById(UUID id) {
        Roles role = roleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Role not found with ID: " + id));
        return convertRoleResponse(role);
    }

    @Transactional
    public RoleResponse updateRole(UUID id, RoleRequest roleRequest) {
        Roles role = roleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Role not found with ID: " + id));

        role.setRoleName(roleRequest.getRoleName());
        role.setUpdatedAt(LocalDateTime.now());
        roleRepository.save(role);
        return convertRoleResponse(role);
    }

    public void deleteRole(UUID id) {
        roleRepository.deleteById(id);
    }

    private RoleResponse convertRoleResponse(Roles role) {
        RoleResponse roleResponse = new RoleResponse();
        roleResponse.setId(role.getId());
        roleResponse.setRoleName(role.getRoleName());
        roleResponse.setCreatedAt(role.getCreatedAt());
        roleResponse.setUpdatedAt(role.getUpdatedAt());
        return roleResponse;
    }

}