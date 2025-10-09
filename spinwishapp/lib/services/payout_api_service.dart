import 'package:flutter/foundation.dart';
import 'package:spinwishapp/services/api_service.dart';
import 'package:spinwishapp/models/payout.dart';

class PayoutApiService {
  static const String _baseEndpoint = '/payouts';

  // ==================== Payout Methods ====================

  /// Add a new payout method
  static Future<PayoutMethodModel> addPayoutMethod(
      AddPayoutMethodRequest request) async {
    try {
      final data = await ApiService.postJson(
        '$_baseEndpoint/methods',
        request.toJson(),
        includeAuth: true,
      );
      return PayoutMethodModel.fromJson(data);
    } catch (e) {
      debugPrint('Failed to add payout method: $e');
      throw ApiException('Failed to add payout method: ${e.toString()}');
    }
  }

  /// Get all payout methods for current user
  static Future<List<PayoutMethodModel>> getPayoutMethods() async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/methods',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data
            .map((item) =>
                PayoutMethodModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Failed to get payout methods: $e');
      throw ApiException('Failed to get payout methods: ${e.toString()}');
    }
  }

  /// Get default payout method
  static Future<PayoutMethodModel?> getDefaultPayoutMethod() async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/methods/default',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);
      return PayoutMethodModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Failed to get default payout method: $e');
      return null; // No default method found
    }
  }

  /// Set a payout method as default
  static Future<PayoutMethodModel> setDefaultPayoutMethod(
      String methodId) async {
    try {
      final data = await ApiService.put(
        '$_baseEndpoint/methods/$methodId/default',
        {},
        includeAuth: true,
      );
      return PayoutMethodModel.fromJson(data);
    } catch (e) {
      debugPrint('Failed to set default payout method: $e');
      throw ApiException(
          'Failed to set default payout method: ${e.toString()}');
    }
  }

  /// Delete a payout method
  static Future<void> deletePayoutMethod(String methodId) async {
    try {
      await ApiService.delete(
        '$_baseEndpoint/methods/$methodId',
        includeAuth: true,
      );
    } catch (e) {
      debugPrint('Failed to delete payout method: $e');
      throw ApiException('Failed to delete payout method: ${e.toString()}');
    }
  }

  // ==================== Payout Requests ====================

  /// Create a new payout request
  static Future<PayoutRequestModel> createPayoutRequest(
      CreatePayoutRequest request) async {
    try {
      final data = await ApiService.postJson(
        '$_baseEndpoint/requests',
        request.toJson(),
        includeAuth: true,
      );
      return PayoutRequestModel.fromJson(data);
    } catch (e) {
      debugPrint('Failed to create payout request: $e');
      throw ApiException('Failed to create payout request: ${e.toString()}');
    }
  }

  /// Get all payout requests for current user
  static Future<List<PayoutRequestModel>> getPayoutRequests({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/requests?page=$page&size=$size',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);

      if (data is Map && data['content'] is List) {
        return (data['content'] as List)
            .map((item) =>
                PayoutRequestModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Failed to get payout requests: $e');
      throw ApiException('Failed to get payout requests: ${e.toString()}');
    }
  }

  /// Get a specific payout request by ID
  static Future<PayoutRequestModel> getPayoutRequest(String requestId) async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/requests/$requestId',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);
      return PayoutRequestModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Failed to get payout request: $e');
      throw ApiException('Failed to get payout request: ${e.toString()}');
    }
  }

  /// Process a payout request (Demo with PayMe)
  static Future<PayoutRequestModel> processPayoutRequest(
      String requestId) async {
    try {
      final data = await ApiService.postJson(
        '$_baseEndpoint/requests/$requestId/process',
        {},
        includeAuth: true,
      );
      return PayoutRequestModel.fromJson(data);
    } catch (e) {
      debugPrint('Failed to process payout request: $e');
      throw ApiException('Failed to process payout request: ${e.toString()}');
    }
  }

  /// Validate payout amount
  static bool isValidPayoutAmount(double amount) {
    return amount >= 50.0 && amount <= 500000.0;
  }

  /// Get minimum payout amount
  static double getMinimumPayoutAmount() {
    return 50.0;
  }

  /// Get maximum payout amount
  static double getMaximumPayoutAmount() {
    return 500000.0;
  }

  /// Calculate processing fee (2%)
  static double calculateProcessingFee(double amount) {
    return amount * 0.02;
  }

  /// Calculate net amount after fee
  static double calculateNetAmount(double amount) {
    return amount - calculateProcessingFee(amount);
  }
}

/// API Exception
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}
