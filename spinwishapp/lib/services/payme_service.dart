import 'dart:async';
import 'package:flutter/foundation.dart';

/// PayMe Service for handling demo payments
class PaymeService {
  static const String _baseEndpoint = '/api/v1/payment';

  /// Initiate a demo PayMe payment
  static Future<PaymePaymentResponse> initiateDemoPayment({
    required String accountNumber,
    required String pin,
    required double amount,
    String? requestId,
    String? djName,
  }) async {
    try {
      // Validate inputs
      _validatePaymentInputs(accountNumber, pin, amount);

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Generate a demo transaction ID
      final transactionId = 'PAYME${DateTime.now().millisecondsSinceEpoch}';

      debugPrint('PayMe demo payment initiated: $transactionId');

      return PaymePaymentResponse(
        isSuccess: true,
        transactionId: transactionId,
        message: 'Payment initiated successfully',
        accountNumber: accountNumber,
        amount: amount,
      );
    } catch (e) {
      debugPrint('PayMe payment failed: $e');
      if (e is PaymeException) {
        rethrow;
      }
      throw PaymeException('Payment initiation failed. Please try again.');
    }
  }

  /// Validate payment inputs
  static void _validatePaymentInputs(
      String accountNumber, String pin, double amount) {
    // Validate account number
    if (accountNumber.trim().isEmpty) {
      throw const PaymeException('Account number is required');
    }

    if (accountNumber.length < 4) {
      throw const PaymeException(
          'Please enter a valid PayMe account number');
    }

    // Validate PIN
    if (pin.trim().isEmpty) {
      throw const PaymeException('PIN is required');
    }

    if (pin.length != 4) {
      throw const PaymeException('PIN must be 4 digits');
    }

    // Validate amount
    if (amount <= 0) {
      throw const PaymeException('Amount must be greater than zero');
    }

    if (amount < 1.0) {
      throw const PaymeException('Minimum transaction amount is KES 1.00');
    }

    if (amount > 300000.0) {
      throw const PaymeException(
          'Maximum transaction amount is KES 300,000.00');
    }
  }

  /// Query payment status (for demo purposes, always returns success)
  static Future<PaymePaymentStatus> queryPaymentStatus(
      String transactionId) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      return PaymePaymentStatus(
        transactionId: transactionId,
        isSuccess: true,
        status: 'COMPLETED',
        message: 'Payment completed successfully',
      );
    } catch (e) {
      debugPrint('Failed to query PayMe payment status: $e');
      throw PaymeException('Failed to check payment status');
    }
  }
}

/// PayMe Payment Response
class PaymePaymentResponse {
  final bool isSuccess;
  final String transactionId;
  final String? message;
  final String accountNumber;
  final double amount;

  PaymePaymentResponse({
    required this.isSuccess,
    required this.transactionId,
    this.message,
    required this.accountNumber,
    required this.amount,
  });

  factory PaymePaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymePaymentResponse(
      isSuccess: json['isSuccess'] ?? false,
      transactionId: json['transactionId'] ?? '',
      message: json['message'],
      accountNumber: json['accountNumber'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isSuccess': isSuccess,
      'transactionId': transactionId,
      'message': message,
      'accountNumber': accountNumber,
      'amount': amount,
    };
  }
}

/// PayMe Payment Status
class PaymePaymentStatus {
  final String transactionId;
  final bool isSuccess;
  final String status;
  final String? message;

  PaymePaymentStatus({
    required this.transactionId,
    required this.isSuccess,
    required this.status,
    this.message,
  });

  factory PaymePaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymePaymentStatus(
      transactionId: json['transactionId'] ?? '',
      isSuccess: json['isSuccess'] ?? false,
      status: json['status'] ?? 'UNKNOWN',
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'isSuccess': isSuccess,
      'status': status,
      'message': message,
    };
  }
}

/// PayMe Exception
class PaymeException implements Exception {
  final String message;

  const PaymeException(this.message);

  @override
  String toString() => 'PaymeException: $message';
}

