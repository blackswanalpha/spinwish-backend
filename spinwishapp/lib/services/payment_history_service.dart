import 'package:flutter/foundation.dart';
import 'package:spinwishapp/services/api_service.dart';
import 'package:spinwishapp/models/payment.dart';

/// Service for managing payment history and receipts
class PaymentHistoryService {
  static const String _baseEndpoint = '/payment';

  /// Get all payments for the current user
  static Future<List<Payment>> getPaymentHistory() async {
    try {
      final response = await ApiService.get(
        _baseEndpoint,
        includeAuth: true,
      );

      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data.map((json) => Payment.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      debugPrint('Failed to fetch payment history: $e');
      rethrow;
    }
  }

  /// Get payment details by ID
  static Future<Payment?> getPaymentById(String paymentId) async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/$paymentId',
        includeAuth: true,
      );

      final data = ApiService.handleResponse(response);
      return Payment.fromJson(data);
    } catch (e) {
      debugPrint('Failed to fetch payment details: $e');
      return null;
    }
  }

  /// Get receipt data for a payment
  static Future<Map<String, dynamic>?> getReceiptData(
    String paymentId,
    PaymentType paymentType,
  ) async {
    try {
      final endpoint = paymentType == PaymentType.tip
          ? '$_baseEndpoint/receipt/tip/$paymentId'
          : '$_baseEndpoint/receipt/request/$paymentId';

      final response = await ApiService.get(
        endpoint,
        includeAuth: true,
      );

      return ApiService.handleResponse(response);
    } catch (e) {
      debugPrint('Failed to fetch receipt data: $e');
      return null;
    }
  }

  /// Get HTML receipt for a payment
  static Future<String?> getReceiptHtml(
    String paymentId,
    PaymentType paymentType,
  ) async {
    try {
      final endpoint = paymentType == PaymentType.tip
          ? '$_baseEndpoint/receipt/html/tip/$paymentId'
          : '$_baseEndpoint/receipt/html/request/$paymentId';

      final response = await ApiService.get(
        endpoint,
        includeAuth: true,
      );

      // For HTML responses, we expect the raw HTML string
      if (response.statusCode == 200) {
        return response.body;
      }

      return null;
    } catch (e) {
      debugPrint('Failed to fetch receipt HTML: $e');
      return null;
    }
  }

  /// Filter payments by type
  static List<Payment> filterByType(List<Payment> payments, PaymentType type) {
    return payments.where((payment) => payment.type == type).toList();
  }

  /// Filter payments by status
  static List<Payment> filterByStatus(
      List<Payment> payments, PaymentStatus status) {
    return payments.where((payment) => payment.status == status).toList();
  }

  /// Filter payments by date range
  static List<Payment> filterByDateRange(
    List<Payment> payments,
    DateTime startDate,
    DateTime endDate,
  ) {
    return payments.where((payment) {
      return payment.timestamp.isAfter(startDate) &&
          payment.timestamp.isBefore(endDate);
    }).toList();
  }

  /// Sort payments by date (newest first)
  static List<Payment> sortByDateDescending(List<Payment> payments) {
    final sortedPayments = List<Payment>.from(payments);
    sortedPayments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedPayments;
  }

  /// Sort payments by amount (highest first)
  static List<Payment> sortByAmountDescending(List<Payment> payments) {
    final sortedPayments = List<Payment>.from(payments);
    sortedPayments.sort((a, b) => b.amount.compareTo(a.amount));
    return sortedPayments;
  }

  /// Get total amount spent
  static double getTotalAmount(List<Payment> payments) {
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get payment statistics
  static Map<String, dynamic> getPaymentStatistics(List<Payment> payments) {
    final completedPayments = filterByStatus(payments, PaymentStatus.completed);
    final failedPayments = filterByStatus(payments, PaymentStatus.failed);
    final pendingPayments = filterByStatus(payments, PaymentStatus.pending);

    final songRequestPayments =
        filterByType(completedPayments, PaymentType.songRequest);
    final tipPayments = filterByType(completedPayments, PaymentType.tip);

    return {
      'totalPayments': payments.length,
      'completedPayments': completedPayments.length,
      'failedPayments': failedPayments.length,
      'pendingPayments': pendingPayments.length,
      'totalAmount': getTotalAmount(completedPayments),
      'songRequestCount': songRequestPayments.length,
      'tipCount': tipPayments.length,
      'songRequestAmount': getTotalAmount(songRequestPayments),
      'tipAmount': getTotalAmount(tipPayments),
      'averagePayment': completedPayments.isNotEmpty
          ? getTotalAmount(completedPayments) / completedPayments.length
          : 0.0,
    };
  }

  /// Get payments grouped by month
  static Map<String, List<Payment>> groupByMonth(List<Payment> payments) {
    final Map<String, List<Payment>> grouped = {};

    for (final payment in payments) {
      final monthKey =
          '${payment.timestamp.year}-${payment.timestamp.month.toString().padLeft(2, '0')}';

      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }

      grouped[monthKey]!.add(payment);
    }

    return grouped;
  }

  /// Search payments by description or transaction ID
  static List<Payment> searchPayments(List<Payment> payments, String query) {
    if (query.trim().isEmpty) {
      return payments;
    }

    final lowerQuery = query.toLowerCase();

    return payments.where((payment) {
      return (payment.description?.toLowerCase().contains(lowerQuery) ??
              false) ||
          (payment.transactionId?.toLowerCase().contains(lowerQuery) ??
              false) ||
          (payment.id.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get recent payments (last 30 days)
  static List<Payment> getRecentPayments(List<Payment> payments) {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return filterByDateRange(payments, thirtyDaysAgo, DateTime.now());
  }

  /// Check if payment can be retried
  static bool canRetryPayment(Payment payment) {
    return payment.status == PaymentStatus.failed ||
        payment.status == PaymentStatus.cancelled;
  }

  /// Format payment amount for display
  static String formatAmount(double amount) {
    return 'KES ${amount.toStringAsFixed(2)}';
  }

  /// Get payment type display name
  static String getPaymentTypeDisplayName(PaymentType type) {
    switch (type) {
      case PaymentType.songRequest:
        return 'Song Request';
      case PaymentType.tip:
        return 'DJ Tip';
      case PaymentType.subscription:
        return 'Subscription';
      case PaymentType.other:
        return 'Other';
    }
  }

  /// Get payment status display name
  static String getPaymentStatusDisplayName(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  /// Get status color for UI
  static String getStatusColorHex(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return '#10B981'; // Green
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        return '#F59E0B'; // Orange
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        return '#EF4444'; // Red
      case PaymentStatus.refunded:
        return '#6B7280'; // Gray
    }
  }
}
