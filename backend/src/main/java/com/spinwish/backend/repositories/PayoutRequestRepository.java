package com.spinwish.backend.repositories;

import com.spinwish.backend.entities.Users;
import com.spinwish.backend.entities.payments.PayoutRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface PayoutRequestRepository extends JpaRepository<PayoutRequest, UUID> {
    
    /**
     * Find all payout requests for a user
     */
    Page<PayoutRequest> findByUserOrderByRequestedAtDesc(Users user, Pageable pageable);
    
    /**
     * Find payout requests by status
     */
    List<PayoutRequest> findByStatus(PayoutRequest.PayoutStatus status);
    
    /**
     * Find payout requests by user and status
     */
    List<PayoutRequest> findByUserAndStatus(Users user, PayoutRequest.PayoutStatus status);
    
    /**
     * Find pending payout requests for a user
     */
    List<PayoutRequest> findByUserAndStatusIn(Users user, List<PayoutRequest.PayoutStatus> statuses);
    
    /**
     * Calculate total pending payout amount for a user
     */
    @Query("SELECT COALESCE(SUM(pr.amount), 0.0) FROM PayoutRequest pr WHERE pr.user = :user AND pr.status IN :statuses")
    Double sumPendingAmountByUser(@Param("user") Users user, @Param("statuses") List<PayoutRequest.PayoutStatus> statuses);
    
    /**
     * Find payout requests within date range
     */
    List<PayoutRequest> findByUserAndRequestedAtBetween(Users user, LocalDateTime start, LocalDateTime end);
}

