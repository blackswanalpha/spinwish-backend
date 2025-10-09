enum TipStatus { pending, processing, completed, failed, cancelled }

class Tip {
  final String id;
  final String userId;
  final String djId;
  final String sessionId;
  final double amount;
  final String? message;
  final TipStatus status;
  final DateTime timestamp;
  final String? paymentId;
  final bool isAnonymous;

  Tip({
    required this.id,
    required this.userId,
    required this.djId,
    required this.sessionId,
    required this.amount,
    this.message,
    required this.status,
    required this.timestamp,
    this.paymentId,
    this.isAnonymous = false,
  });

  factory Tip.fromJson(Map<String, dynamic> json) => Tip(
        id: json['id'],
        userId: json['userId'],
        djId: json['djId'],
        sessionId: json['sessionId'],
        amount: json['amount'].toDouble(),
        message: json['message'],
        status: TipStatus.values[json['status']],
        timestamp: DateTime.parse(json['timestamp']),
        paymentId: json['paymentId'],
        isAnonymous: json['isAnonymous'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'djId': djId,
        'sessionId': sessionId,
        'amount': amount,
        'message': message,
        'status': status.index,
        'timestamp': timestamp.toIso8601String(),
        'paymentId': paymentId,
        'isAnonymous': isAnonymous,
      };

  Tip copyWith({
    String? id,
    String? userId,
    String? djId,
    String? sessionId,
    double? amount,
    String? message,
    TipStatus? status,
    DateTime? timestamp,
    String? paymentId,
    bool? isAnonymous,
  }) {
    return Tip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      djId: djId ?? this.djId,
      sessionId: sessionId ?? this.sessionId,
      amount: amount ?? this.amount,
      message: message ?? this.message,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      paymentId: paymentId ?? this.paymentId,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  String get formattedAmount => 'KSH ${amount.toStringAsFixed(2)}';

  String get statusDisplayName {
    switch (status) {
      case TipStatus.pending:
        return 'Pending';
      case TipStatus.processing:
        return 'Processing';
      case TipStatus.completed:
        return 'Completed';
      case TipStatus.failed:
        return 'Failed';
      case TipStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class TipPreset {
  final double amount;
  final String label;
  final String? emoji;

  const TipPreset({
    required this.amount,
    required this.label,
    this.emoji,
  });

  String get formattedAmount => 'KSH ${amount.toStringAsFixed(0)}';
}

// Common tip presets (in Kenyan Shillings)
class TipPresets {
  static const List<TipPreset> common = [
    TipPreset(amount: 50.0, label: 'Small Tip', emoji: '☕'),
    TipPreset(amount: 100.0, label: 'Good Vibes', emoji: '🎵'),
    TipPreset(amount: 200.0, label: 'Great Set', emoji: '🔥'),
    TipPreset(amount: 500.0, label: 'Amazing!', emoji: '⭐'),
    TipPreset(amount: 1000.0, label: 'Legendary', emoji: '👑'),
  ];
}
