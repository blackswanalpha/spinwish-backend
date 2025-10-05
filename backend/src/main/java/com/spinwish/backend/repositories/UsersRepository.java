package com.spinwish.backend.repositories;

import com.spinwish.backend.entities.Users;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UsersRepository extends JpaRepository<Users, UUID> {
    Users findByEmailAddress(String emailAddress);
    Optional<Users> findByActualUsernameIgnoreCase(String actualUsername);
    Users findByPhoneNumber(String phoneNumber);
}