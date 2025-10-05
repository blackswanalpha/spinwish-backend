package com.spinwish.backend.repositories;

import com.spinwish.backend.entities.payments.TipPayments;
import com.spinwish.backend.entities.Users;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TipPaymentsRepository extends JpaRepository<TipPayments, UUID> {
    Optional<TipPayments> findByReceiptNumber(String receiptNumber);

    List<TipPayments> findByDjAndTransactionDateBetween(Users dj, LocalDateTime startDate, LocalDateTime endDate);

    Page<TipPayments> findByDj(Users dj, Pageable pageable);
}
