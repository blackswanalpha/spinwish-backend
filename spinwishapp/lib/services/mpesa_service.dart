import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:spinwishapp/services/api_service.dart';
import 'package:spinwishapp/models/payment.dart';

/// Custom exception for M-Pesa related errors
class MpesaException implements Exception {
  final String message;
  final String? code;

  const MpesaException(this.message, [this.code]);

  @override
  String toString() => 'MpesaException: $message';
}

class MpesaPaymentRequest {
  final String phoneNumber;
  final double amount;
  final String? requestId;
  final String? djName;
  final String description;

  MpesaPaymentRequest({
    required this.phoneNumber,
    required this.amount,
    this.requestId,
    this.djName,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'amount': amount.toString(),
        'requestId': requestId,
        'djName': djName,
      };
}

class MpesaPaymentResponse {
  final String checkoutRequestId;
  final String merchantRequestId;
  final String responseCode;
  final String responseDescription;
  final String customerMessage;

  MpesaPaymentResponse({
    required this.checkoutRequestId,
    required this.merchantRequestId,
    required this.responseCode,
    required this.responseDescription,
    required this.customerMessage,
  });

  factory MpesaPaymentResponse.fromJson(Map<String, dynamic> json) {
    return MpesaPaymentResponse(
      checkoutRequestId: json['CheckoutRequestID'] ?? '',
      merchantRequestId: json['MerchantRequestID'] ?? '',
      responseCode: json['ResponseCode'] ?? '',
      responseDescription: json['ResponseDescription'] ?? '',
      customerMessage: json['CustomerMessage'] ?? '',
    );
  }

  bool get isSuccess => responseCode == '0';
}

class MpesaCallbackResponse {
  final String merchantRequestId;
  final String checkoutRequestId;
  final int resultCode;
  final String resultDesc;
  final String? mpesaReceiptNumber;
  final double? amount;
  final String? transactionDate;
  final String? phoneNumber;

  MpesaCallbackResponse({
    required this.merchantRequestId,
    required this.checkoutRequestId,
    required this.resultCode,
    required this.resultDesc,
    this.mpesaReceiptNumber,
    this.amount,
    this.transactionDate,
    this.phoneNumber,
  });

  factory MpesaCallbackResponse.fromJson(Map<String, dynamic> json) {
    final body = json['Body'] ?? {};
    final stkCallback = body['stkCallback'] ?? {};
    final callbackMetadata = stkCallback['CallbackMetadata'] ?? {};
    final items = callbackMetadata['Item'] as List? ?? [];

    String? receiptNumber;
    double? amount;
    String? transactionDate;
    String? phoneNumber;

    for (var item in items) {
      switch (item['Name']) {
        case 'MpesaReceiptNumber':
          receiptNumber = item['Value']?.toString();
          break;
        case 'Amount':
          amount = double.tryParse(item['Value']?.toString() ?? '0');
          break;
        case 'TransactionDate':
          transactionDate = item['Value']?.toString();
          break;
        case 'PhoneNumber':
          phoneNumber = item['Value']?.toString();
          break;
      }
    }

    return MpesaCallbackResponse(
      merchantRequestId: stkCallback['MerchantRequestID'] ?? '',
      checkoutRequestId: stkCallback['CheckoutRequestID'] ?? '',
      resultCode: stkCallback['ResultCode'] ?? -1,
      resultDesc: stkCallback['ResultDesc'] ?? '',
      mpesaReceiptNumber: receiptNumber,
      amount: amount,
      transactionDate: transactionDate,
      phoneNumber: phoneNumber,
    );
  }

  bool get isSuccess => resultCode == 0;
}

class MpesaService {
  static const String _baseEndpoint = '/payment';

  /// Initiate STK Push for M-Pesa payment
  static Future<MpesaPaymentResponse> initiateStkPush({
    required String phoneNumber,
    required double amount,
    String? requestId,
    String? djName,
  }) async {
    try {
      // Validate inputs before making the request
      _validatePaymentInputs(phoneNumber, amount);

      final request = MpesaPaymentRequest(
        phoneNumber: _formatPhoneNumber(phoneNumber),
        amount: amount,
        requestId: requestId,
        djName: djName,
        description: 'SpinWish Payment',
      );

      final response = await ApiService.postJson(
        '$_baseEndpoint/mpesa/stkpush',
        request.toJson(),
        includeAuth: true,
      );

      return MpesaPaymentResponse.fromJson(response);
    } on FormatException catch (e) {
      debugPrint('Invalid response format: $e');
      throw MpesaException('Invalid response from payment service');
    } on TimeoutException catch (e) {
      debugPrint('Request timeout: $e');
      throw MpesaException('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('M-Pesa STK Push failed: $e');
      if (e is MpesaException) {
        rethrow;
      }
      throw MpesaException('Payment initiation failed. Please try again.');
    }
  }

  /// Query STK Push status
  static Future<MpesaCallbackResponse> queryStkPushStatus(
      String checkoutRequestId) async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/stk/query/$checkoutRequestId',
        includeAuth: true,
      );

      final data = ApiService.handleResponse(response);
      return MpesaCallbackResponse.fromJson(data);
    } catch (e) {
      debugPrint('M-Pesa status query failed: $e');
      rethrow;
    }
  }

  /// Poll payment status until completion or timeout with exponential backoff
  static Future<PaymentStatus> pollPaymentStatus(
    String checkoutRequestId, {
    Duration timeout = const Duration(minutes: 2),
    Duration initialInterval = const Duration(seconds: 3),
    int maxRetries = 20,
  }) async {
    final endTime = DateTime.now().add(timeout);
    Duration currentInterval = initialInterval;
    int retryCount = 0;
    int consecutiveErrors = 0;

    while (DateTime.now().isBefore(endTime) && retryCount < maxRetries) {
      try {
        final status = await queryStkPushStatus(checkoutRequestId);

        if (status.isSuccess) {
          debugPrint('Payment completed successfully');
          return PaymentStatus.completed;
        } else if (status.resultCode != -1) {
          // Payment failed or cancelled
          debugPrint('Payment failed with code: ${status.resultCode}');
          return PaymentStatus.failed;
        }

        // Reset consecutive error count on successful API call
        consecutiveErrors = 0;

        // Still processing, wait and try again
        debugPrint(
            'Payment still processing, waiting ${currentInterval.inSeconds}s...');
        await Future.delayed(currentInterval);

        // Exponential backoff with jitter
        currentInterval = Duration(
            milliseconds: (currentInterval.inMilliseconds * 1.2).round() +
                (DateTime.now().millisecondsSinceEpoch % 1000));

        // Cap the interval at 15 seconds
        if (currentInterval.inSeconds > 15) {
          currentInterval = const Duration(seconds: 15);
        }
      } catch (e) {
        consecutiveErrors++;
        debugPrint('Status polling error (attempt ${retryCount + 1}): $e');

        // If we have too many consecutive errors, fail fast
        if (consecutiveErrors >= 5) {
          debugPrint('Too many consecutive errors, stopping polling');
          return PaymentStatus.failed;
        }

        // Wait before retrying, with exponential backoff for errors
        await Future.delayed(Duration(seconds: 2 * consecutiveErrors));
      }

      retryCount++;
    }

    // Timeout reached or max retries exceeded
    debugPrint('Payment polling timeout or max retries reached');
    return PaymentStatus.pending;
  }

  /// Format phone number to M-Pesa format (254XXXXXXXXX)
  static String _formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Handle different formats
    if (cleaned.startsWith('254')) {
      return cleaned;
    } else if (cleaned.startsWith('0')) {
      return '254${cleaned.substring(1)}';
    } else if (cleaned.length == 9) {
      return '254$cleaned';
    }

    return cleaned;
  }

  /// Validate Kenyan phone number
  static bool isValidKenyanPhoneNumber(String phoneNumber) {
    final formatted = _formatPhoneNumber(phoneNumber);

    // Should be 12 digits starting with 254
    if (formatted.length != 12 || !formatted.startsWith('254')) {
      return false;
    }

    // Check if it's a valid Kenyan mobile number
    final prefix = formatted.substring(3, 6);
    final validPrefixes = [
      '701',
      '702',
      '703',
      '704',
      '705',
      '706',
      '707',
      '708',
      '709',
      '710',
      '711',
      '712',
      '713',
      '714',
      '715',
      '716',
      '717',
      '718',
      '719',
      '720',
      '721',
      '722',
      '723',
      '724',
      '725',
      '726',
      '727',
      '728',
      '729',
      '730',
      '731',
      '732',
      '733',
      '734',
      '735',
      '736',
      '737',
      '738',
      '739',
      '740',
      '741',
      '742',
      '743',
      '744',
      '745',
      '746',
      '747',
      '748',
      '749',
      '750',
      '751',
      '752',
      '753',
      '754',
      '755',
      '756',
      '757',
      '758',
      '759',
      '760',
      '761',
      '762',
      '763',
      '764',
      '765',
      '766',
      '767',
      '768',
      '769',
      '770',
      '771',
      '772',
      '773',
      '774',
      '775',
      '776',
      '777',
      '778',
      '779',
      '780',
      '781',
      '782',
      '783',
      '784',
      '785',
      '786',
      '787',
      '788',
      '789',
      '790',
      '791',
      '792',
      '793',
      '794',
      '795',
      '796',
      '797',
      '798',
      '799'
    ];

    return validPrefixes.contains(prefix);
  }

  /// Format phone number for display
  static String formatPhoneNumberForDisplay(String phoneNumber) {
    final formatted = _formatPhoneNumber(phoneNumber);
    if (formatted.length == 12 && formatted.startsWith('254')) {
      return '+${formatted.substring(0, 3)} ${formatted.substring(3, 6)} ${formatted.substring(6, 9)} ${formatted.substring(9)}';
    }
    return phoneNumber;
  }

  /// Validate payment inputs before processing
  static void _validatePaymentInputs(String phoneNumber, double amount) {
    // Validate phone number
    if (phoneNumber.trim().isEmpty) {
      throw const MpesaException('Phone number is required');
    }

    if (!isValidKenyanPhoneNumber(phoneNumber)) {
      throw const MpesaException('Please enter a valid Kenyan mobile number');
    }

    // Validate amount
    if (amount <= 0) {
      throw const MpesaException('Amount must be greater than zero');
    }

    if (amount < 1.0) {
      throw const MpesaException('Minimum transaction amount is KES 1.00');
    }

    if (amount > 300000.0) {
      throw const MpesaException(
          'Maximum transaction amount is KES 300,000.00');
    }

    // Check decimal places
    if ((amount * 100).round() != (amount * 100)) {
      throw const MpesaException(
          'Amount cannot have more than 2 decimal places');
    }
  }
}
