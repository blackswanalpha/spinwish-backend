enum RequestHistoryStatus {
  pending,
  accepted,
  played,
  rejected,
  cancelled,
  expired,
}

enum RequestHistoryType {
  songRequest,
  tip,
  payment,
  subscription,
  refund,
}

class RequestHistoryItem {
  final String id;
  final String userId;
  final RequestHistoryType type;
  final RequestHistoryStatus status;
  final String title;
  final String? subtitle;
  final String? description;
  final double? amount;
  final String? currency;
  final String? djId;
  final String? djName;
  final String? sessionId;
  final String? sessionName;
  final String? songId;
  final String? songTitle;
  final String? artistName;
  final String? albumArt;
  final String? paymentMethodId;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? playedAt;
  final Map<String, dynamic>? metadata;

  RequestHistoryItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.title,
    this.subtitle,
    this.description,
    this.amount,
    this.currency,
    this.djId,
    this.djName,
    this.sessionId,
    this.sessionName,
    this.songId,
    this.songTitle,
    this.artistName,
    this.albumArt,
    this.paymentMethodId,
    this.transactionId,
    required this.createdAt,
    this.updatedAt,
    this.playedAt,
    this.metadata,
  });

  factory RequestHistoryItem.fromJson(Map<String, dynamic> json) => RequestHistoryItem(
        id: json['id'],
        userId: json['userId'],
        type: RequestHistoryType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'],
          orElse: () => RequestHistoryType.songRequest,
        ),
        status: RequestHistoryStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
          orElse: () => RequestHistoryStatus.pending,
        ),
        title: json['title'],
        subtitle: json['subtitle'],
        description: json['description'],
        amount: json['amount']?.toDouble(),
        currency: json['currency'],
        djId: json['djId'],
        djName: json['djName'],
        sessionId: json['sessionId'],
        sessionName: json['sessionName'],
        songId: json['songId'],
        songTitle: json['songTitle'],
        artistName: json['artistName'],
        albumArt: json['albumArt'],
        paymentMethodId: json['paymentMethodId'],
        transactionId: json['transactionId'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        playedAt: json['playedAt'] != null ? DateTime.parse(json['playedAt']) : null,
        metadata: json['metadata'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type.toString().split('.').last,
        'status': status.toString().split('.').last,
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'amount': amount,
        'currency': currency,
        'djId': djId,
        'djName': djName,
        'sessionId': sessionId,
        'sessionName': sessionName,
        'songId': songId,
        'songTitle': songTitle,
        'artistName': artistName,
        'albumArt': albumArt,
        'paymentMethodId': paymentMethodId,
        'transactionId': transactionId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'playedAt': playedAt?.toIso8601String(),
        'metadata': metadata,
      };

  RequestHistoryItem copyWith({
    String? id,
    String? userId,
    RequestHistoryType? type,
    RequestHistoryStatus? status,
    String? title,
    String? subtitle,
    String? description,
    double? amount,
    String? currency,
    String? djId,
    String? djName,
    String? sessionId,
    String? sessionName,
    String? songId,
    String? songTitle,
    String? artistName,
    String? albumArt,
    String? paymentMethodId,
    String? transactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? playedAt,
    Map<String, dynamic>? metadata,
  }) {
    return RequestHistoryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      djId: djId ?? this.djId,
      djName: djName ?? this.djName,
      sessionId: sessionId ?? this.sessionId,
      sessionName: sessionName ?? this.sessionName,
      songId: songId ?? this.songId,
      songTitle: songTitle ?? this.songTitle,
      artistName: artistName ?? this.artistName,
      albumArt: albumArt ?? this.albumArt,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      playedAt: playedAt ?? this.playedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case RequestHistoryType.songRequest:
        return 'Song Request';
      case RequestHistoryType.tip:
        return 'Tip';
      case RequestHistoryType.payment:
        return 'Payment';
      case RequestHistoryType.subscription:
        return 'Subscription';
      case RequestHistoryType.refund:
        return 'Refund';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case RequestHistoryStatus.pending:
        return 'Pending';
      case RequestHistoryStatus.accepted:
        return 'Accepted';
      case RequestHistoryStatus.played:
        return 'Played';
      case RequestHistoryStatus.rejected:
        return 'Rejected';
      case RequestHistoryStatus.cancelled:
        return 'Cancelled';
      case RequestHistoryStatus.expired:
        return 'Expired';
    }
  }

  String get formattedAmount {
    if (amount == null) return '';
    final currencySymbol = currency == 'USD' ? '\$' : currency ?? '';
    return '$currencySymbol${amount!.toStringAsFixed(2)}';
  }

  bool get isSuccessful {
    return status == RequestHistoryStatus.played || 
           status == RequestHistoryStatus.accepted;
  }

  bool get isPending {
    return status == RequestHistoryStatus.pending;
  }

  bool get isFailed {
    return status == RequestHistoryStatus.rejected || 
           status == RequestHistoryStatus.cancelled || 
           status == RequestHistoryStatus.expired;
  }
}

class RequestHistoryFilter {
  final RequestHistoryType? type;
  final RequestHistoryStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? djId;
  final double? minAmount;
  final double? maxAmount;

  RequestHistoryFilter({
    this.type,
    this.status,
    this.startDate,
    this.endDate,
    this.djId,
    this.minAmount,
    this.maxAmount,
  });

  Map<String, dynamic> toJson() => {
        'type': type?.toString().split('.').last,
        'status': status?.toString().split('.').last,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'djId': djId,
        'minAmount': minAmount,
        'maxAmount': maxAmount,
      };

  RequestHistoryFilter copyWith({
    RequestHistoryType? type,
    RequestHistoryStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? djId,
    double? minAmount,
    double? maxAmount,
  }) {
    return RequestHistoryFilter(
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      djId: djId ?? this.djId,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
    );
  }

  bool get hasActiveFilters {
    return type != null ||
           status != null ||
           startDate != null ||
           endDate != null ||
           djId != null ||
           minAmount != null ||
           maxAmount != null;
  }
}
