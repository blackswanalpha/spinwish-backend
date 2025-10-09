import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// PayMe Service for handling demo payments
class PaymeService {
  static const String _baseEndpoint = '/payment';

  /// Initiate a demo PayMe payment
  static Future<PaymePaymentResponse> initiateDemoPayment({
    required String accountNumber,
    required String pin,
    required double amount,
    String? requestId,
    String? djId,
  }) async {
    try {
      // Validate inputs
      _validatePaymentInputs(accountNumber, pin, amount);

      // Get base URL
      final baseUrl = await ApiService.getBaseUrl();
      final url = Uri.parse('$baseUrl$_baseEndpoint/payme/demo');

      debugPrint('🔵 Initiating PayMe payment to: $url');
      debugPrint('   Amount: KSH $amount');
      debugPrint('   RequestId: $requestId');
      debugPrint('   DjId: $djId');

      // Get auth token
      final token = await ApiService.getToken();

      // Call backend API to record the payment
      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'accountNumber': accountNumber,
          'pin': pin,
          'amount': amount,
          if (requestId != null) 'requestId': requestId,
          if (djId != null) 'djId': djId,
        }),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw PaymeException('Request timeout. Please try again.');
        },
      );

      debugPrint('📥 PayMe API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['isSuccess'] == true) {
          debugPrint('✅ PayMe payment recorded in backend');

          return PaymePaymentResponse(
            isSuccess: true,
            transactionId: data['transactionId'] as String,
            message:
                data['message'] as String? ?? 'Payment initiated successfully',
            accountNumber: accountNumber,
            amount: amount,
          );
        } else {
          throw PaymeException(data['message'] as String? ?? 'Payment failed');
        }
      } else {
        debugPrint(
            '❌ PayMe API error: ${response.statusCode} - ${response.body}');
        throw PaymeException('Payment failed. Please try again.');
      }
    } catch (e) {
      debugPrint('❌ PayMe payment failed: $e');
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
      throw const PaymeException('Please enter a valid PayMe account number');
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
