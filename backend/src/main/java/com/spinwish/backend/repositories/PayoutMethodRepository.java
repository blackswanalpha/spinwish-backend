package com.spinwish.backend.repositories;

import com.spinwish.backend.entities.Users;
import com.spinwish.backend.entities.payments.PayoutMethod;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PayoutMethodRepository extends JpaRepository<PayoutMethod, UUID> {
    
    /**
     * Find all payout methods for a user
     */
    List<PayoutMethod> findByUserOrderByCreatedAtDesc(Users user);
    
    /**
     * Find default payout method for a user
     */
    Optional<PayoutMethod> findByUserAndIsDefaultTrue(Users user);
    
    /**
     * Find payout method by ID and user
     */
    Optional<PayoutMethod> findByIdAndUser(UUID id, Users user);
    
    /**
     * Count payout methods for a user
     */
    long countByUser(Users user);
    
    /**
     * Check if user has a default payout method
     */
    boolean existsByUserAndIsDefaultTrue(Users user);
}

