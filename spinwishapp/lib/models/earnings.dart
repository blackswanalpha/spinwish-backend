enum EarningsType { songRequest, tip, bonus }
enum PayoutStatus { pending, processing, completed, failed }

class Earnings {
  final String id;
  final String djId;
  final String? sessionId;
  final String? requestId;
  final EarningsType type;
  final double amount;
  final double platformFee;
  final double netAmount;
  final String currency;
  final DateTime createdAt;
  final String? description;
  final Map<String, dynamic>? metadata;

  Earnings({
    required this.id,
    required this.djId,
    this.sessionId,
    this.requestId,
    required this.type,
    required this.amount,
    required this.platformFee,
    required this.netAmount,
    required this.currency,
    required this.createdAt,
    this.description,
    this.metadata,
  });

  factory Earnings.fromJson(Map<String, dynamic> json) => Earnings(
    id: json['id'],
    djId: json['djId'],
    sessionId: json['sessionId'],
    requestId: json['requestId'],
    type: EarningsType.values.firstWhere((e) => e.name == json['type']),
    amount: json['amount'].toDouble(),
    platformFee: json['platformFee'].toDouble(),
    netAmount: json['netAmount'].toDouble(),
    currency: json['currency'],
    createdAt: DateTime.parse(json['createdAt']),
    description: json['description'],
    metadata: json['metadata'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'djId': djId,
    'sessionId': sessionId,
    'requestId': requestId,
    'type': type.name,
    'amount': amount,
    'platformFee': platformFee,
    'netAmount': netAmount,
    'currency': currency,
    'createdAt': createdAt.toIso8601String(),
    'description': description,
    'metadata': metadata,
  };
}

class Payout {
  final String id;
  final String djId;
  final double amount;
  final String currency;
  final PayoutStatus status;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final DateTime? completedAt;
  final String? paymentMethodId;
  final String? externalTransactionId;
  final String? failureReason;
  final List<String> earningsIds;

  Payout({
    required this.id,
    required this.djId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.requestedAt,
    this.processedAt,
    this.completedAt,
    this.paymentMethodId,
    this.externalTransactionId,
    this.failureReason,
    required this.earningsIds,
  });

  factory Payout.fromJson(Map<String, dynamic> json) => Payout(
    id: json['id'],
    djId: json['djId'],
    amount: json['amount'].toDouble(),
    currency: json['currency'],
    status: PayoutStatus.values.firstWhere((e) => e.name == json['status']),
    requestedAt: DateTime.parse(json['requestedAt']),
    processedAt: json['processedAt'] != null ? DateTime.parse(json['processedAt']) : null,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    paymentMethodId: json['paymentMethodId'],
    externalTransactionId: json['externalTransactionId'],
    failureReason: json['failureReason'],
    earningsIds: List<String>.from(json['earningsIds']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'djId': djId,
    'amount': amount,
    'currency': currency,
    'status': status.name,
    'requestedAt': requestedAt.toIso8601String(),
    'processedAt': processedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'paymentMethodId': paymentMethodId,
    'externalTransactionId': externalTransactionId,
    'failureReason': failureReason,
    'earningsIds': earningsIds,
  };
}

class EarningsSummary {
  final double totalEarnings;
  final double totalTips;
  final double totalRequests;
  final double pendingAmount;
  final double availableForPayout;
  final int totalTransactions;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<EarningsType, double> earningsByType;
  final List<DailyEarnings> dailyBreakdown;

  EarningsSummary({
    required this.totalEarnings,
    required this.totalTips,
    required this.totalRequests,
    required this.pendingAmount,
    required this.availableForPayout,
    required this.totalTransactions,
    required this.periodStart,
    required this.periodEnd,
    required this.earningsByType,
    required this.dailyBreakdown,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) => EarningsSummary(
    totalEarnings: json['totalEarnings'].toDouble(),
    totalTips: json['totalTips'].toDouble(),
    totalRequests: json['totalRequests'].toDouble(),
    pendingAmount: json['pendingAmount'].toDouble(),
    availableForPayout: json['availableForPayout'].toDouble(),
    totalTransactions: json['totalTransactions'],
    periodStart: DateTime.parse(json['periodStart']),
    periodEnd: DateTime.parse(json['periodEnd']),
    earningsByType: Map<EarningsType, double>.from(
      json['earningsByType'].map((key, value) => MapEntry(
        EarningsType.values.firstWhere((e) => e.name == key),
        value.toDouble(),
      )),
    ),
    dailyBreakdown: (json['dailyBreakdown'] as List)
        .map((item) => DailyEarnings.fromJson(item))
        .toList(),
  );
}

class DailyEarnings {
  final DateTime date;
  final double amount;
  final int transactions;

  DailyEarnings({
    required this.date,
    required this.amount,
    required this.transactions,
  });

  factory DailyEarnings.fromJson(Map<String, dynamic> json) => DailyEarnings(
    date: DateTime.parse(json['date']),
    amount: json['amount'].toDouble(),
    transactions: json['transactions'],
  );

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'amount': amount,
    'transactions': transactions,
  };
}
