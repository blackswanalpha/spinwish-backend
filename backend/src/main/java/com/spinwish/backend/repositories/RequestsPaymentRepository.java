package com.spinwish.backend.repositories;

import com.spinwish.backend.entities.payments.RequestsPayment;
import com.spinwish.backend.entities.Users;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface RequestsPaymentRepository extends JpaRepository<RequestsPayment, UUID> {
    Optional<RequestsPayment> findByReceiptNumber(String receiptNumber);

    @Query("SELECT rp FROM RequestsPayment rp WHERE rp.request.dj = :dj AND rp.transactionDate BETWEEN :startDate AND :endDate")
    List<RequestsPayment> findByRequestDjAndTransactionDateBetween(@Param("dj") Users dj, @Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    @Query("SELECT rp FROM RequestsPayment rp WHERE rp.request.dj = :dj")
    Page<RequestsPayment> findByRequestDj(@Param("dj") Users dj, Pageable pageable);

    @Query("SELECT rp FROM RequestsPayment rp WHERE rp.request.djId = :djId ORDER BY rp.transactionDate DESC")
    List<RequestsPayment> findByRequestDjId(@Param("djId") UUID djId);
}
