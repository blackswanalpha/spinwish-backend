package com.spinwish.backend.repositories;

import com.spinwish.backend.entities.payments.Refund;
import com.spinwish.backend.entities.payments.RequestsPayment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface RefundRepository extends JpaRepository<Refund, UUID> {
    
    /**
     * Find refund by request payment
     */
    Optional<Refund> findByRequestPayment(RequestsPayment requestPayment);
    
    /**
     * Check if refund exists for a request payment
     */
    boolean existsByRequestPayment(RequestsPayment requestPayment);
    
    /**
     * Find refund by transaction ID
     */
    Optional<Refund> findByTransactionId(String transactionId);
}

