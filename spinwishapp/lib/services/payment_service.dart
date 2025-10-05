import 'package:spinwishapp/models/payment.dart';
import 'package:spinwishapp/services/api_service.dart';

class PaymentService {
  // Simulate payment processing delay
  static const Duration _processingDelay = Duration(seconds: 2);
  static const String _baseEndpoint = '/payment';

  /// Process a song request payment
  static Future<Payment> processSongRequestPayment({
    required String userId,
    required String sessionId,
    required String songId,
    required double amount,
    required PaymentMethod method,
    String? message,
  }) async {
    try {
      // Create payment request for backend
      final paymentRequest = {
        'userId': userId,
        'sessionId': sessionId,
        'songId': songId,
        'amount': amount,
        'method': method.name,
        'type': 'songRequest',
        'message': message,
      };

      // Call backend payment API
      final response = await ApiService.postJson(
        '$_baseEndpoint/process-request-payment',
        paymentRequest,
        includeAuth: true,
      );

      return Payment.fromJson(response);
    } catch (e) {
      // Fallback to simulation for development
      await Future.delayed(_processingDelay);

      final payment = Payment(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        type: PaymentType.songRequest,
        amount: amount,
        method: method,
        status: PaymentStatus.processing,
        timestamp: DateTime.now(),
        description: 'Song request payment',
        sessionId: sessionId,
        songId: songId,
        transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        metadata: message != null ? {'message': message} : null,
      );

      // Simulate success/failure (90% success rate)
      final isSuccess = DateTime.now().millisecond % 10 != 0;

      if (isSuccess) {
        return payment.copyWith(
          status: PaymentStatus.completed,
          receiptUrl: 'https://example.com/receipt/${payment.id}',
        );
      } else {
        return payment.copyWith(status: PaymentStatus.failed);
      }
    }
  }

  /// Process a tip payment
  static Future<Payment> processTipPayment({
    required String userId,
    required String djId,
    required String sessionId,
    required double amount,
    required PaymentMethod method,
    String? message,
    bool isAnonymous = false,
  }) async {
    try {
      // Create tip payment request for backend
      final paymentRequest = {
        'userId': userId,
        'djId': djId,
        'sessionId': sessionId,
        'amount': amount,
        'method': method.name,
        'type': 'tip',
        'message': message,
        'isAnonymous': isAnonymous,
      };

      // Call backend payment API
      final response = await ApiService.postJson(
        '$_baseEndpoint/process-tip-payment',
        paymentRequest,
        includeAuth: true,
      );

      return Payment.fromJson(response);
    } catch (e) {
      // Fallback to simulation for development
      await Future.delayed(_processingDelay);

      final payment = Payment(
        id: 'tip_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        type: PaymentType.tip,
        amount: amount,
        method: method,
        status: PaymentStatus.processing,
        timestamp: DateTime.now(),
        description: 'DJ tip',
        sessionId: sessionId,
        djId: djId,
        transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        metadata: {
          if (message != null) 'message': message,
          'isAnonymous': isAnonymous,
        },
      );

      // Simulate success/failure (95% success rate for tips)
      final isSuccess = DateTime.now().millisecond % 20 != 0;

      if (isSuccess) {
        return payment.copyWith(
          status: PaymentStatus.completed,
          receiptUrl: 'https://example.com/receipt/${payment.id}',
        );
      } else {
        return payment.copyWith(status: PaymentStatus.failed);
      }
    }
  }

  /// Get payment history for a user
  static Future<List<Payment>> getPaymentHistory(String userId) async {
    try {
      // Call backend API to get payment history
      final response = await ApiService.get(
        '$_baseEndpoint/history/$userId',
        includeAuth: true,
      );

      final data = ApiService.handleResponse(response);
      if (data is List) {
        return data
            .map((item) => Payment.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      // Fallback to mock data for development
      await Future.delayed(const Duration(milliseconds: 500));

      // Return sample payment history
      return [
        Payment(
          id: 'pay_001',
          userId: userId,
          type: PaymentType.songRequest,
          amount: 7.50,
          method: PaymentMethod.creditCard,
          status: PaymentStatus.completed,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          description: 'Song request: Electric Dreams',
          songId: '1',
          sessionId: '1',
          transactionId: 'txn_001',
          receiptUrl: 'https://example.com/receipt/pay_001',
        ),
        Payment(
          id: 'tip_001',
          userId: userId,
          type: PaymentType.tip,
          amount: 10.00,
          method: PaymentMethod.applePay,
          status: PaymentStatus.completed,
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          description: 'Tip for DJ Nova',
          djId: '1',
          sessionId: '1',
          transactionId: 'txn_002',
          receiptUrl: 'https://example.com/receipt/tip_001',
          metadata: {'message': 'Great set! 🔥'},
        ),
      ];
    }
  }

  /// Get available payment methods for user
  static Future<List<PaymentMethod>> getAvailablePaymentMethods() async {
    // Simulate API call to check available payment methods
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      PaymentMethod.mpesa,
      PaymentMethod.payme,
      PaymentMethod.creditCard,
      PaymentMethod.debitCard,
      PaymentMethod.applePay,
      PaymentMethod.googlePay,
      PaymentMethod.paypal,
    ];
  }

  /// Validate payment amount
  static bool isValidAmount(double amount) {
    return amount >= 1.0 && amount <= 500.0;
  }

  /// Calculate processing fee
  static double calculateProcessingFee(double amount) {
    // 2.9% + KSH 0.30 processing fee (typical for payment processors)
    return (amount * 0.029) + 0.30;
  }

  /// Get total amount including fees
  static double getTotalAmount(double baseAmount) {
    return baseAmount + calculateProcessingFee(baseAmount);
  }

  /// Refund a payment
  static Future<Payment> refundPayment(String paymentId) async {
    // Simulate refund processing
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would call the payment processor's refund API
    // For now, we'll simulate a successful refund
    return Payment(
      id: 'ref_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user1', // This would come from the original payment
      type: PaymentType.other,
      amount: -10.00, // Negative amount for refund
      method: PaymentMethod.creditCard,
      status: PaymentStatus.completed,
      timestamp: DateTime.now(),
      description: 'Refund for payment $paymentId',
      transactionId: 'ref_txn_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
