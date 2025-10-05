import 'package:flutter/foundation.dart';
import 'package:spinwishapp/services/api_service.dart';
import 'package:spinwishapp/services/auth_service.dart';

/// Service for DJ payment-related operations
class DjPaymentService {
  static const String _baseEndpoint = '/api/v1/payment';

  /// Get all request payments for the current DJ
  static Future<List<Map<String, dynamic>>> getRequestPayments() async {
    try {
      // Get current user
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Call backend API to get payments
      final response = await ApiService.get(
        '$_baseEndpoint/requests/dj/${currentUser.id}',
        includeAuth: true,
      );

      if (response is List) {
        return (response as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Failed to get request payments: $e');
      rethrow;
    }
  }

  /// Get request payments for a specific DJ by ID
  static Future<List<Map<String, dynamic>>> getRequestPaymentsByDjId(
      String djId) async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/requests/dj/$djId',
        includeAuth: true,
      );

      if (response is List) {
        return (response as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Failed to get request payments for DJ $djId: $e');
      rethrow;
    }
  }

  /// Get payment statistics for the current DJ
  static Future<Map<String, dynamic>> getPaymentStatistics() async {
    try {
      final payments = await getRequestPayments();

      double totalAmount = 0;
      int totalPayments = payments.length;
      Map<String, int> paymentsByMonth = {};

      for (var payment in payments) {
        totalAmount += (payment['amount'] as num).toDouble();

        // Group by month
        final transactionDate = DateTime.parse(payment['transactionDate']);
        final monthKey =
            '${transactionDate.year}-${transactionDate.month.toString().padLeft(2, '0')}';
        paymentsByMonth[monthKey] = (paymentsByMonth[monthKey] ?? 0) + 1;
      }

      return {
        'totalAmount': totalAmount,
        'totalPayments': totalPayments,
        'averageAmount': totalPayments > 0 ? totalAmount / totalPayments : 0,
        'paymentsByMonth': paymentsByMonth,
      };
    } catch (e) {
      debugPrint('Failed to get payment statistics: $e');
      rethrow;
    }
  }

  /// Get recent payments (last N payments)
  static Future<List<Map<String, dynamic>>> getRecentPayments(
      {int limit = 10}) async {
    try {
      final payments = await getRequestPayments();

      // Sort by transaction date (most recent first)
      payments.sort((a, b) {
        final dateA = DateTime.parse(a['transactionDate']);
        final dateB = DateTime.parse(b['transactionDate']);
        return dateB.compareTo(dateA);
      });

      // Return only the requested number of payments
      return payments.take(limit).toList();
    } catch (e) {
      debugPrint('Failed to get recent payments: $e');
      rethrow;
    }
  }

  /// Filter payments by date range
  static Future<List<Map<String, dynamic>>> getPaymentsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final payments = await getRequestPayments();

      return payments.where((payment) {
        final transactionDate = DateTime.parse(payment['transactionDate']);
        return transactionDate.isAfter(startDate) &&
            transactionDate.isBefore(endDate);
      }).toList();
    } catch (e) {
      debugPrint('Failed to filter payments by date range: $e');
      rethrow;
    }
  }

  /// Search payments by payer name
  static Future<List<Map<String, dynamic>>> searchPaymentsByPayerName(
      String query) async {
    try {
      final payments = await getRequestPayments();

      return payments.where((payment) {
        final payerName = (payment['payerName'] as String).toLowerCase();
        return payerName.contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      debugPrint('Failed to search payments: $e');
      rethrow;
    }
  }
}
