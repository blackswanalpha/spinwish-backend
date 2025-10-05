enum PaymentMethodType {
  creditCard,
  debitCard,
  paypal,
  applePay,
  googlePay,
  bankTransfer,
  cryptocurrency,
  mpesa,
}

enum CardBrand {
  visa,
  mastercard,
  americanExpress,
  discover,
  jcb,
  dinersClub,
  unionPay,
  unknown,
}

class PaymentMethodModel {
  final String id;
  final String userId;
  final PaymentMethodType type;
  final String displayName;
  final String? last4Digits;
  final CardBrand? cardBrand;
  final String? expiryMonth;
  final String? expiryYear;
  final String? holderName;
  final String? email; // For PayPal
  final bool isDefault;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastUsed;
  final Map<String, dynamic>? metadata;

  PaymentMethodModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.displayName,
    this.last4Digits,
    this.cardBrand,
    this.expiryMonth,
    this.expiryYear,
    this.holderName,
    this.email,
    this.isDefault = false,
    this.isVerified = false,
    required this.createdAt,
    this.lastUsed,
    this.metadata,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      PaymentMethodModel(
        id: json['id'],
        userId: json['userId'],
        type: PaymentMethodType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'],
          orElse: () => PaymentMethodType.creditCard,
        ),
        displayName: json['displayName'],
        last4Digits: json['last4Digits'],
        cardBrand: json['cardBrand'] != null
            ? CardBrand.values.firstWhere(
                (e) => e.toString().split('.').last == json['cardBrand'],
                orElse: () => CardBrand.unknown,
              )
            : null,
        expiryMonth: json['expiryMonth'],
        expiryYear: json['expiryYear'],
        holderName: json['holderName'],
        email: json['email'],
        isDefault: json['isDefault'] ?? false,
        isVerified: json['isVerified'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        lastUsed:
            json['lastUsed'] != null ? DateTime.parse(json['lastUsed']) : null,
        metadata: json['metadata'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type.toString().split('.').last,
        'displayName': displayName,
        'last4Digits': last4Digits,
        'cardBrand': cardBrand?.toString().split('.').last,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'holderName': holderName,
        'email': email,
        'isDefault': isDefault,
        'isVerified': isVerified,
        'createdAt': createdAt.toIso8601String(),
        'lastUsed': lastUsed?.toIso8601String(),
        'metadata': metadata,
      };

  PaymentMethodModel copyWith({
    String? id,
    String? userId,
    PaymentMethodType? type,
    String? displayName,
    String? last4Digits,
    CardBrand? cardBrand,
    String? expiryMonth,
    String? expiryYear,
    String? holderName,
    String? email,
    bool? isDefault,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastUsed,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      last4Digits: last4Digits ?? this.last4Digits,
      cardBrand: cardBrand ?? this.cardBrand,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      holderName: holderName ?? this.holderName,
      email: email ?? this.email,
      isDefault: isDefault ?? this.isDefault,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      metadata: metadata ?? this.metadata,
    );
  }

  String get maskedNumber {
    if (last4Digits != null) {
      return '**** **** **** $last4Digits';
    }
    return displayName;
  }

  String get typeDisplayName {
    switch (type) {
      case PaymentMethodType.creditCard:
        return 'Credit Card';
      case PaymentMethodType.debitCard:
        return 'Debit Card';
      case PaymentMethodType.paypal:
        return 'PayPal';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
      case PaymentMethodType.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethodType.cryptocurrency:
        return 'Cryptocurrency';
      case PaymentMethodType.mpesa:
        return 'M-Pesa';
    }
  }

  String get brandDisplayName {
    if (cardBrand == null) return '';
    switch (cardBrand!) {
      case CardBrand.visa:
        return 'Visa';
      case CardBrand.mastercard:
        return 'Mastercard';
      case CardBrand.americanExpress:
        return 'American Express';
      case CardBrand.discover:
        return 'Discover';
      case CardBrand.jcb:
        return 'JCB';
      case CardBrand.dinersClub:
        return 'Diners Club';
      case CardBrand.unionPay:
        return 'UnionPay';
      case CardBrand.unknown:
        return 'Unknown';
    }
  }

  bool get isExpired {
    if (expiryMonth == null || expiryYear == null) return false;
    final now = DateTime.now();
    final expiry = DateTime(
      int.parse('20$expiryYear'),
      int.parse(expiryMonth!),
    );
    return now.isAfter(expiry);
  }

  bool get isExpiringSoon {
    if (expiryMonth == null || expiryYear == null) return false;
    final now = DateTime.now();
    final expiry = DateTime(
      int.parse('20$expiryYear'),
      int.parse(expiryMonth!),
    );
    final threeMonthsFromNow = now.add(const Duration(days: 90));
    return expiry.isBefore(threeMonthsFromNow) && !isExpired;
  }
}

class AddPaymentMethodRequest {
  final PaymentMethodType type;
  final String? cardNumber;
  final String? expiryMonth;
  final String? expiryYear;
  final String? cvv;
  final String? holderName;
  final String? email;
  final String? displayName;
  final bool setAsDefault;

  AddPaymentMethodRequest({
    required this.type,
    this.cardNumber,
    this.expiryMonth,
    this.expiryYear,
    this.cvv,
    this.holderName,
    this.email,
    this.displayName,
    this.setAsDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'type': type.toString().split('.').last,
        'cardNumber': cardNumber,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'cvv': cvv,
        'holderName': holderName,
        'email': email,
        'displayName': displayName,
        'setAsDefault': setAsDefault,
      };
}
