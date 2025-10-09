package com.spinwish.backend.services;

import com.spinwish.backend.entities.Request;
import com.spinwish.backend.entities.Users;
import com.spinwish.backend.entities.payments.TipPayments;
import com.spinwish.backend.entities.payments.RequestsPayment;
import com.spinwish.backend.repositories.UsersRepository;
import com.spinwish.backend.repositories.TipPaymentsRepository;
import com.spinwish.backend.repositories.RequestsPaymentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;

@Service
public class EarningsService {

    @Autowired
    private UsersRepository usersRepository;

    @Autowired
    private TipPaymentsRepository tipPaymentsRepository;

    @Autowired
    private RequestsPaymentRepository requestsPaymentRepository;

    public EarningsSummary getDJEarningsSummary(UUID djId, String period) {
        Users dj = usersRepository.findById(djId)
                .orElseThrow(() -> new RuntimeException("DJ not found with id: " + djId));

        if (!"DJ".equals(dj.getRole().getRoleName())) {
            throw new RuntimeException("User is not a DJ");
        }

        LocalDateTime startDate = getStartDateForPeriod(period);
        LocalDateTime endDate = LocalDateTime.now();

        // Get tip earnings (all tips are immediately available)
        List<TipPayments> tips = tipPaymentsRepository.findByDjAndTransactionDateBetween(
                dj, startDate, endDate);
        double totalTips = tips.stream().mapToDouble(TipPayments::getAmount).sum();

        // Get ACCEPTED request earnings only (not pending or rejected)
        List<RequestsPayment> acceptedRequests = requestsPaymentRepository
                .findByRequestDjAndStatusAndTransactionDateBetween(
                        dj, Request.RequestStatus.ACCEPTED, startDate, endDate);
        double totalAcceptedRequests = acceptedRequests.stream()
                .mapToDouble(RequestsPayment::getAmount).sum();

        // Get PENDING request payments (not yet approved)
        List<RequestsPayment> pendingRequests = requestsPaymentRepository
                .findByRequestDjAndStatusAndTransactionDateBetween(
                        dj, Request.RequestStatus.PENDING, startDate, endDate);
        double totalPendingRequests = pendingRequests.stream()
                .mapToDouble(RequestsPayment::getAmount).sum();

        // Total earnings = tips + accepted requests only
        double totalEarnings = totalTips + totalAcceptedRequests;

        return new EarningsSummary(
                totalEarnings,
                totalTips,
                totalAcceptedRequests,
                totalPendingRequests, // Pending amount from unapproved requests
                totalEarnings, // Available for payout (all accepted earnings)
                tips.size() + acceptedRequests.size(),
                startDate,
                endDate
        );
    }

    public EarningsSummary getCurrentDJEarningsSummary(String period) {
        String emailAddress = SecurityContextHolder.getContext().getAuthentication().getName();
        Users currentUser = usersRepository.findByEmailAddress(emailAddress);
        
        if (currentUser == null) {
            throw new RuntimeException("User not found");
        }

        if (!"DJ".equals(currentUser.getRole().getRoleName())) {
            throw new RuntimeException("Current user is not a DJ");
        }

        return getDJEarningsSummary(currentUser.getId(), period);
    }

    public Page<TipPayments> getDJTipHistory(UUID djId, int page, int size) {
        Users dj = usersRepository.findById(djId)
                .orElseThrow(() -> new RuntimeException("DJ not found with id: " + djId));

        Pageable pageable = PageRequest.of(page, size, Sort.by("transactionDate").descending());
        return tipPaymentsRepository.findByDj(dj, pageable);
    }

    public Page<RequestsPayment> getDJRequestPaymentHistory(UUID djId, int page, int size) {
        Users dj = usersRepository.findById(djId)
                .orElseThrow(() -> new RuntimeException("DJ not found with id: " + djId));

        Pageable pageable = PageRequest.of(page, size, Sort.by("transactionDate").descending());
        return requestsPaymentRepository.findByRequestDj(dj, pageable);
    }

    public Page<TipPayments> getCurrentDJTipHistory(int page, int size) {
        String emailAddress = SecurityContextHolder.getContext().getAuthentication().getName();
        Users currentUser = usersRepository.findByEmailAddress(emailAddress);
        
        if (currentUser == null) {
            throw new RuntimeException("User not found");
        }

        return getDJTipHistory(currentUser.getId(), page, size);
    }

    public Page<RequestsPayment> getCurrentDJRequestPaymentHistory(int page, int size) {
        String emailAddress = SecurityContextHolder.getContext().getAuthentication().getName();
        Users currentUser = usersRepository.findByEmailAddress(emailAddress);
        
        if (currentUser == null) {
            throw new RuntimeException("User not found");
        }

        return getDJRequestPaymentHistory(currentUser.getId(), page, size);
    }

    private LocalDateTime getStartDateForPeriod(String period) {
        LocalDateTime now = LocalDateTime.now();
        switch (period.toLowerCase()) {
            case "today":
                return now.truncatedTo(ChronoUnit.DAYS);
            case "week":
                return now.minusWeeks(1);
            case "month":
                return now.minusMonths(1);
            case "all":
                return LocalDateTime.of(2020, 1, 1, 0, 0); // Start from a reasonable date
            default:
                return now.minusMonths(1); // Default to month
        }
    }

    // Inner class for earnings summary
    public static class EarningsSummary {
        private double totalEarnings;
        private double totalTips;
        private double totalRequests;
        private double pendingAmount;
        private double availableForPayout;
        private int totalTransactions;
        private LocalDateTime periodStart;
        private LocalDateTime periodEnd;

        public EarningsSummary(double totalEarnings, double totalTips, double totalRequests,
                             double pendingAmount, double availableForPayout, int totalTransactions,
                             LocalDateTime periodStart, LocalDateTime periodEnd) {
            this.totalEarnings = totalEarnings;
            this.totalTips = totalTips;
            this.totalRequests = totalRequests;
            this.pendingAmount = pendingAmount;
            this.availableForPayout = availableForPayout;
            this.totalTransactions = totalTransactions;
            this.periodStart = periodStart;
            this.periodEnd = periodEnd;
        }

        // Getters
        public double getTotalEarnings() { return totalEarnings; }
        public double getTotalTips() { return totalTips; }
        public double getTotalRequests() { return totalRequests; }
        public double getPendingAmount() { return pendingAmount; }
        public double getAvailableForPayout() { return availableForPayout; }
        public int getTotalTransactions() { return totalTransactions; }
        public LocalDateTime getPeriodStart() { return periodStart; }
        public LocalDateTime getPeriodEnd() { return periodEnd; }
    }
}
