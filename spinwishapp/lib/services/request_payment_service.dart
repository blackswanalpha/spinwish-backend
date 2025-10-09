import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:spinwishapp/models/payment.dart';
import 'package:spinwishapp/services/payment_service.dart';
import 'package:spinwishapp/services/user_requests_service.dart';
import 'package:spinwishapp/services/auth_service.dart';
import 'package:spinwishapp/services/api_service.dart';

class RequestPaymentService extends ChangeNotifier {
  static final RequestPaymentService _instance =
      RequestPaymentService._internal();
  factory RequestPaymentService() => _instance;
  RequestPaymentService._internal();

  // Payment state
  Map<String, Payment> _pendingPayments = {};
  Map<String, PlaySongResponse> _pendingRequests = {};
  bool _isProcessingPayment = false;

  // Getters
  Map<String, Payment> get pendingPayments =>
      Map.unmodifiable(_pendingPayments);
  Map<String, PlaySongResponse> get pendingRequests =>
      Map.unmodifiable(_pendingRequests);
  bool get isProcessingPayment => _isProcessingPayment;

  /// Create a song request with integrated payment flow
  Future<Map<String, dynamic>> createRequestWithPayment({
    required String djId,
    required String songId,
    required double tipAmount,
    required PaymentMethod paymentMethod,
    String? message,
    String? sessionId,
  }) async {
    _isProcessingPayment = true;
    notifyListeners();

    try {
      // Get current user
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Validate payment amount
      if (!PaymentService.isValidAmount(tipAmount)) {
        throw Exception(
            'Invalid payment amount. Must be between KSH 1.00 and KSH 500.00');
      }

      // Create the song request first (in pending state)
      final request = await UserRequestsService.requestSong(
        djId: djId,
        songId: songId,
        tipAmount: tipAmount,
        message: message,
        sessionId: sessionId,
      );

      // Store pending request
      _pendingRequests[request.id] = request;

      // Process payment
      final payment = await PaymentService.processSongRequestPayment(
        userId: currentUser.id,
        sessionId: sessionId ?? '',
        songId: songId,
        amount: tipAmount,
        method: paymentMethod,
        message: message,
      );

      // Store pending payment
      _pendingPayments[payment.id] = payment;

      _isProcessingPayment = false;
      notifyListeners();

      if (payment.status == PaymentStatus.completed) {
        // Payment successful - confirm the request
        await _confirmRequestPayment(request.id, payment.id);

        return {
          'success': true,
          'request': request,
          'payment': payment,
          'message': 'Request submitted and payment processed successfully!',
        };
      } else {
        // Payment failed - cancel the request
        await _cancelRequestPayment(request.id, payment.id);

        return {
          'success': false,
          'request': request,
          'payment': payment,
          'message': 'Payment failed. Request has been cancelled.',
        };
      }
    } catch (e) {
      _isProcessingPayment = false;
      notifyListeners();

      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to process request and payment.',
      };
    }
  }

  /// Process tip payment for DJ
  Future<Map<String, dynamic>> processTipPayment({
    required String djId,
    required String sessionId,
    required double tipAmount,
    required PaymentMethod paymentMethod,
    String? message,
    bool isAnonymous = false,
  }) async {
    _isProcessingPayment = true;
    notifyListeners();

    try {
      // Get current user
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Validate payment amount
      if (!PaymentService.isValidAmount(tipAmount)) {
        throw Exception(
            'Invalid tip amount. Must be between KSH 1.00 and KSH 500.00');
      }

      // Process tip payment
      final payment = await PaymentService.processTipPayment(
        userId: currentUser.id,
        djId: djId,
        sessionId: sessionId,
        amount: tipAmount,
        method: paymentMethod,
        message: message,
        isAnonymous: isAnonymous,
      );

      // Store pending payment
      _pendingPayments[payment.id] = payment;

      _isProcessingPayment = false;
      notifyListeners();

      if (payment.status == PaymentStatus.completed) {
        // Notify backend about successful tip
        await _notifyTipPaymentSuccess(payment);

        return {
          'success': true,
          'payment': payment,
          'message': 'Tip sent successfully!',
        };
      } else {
        return {
          'success': false,
          'payment': payment,
          'message': 'Tip payment failed. Please try again.',
        };
      }
    } catch (e) {
      _isProcessingPayment = false;
      notifyListeners();

      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to process tip payment.',
      };
    }
  }

  /// Confirm request payment success
  Future<void> _confirmRequestPayment(
      String requestId, String paymentId) async {
    try {
      // Call backend API to confirm payment
      await ApiService.postJson(
        '/requests/$requestId/confirm-payment',
        {
          'paymentId': paymentId,
          'status': 'confirmed',
        },
        includeAuth: true,
      );

      // Remove from pending
      _pendingRequests.remove(requestId);
      _pendingPayments.remove(paymentId);

      debugPrint('Request payment confirmed: $requestId');
    } catch (e) {
      debugPrint('Failed to confirm request payment: $e');
    }
  }

  /// Cancel request payment
  Future<void> _cancelRequestPayment(String requestId, String paymentId) async {
    try {
      // Call backend API to cancel request
      await ApiService.postJson(
        '/requests/$requestId/cancel-payment',
        {
          'paymentId': paymentId,
          'status': 'cancelled',
        },
        includeAuth: true,
      );

      // Remove from pending
      _pendingRequests.remove(requestId);
      _pendingPayments.remove(paymentId);

      debugPrint('Request payment cancelled: $requestId');
    } catch (e) {
      debugPrint('Failed to cancel request payment: $e');
    }
  }

  /// Notify backend about successful tip payment
  Future<void> _notifyTipPaymentSuccess(Payment payment) async {
    try {
      await ApiService.postJson(
        '/payments/tip-success',
        {
          'paymentId': payment.id,
          'djId': payment.djId,
          'sessionId': payment.sessionId,
          'amount': payment.amount,
          'userId': payment.userId,
          'isAnonymous': payment.metadata?['isAnonymous'] ?? false,
          'message': payment.metadata?['message'],
        },
        includeAuth: true,
      );

      // Remove from pending
      _pendingPayments.remove(payment.id);

      debugPrint('Tip payment success notified: ${payment.id}');
    } catch (e) {
      debugPrint('Failed to notify tip payment success: $e');
    }
  }

  /// Get payment history for current user
  Future<List<Payment>> getPaymentHistory() async {
    try {
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) return [];

      return await PaymentService.getPaymentHistory(currentUser.id);
    } catch (e) {
      debugPrint('Failed to get payment history: $e');
      return [];
    }
  }

  /// Get available payment methods
  Future<List<PaymentMethod>> getAvailablePaymentMethods() async {
    try {
      return await PaymentService.getAvailablePaymentMethods();
    } catch (e) {
      debugPrint('Failed to get payment methods: $e');
      return [PaymentMethod.creditCard, PaymentMethod.debitCard];
    }
  }

  /// Calculate total cost including fees
  double calculateTotalCost(double baseAmount) {
    return PaymentService.getTotalAmount(baseAmount);
  }

  /// Calculate processing fee
  double calculateProcessingFee(double baseAmount) {
    return PaymentService.calculateProcessingFee(baseAmount);
  }

  /// Validate payment amount
  bool isValidPaymentAmount(double amount) {
    return PaymentService.isValidAmount(amount);
  }

  /// Get payment statistics for current user
  Future<Map<String, dynamic>> getPaymentStatistics() async {
    try {
      final payments = await getPaymentHistory();

      final totalSpent = payments.fold<double>(
          0.0,
          (sum, payment) => payment.status == PaymentStatus.completed
              ? sum + payment.amount
              : sum);

      final requestPayments =
          payments.where((p) => p.type == PaymentType.songRequest).toList();
      final tipPayments =
          payments.where((p) => p.type == PaymentType.tip).toList();

      final totalRequests = requestPayments.length;
      final totalTips = tipPayments.length;

      final avgRequestAmount = totalRequests > 0
          ? requestPayments.fold<double>(0.0, (sum, p) => sum + p.amount) /
              totalRequests
          : 0.0;

      final avgTipAmount = totalTips > 0
          ? tipPayments.fold<double>(0.0, (sum, p) => sum + p.amount) /
              totalTips
          : 0.0;

      return {
        'totalSpent': totalSpent,
        'totalRequests': totalRequests,
        'totalTips': totalTips,
        'averageRequestAmount': avgRequestAmount,
        'averageTipAmount': avgTipAmount,
        'successfulPayments':
            payments.where((p) => p.status == PaymentStatus.completed).length,
        'failedPayments':
            payments.where((p) => p.status == PaymentStatus.failed).length,
      };
    } catch (e) {
      debugPrint('Failed to get payment statistics: $e');
      return {};
    }
  }

  /// Clear all pending payments and requests
  void clearPendingData() {
    _pendingPayments.clear();
    _pendingRequests.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    clearPendingData();
    super.dispose();
  }
}
