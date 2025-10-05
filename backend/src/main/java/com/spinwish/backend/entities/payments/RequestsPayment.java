package com.spinwish.backend.entities.payments;

import com.spinwish.backend.entities.Request;
import com.spinwish.backend.entities.Users;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Getter
@Setter
@Table(name = "request_payments")
public class RequestsPayment {
    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "receipt_number", nullable = false, unique = true)
    private String receiptNumber;

    @Column(name = "payer_name", nullable = false)
    private String payerName;

    @Column(name = "phone_number", nullable = false)
    private String phoneNumber;

    @Column(name = "amount", nullable = false)
    private Double amount;

    @Column(name = "transaction_date", nullable = false)
    private LocalDateTime transactionDate;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id")
    private Users payer;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "request_id", nullable = false)
    private Request request;
}
