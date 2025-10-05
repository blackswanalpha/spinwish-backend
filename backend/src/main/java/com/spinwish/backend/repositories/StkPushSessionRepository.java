package com.spinwish.backend.repositories;

import com.spinwish.backend.entities.payments.StkPushSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface StkPushSessionRepository extends JpaRepository<StkPushSession, UUID> {
    List<StkPushSession> findByStatus(String status);
    Optional<StkPushSession> findByCheckoutRequestId(String checkoutRequestId);
}

