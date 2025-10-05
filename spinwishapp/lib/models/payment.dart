enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded
}

enum PaymentMethod {
  creditCard,
  debitCard,
  paypal,
  applePay,
  googlePay,
  venmo,
  cashApp,
  mpesa,
  payme
}

enum PaymentType { songRequest, tip, subscription, other }

class Payment {
  final String id;
  final String userId;
  final PaymentType type;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime timestamp;
  final String? description;
  final String? sessionId;
  final String? djId;
  final String? songId;
  final String? transactionId;
  final String? receiptUrl;
  final Map<String, dynamic>? metadata;

  Payment({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.method,
    required this.status,
    required this.timestamp,
    this.description,
    this.sessionId,
    this.djId,
    this.songId,
    this.transactionId,
    this.receiptUrl,
    this.metadata,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'],
        userId: json['userId'],
        type: PaymentType.values[json['type']],
        amount: json['amount'].toDouble(),
        method: PaymentMethod.values[json['method']],
        status: PaymentStatus.values[json['status']],
        timestamp: DateTime.parse(json['timestamp']),
        description: json['description'],
        sessionId: json['sessionId'],
        djId: json['djId'],
        songId: json['songId'],
        transactionId: json['transactionId'],
        receiptUrl: json['receiptUrl'],
        metadata: json['metadata'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type.index,
        'amount': amount,
        'method': method.index,
        'status': status.index,
        'timestamp': timestamp.toIso8601String(),
        'description': description,
        'sessionId': sessionId,
        'djId': djId,
        'songId': songId,
        'transactionId': transactionId,
        'receiptUrl': receiptUrl,
        'metadata': metadata,
      };

  Payment copyWith({
    String? id,
    String? userId,
    PaymentType? type,
    double? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? timestamp,
    String? description,
    String? sessionId,
    String? djId,
    String? songId,
    String? transactionId,
    String? receiptUrl,
    Map<String, dynamic>? metadata,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      sessionId: sessionId ?? this.sessionId,
      djId: djId ?? this.djId,
      songId: songId ?? this.songId,
      transactionId: transactionId ?? this.transactionId,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  String get formattedAmount => 'KSH ${amount.toStringAsFixed(2)}';

  String get statusDisplayName {
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

  String get methodDisplayName {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.venmo:
        return 'Venmo';
      case PaymentMethod.cashApp:
        return 'Cash App';
      case PaymentMethod.mpesa:
        return 'M-Pesa';
      case PaymentMethod.payme:
        return 'PayMe';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case PaymentType.songRequest:
        return 'Song Request';
      case PaymentType.tip:
        return 'Tip';
      case PaymentType.subscription:
        return 'Subscription';
      case PaymentType.other:
        return 'Other';
    }
  }
}
