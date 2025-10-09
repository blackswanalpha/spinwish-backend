enum PayoutMethodType {
  bankAccount,
  mpesa,
}

enum PayoutStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}

class PayoutMethodModel {
  final String id;
  final PayoutMethodType methodType;
  final String displayName;
  
  // Bank Account fields
  final String? bankName;
  final String? maskedAccountNumber;
  final String? accountHolderName;
  final String? bankBranch;
  
  // M-Pesa fields
  final String? maskedPhoneNumber;
  final String? mpesaAccountName;
  
  final bool isDefault;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  PayoutMethodModel({
    required this.id,
    required this.methodType,
    required this.displayName,
    this.bankName,
    this.maskedAccountNumber,
    this.accountHolderName,
    this.bankBranch,
    this.maskedPhoneNumber,
    this.mpesaAccountName,
    required this.isDefault,
    required this.isVerified,
    required this.createdAt,
    this.lastUsedAt,
  });

  factory PayoutMethodModel.fromJson(Map<String, dynamic> json) {
    return PayoutMethodModel(
      id: json['id'],
      methodType: json['methodType'] == 'BANK_ACCOUNT' 
          ? PayoutMethodType.bankAccount 
          : PayoutMethodType.mpesa,
      displayName: json['displayName'],
      bankName: json['bankName'],
      maskedAccountNumber: json['maskedAccountNumber'],
      accountHolderName: json['accountHolderName'],
      bankBranch: json['bankBranch'],
      maskedPhoneNumber: json['maskedPhoneNumber'],
      mpesaAccountName: json['mpesaAccountName'],
      isDefault: json['isDefault'] ?? false,
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastUsedAt: json['lastUsedAt'] != null 
          ? DateTime.parse(json['lastUsedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'methodType': methodType == PayoutMethodType.bankAccount 
          ? 'BANK_ACCOUNT' 
          : 'MPESA',
      'displayName': displayName,
      'bankName': bankName,
      'maskedAccountNumber': maskedAccountNumber,
      'accountHolderName': accountHolderName,
      'bankBranch': bankBranch,
      'maskedPhoneNumber': maskedPhoneNumber,
      'mpesaAccountName': mpesaAccountName,
      'isDefault': isDefault,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
    };
  }

  String get methodTypeDisplayName {
    switch (methodType) {
      case PayoutMethodType.bankAccount:
        return 'Bank Account';
      case PayoutMethodType.mpesa:
        return 'M-Pesa';
    }
  }

  String get details {
    if (methodType == PayoutMethodType.bankAccount) {
      return '$bankName - $maskedAccountNumber';
    } else {
      return 'M-Pesa - $maskedPhoneNumber';
    }
  }
}

class PayoutRequestModel {
  final String id;
  final String payoutMethodId;
  final String payoutMethodType;
  final String payoutMethodDisplayName;
  final double amount;
  final String currency;
  final PayoutStatus status;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final DateTime? completedAt;
  final String? externalTransactionId;
  final String? receiptNumber;
  final String? failureReason;
  final double? processingFee;
  final double? netAmount;

  PayoutRequestModel({
    required this.id,
    required this.payoutMethodId,
    required this.payoutMethodType,
    required this.payoutMethodDisplayName,
    required this.amount,
    required this.currency,
    required this.status,
    required this.requestedAt,
    this.processedAt,
    this.completedAt,
    this.externalTransactionId,
    this.receiptNumber,
    this.failureReason,
    this.processingFee,
    this.netAmount,
  });

  factory PayoutRequestModel.fromJson(Map<String, dynamic> json) {
    return PayoutRequestModel(
      id: json['id'],
      payoutMethodId: json['payoutMethodId'],
      payoutMethodType: json['payoutMethodType'],
      payoutMethodDisplayName: json['payoutMethodDisplayName'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'KES',
      status: _parseStatus(json['status']),
      requestedAt: DateTime.parse(json['requestedAt']),
      processedAt: json['processedAt'] != null 
          ? DateTime.parse(json['processedAt']) 
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      externalTransactionId: json['externalTransactionId'],
      receiptNumber: json['receiptNumber'],
      failureReason: json['failureReason'],
      processingFee: json['processingFee'] != null 
          ? (json['processingFee'] as num).toDouble() 
          : null,
      netAmount: json['netAmount'] != null 
          ? (json['netAmount'] as num).toDouble() 
          : null,
    );
  }

  static PayoutStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return PayoutStatus.pending;
      case 'PROCESSING':
        return PayoutStatus.processing;
      case 'COMPLETED':
        return PayoutStatus.completed;
      case 'FAILED':
        return PayoutStatus.failed;
      case 'CANCELLED':
        return PayoutStatus.cancelled;
      default:
        return PayoutStatus.pending;
    }
  }

  String get statusDisplayName {
    switch (status) {
      case PayoutStatus.pending:
        return 'Pending';
      case PayoutStatus.processing:
        return 'Processing';
      case PayoutStatus.completed:
        return 'Completed';
      case PayoutStatus.failed:
        return 'Failed';
      case PayoutStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class AddPayoutMethodRequest {
  final PayoutMethodType methodType;
  final String displayName;
  
  // Bank Account fields
  final String? bankName;
  final String? accountNumber;
  final String? accountHolderName;
  final String? bankBranch;
  final String? bankCode;
  
  // M-Pesa fields
  final String? mpesaPhoneNumber;
  final String? mpesaAccountName;
  
  final bool setAsDefault;
  final String? notes;

  AddPayoutMethodRequest({
    required this.methodType,
    required this.displayName,
    this.bankName,
    this.accountNumber,
    this.accountHolderName,
    this.bankBranch,
    this.bankCode,
    this.mpesaPhoneNumber,
    this.mpesaAccountName,
    this.setAsDefault = false,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'methodType': methodType == PayoutMethodType.bankAccount 
          ? 'BANK_ACCOUNT' 
          : 'MPESA',
      'displayName': displayName,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'bankBranch': bankBranch,
      'bankCode': bankCode,
      'mpesaPhoneNumber': mpesaPhoneNumber,
      'mpesaAccountName': mpesaAccountName,
      'setAsDefault': setAsDefault,
      'notes': notes,
    };
  }
}

class CreatePayoutRequest {
  final String payoutMethodId;
  final double amount;
  final String? notes;

  CreatePayoutRequest({
    required this.payoutMethodId,
    required this.amount,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'payoutMethodId': payoutMethodId,
      'amount': amount,
      'notes': notes,
    };
  }
}

