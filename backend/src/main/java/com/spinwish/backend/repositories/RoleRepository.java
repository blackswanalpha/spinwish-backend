package com.spinwish.backend.repositories;

import com.spinwish.backend.entities.Roles;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface RoleRepository extends JpaRepository<Roles, UUID> {
    Roles findByRoleName(String roleName);
    Optional<Roles> findOptionalByRoleName(String roleName);
}
