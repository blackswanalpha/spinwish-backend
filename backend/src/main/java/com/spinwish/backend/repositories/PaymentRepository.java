package com.spinwish.backend.repositories;

import com.spinwish.backend.entities.payments.RequestsPayment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.UUID;

@Repository
public interface PaymentRepository extends JpaRepository<RequestsPayment, UUID> {
}
