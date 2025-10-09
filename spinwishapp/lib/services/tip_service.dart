import 'package:spinwishapp/models/tip.dart';
import 'package:spinwishapp/models/payment.dart';
import 'package:spinwishapp/services/payment_service.dart';

class TipService {
  /// Send a tip to a DJ
  static Future<Tip> sendTip({
    required String userId,
    required String djId,
    required String sessionId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? message,
    bool isAnonymous = false,
  }) async {
    // Create tip record
    final tip = Tip(
      id: 'tip_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      djId: djId,
      sessionId: sessionId,
      amount: amount,
      message: message,
      status: TipStatus.pending,
      timestamp: DateTime.now(),
      isAnonymous: isAnonymous,
    );

    try {
      // Process payment
      final payment = await PaymentService.processTipPayment(
        userId: userId,
        djId: djId,
        sessionId: sessionId,
        amount: amount,
        method: paymentMethod,
        message: message,
        isAnonymous: isAnonymous,
      );

      // Update tip status based on payment result
      if (payment.status == PaymentStatus.completed) {
        return tip.copyWith(
          status: TipStatus.completed,
          paymentId: payment.id,
        );
      } else {
        return tip.copyWith(status: TipStatus.failed);
      }
    } catch (e) {
      return tip.copyWith(status: TipStatus.failed);
    }
  }

  /// Get tip history for a user
  static Future<List<Tip>> getTipHistory(String userId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Tip(
        id: 'tip_001',
        userId: userId,
        djId: '1',
        sessionId: '1',
        amount: 200.0,
        message: 'Great set! 🔥',
        status: TipStatus.completed,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        paymentId: 'pay_tip_001',
        isAnonymous: false,
      ),
      Tip(
        id: 'tip_002',
        userId: userId,
        djId: '2',
        sessionId: '2',
        amount: 100.0,
        status: TipStatus.completed,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        paymentId: 'pay_tip_002',
        isAnonymous: true,
      ),
    ];
  }

  /// Get tips received by a DJ
  static Future<List<Tip>> getTipsForDJ(String djId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Tip(
        id: 'tip_003',
        userId: 'user1',
        djId: djId,
        sessionId: '1',
        amount: 500.0,
        message: 'Amazing music selection!',
        status: TipStatus.completed,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        paymentId: 'pay_tip_003',
        isAnonymous: false,
      ),
      Tip(
        id: 'tip_004',
        userId: 'user2',
        djId: djId,
        sessionId: '1',
        amount: 200.0,
        status: TipStatus.completed,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        paymentId: 'pay_tip_004',
        isAnonymous: true,
      ),
    ];
  }

  /// Get total tips for a session
  static Future<double> getTotalTipsForSession(String sessionId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));

    // In a real app, this would sum all tips for the session
    return 1850.0;
  }

  /// Get tip statistics for a DJ
  static Future<TipStatistics> getTipStatistics(String djId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    return TipStatistics(
      totalTips: 8500.0,
      tipCount: 18,
      averageTip: 472.22,
      topTip: 1000.0,
      thisWeekTips: 3200.0,
      thisMonthTips: 8500.0,
    );
  }

  /// Validate tip amount (in KSH)
  static bool isValidTipAmount(double amount) {
    return amount >= 10.0 && amount <= 10000.0;
  }

  /// Get suggested tip amounts based on context (in KSH)
  static List<TipPreset> getSuggestedTips({
    double? averageSessionTip,
    String? djRating,
  }) {
    // Base presets
    List<TipPreset> suggestions = List.from(TipPresets.common);

    // Adjust based on context
    if (averageSessionTip != null && averageSessionTip > 300.0) {
      // Higher average tips in this session, suggest higher amounts
      suggestions = [
        const TipPreset(amount: 200.0, label: 'Good Vibes', emoji: '🎵'),
        const TipPreset(amount: 500.0, label: 'Great Set', emoji: '🔥'),
        const TipPreset(amount: 1000.0, label: 'Amazing!', emoji: '⭐'),
        const TipPreset(amount: 2000.0, label: 'Incredible', emoji: '👑'),
        const TipPreset(amount: 5000.0, label: 'Legendary', emoji: '💎'),
      ];
    }

    return suggestions;
  }
}

class TipStatistics {
  final double totalTips;
  final int tipCount;
  final double averageTip;
  final double topTip;
  final double thisWeekTips;
  final double thisMonthTips;

  TipStatistics({
    required this.totalTips,
    required this.tipCount,
    required this.averageTip,
    required this.topTip,
    required this.thisWeekTips,
    required this.thisMonthTips,
  });

  String get formattedTotalTips => 'KSH ${totalTips.toStringAsFixed(2)}';
  String get formattedAverageTip => 'KSH ${averageTip.toStringAsFixed(2)}';
  String get formattedTopTip => 'KSH ${topTip.toStringAsFixed(2)}';
  String get formattedThisWeekTips => 'KSH ${thisWeekTips.toStringAsFixed(2)}';
  String get formattedThisMonthTips =>
      'KSH ${thisMonthTips.toStringAsFixed(2)}';
}
