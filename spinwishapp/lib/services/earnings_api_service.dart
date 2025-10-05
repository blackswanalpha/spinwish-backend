import 'package:spinwishapp/services/api_service.dart';

class EarningsApiService {
  static const String _baseEndpoint = '/earnings';

  /// Get earnings summary for current DJ
  static Future<EarningsSummary> getCurrentDJEarningsSummary({String period = 'month'}) async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/me/summary?period=$period',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);
      return EarningsSummary.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to fetch earnings summary: ${e.toString()}');
    }
  }

  /// Get earnings summary for specific DJ
  static Future<EarningsSummary> getDJEarningsSummary(String djId, {String period = 'month'}) async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/dj/$djId/summary?period=$period',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);
      return EarningsSummary.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to fetch DJ earnings summary: ${e.toString()}');
    }
  }

  /// Get tip history for current DJ
  static Future<List<TipPayment>> getCurrentDJTipHistory({int page = 0, int size = 20}) async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/me/tips?page=$page&size=$size',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);
      
      if (data is Map && data['content'] is List) {
        return (data['content'] as List)
            .map((item) => TipPayment.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch tip history: ${e.toString()}');
    }
  }

  /// Get request payment history for current DJ
  static Future<List<RequestPayment>> getCurrentDJRequestHistory({int page = 0, int size = 20}) async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/me/requests?page=$page&size=$size',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);
      
      if (data is Map && data['content'] is List) {
        return (data['content'] as List)
            .map((item) => RequestPayment.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch request payment history: ${e.toString()}');
    }
  }
}

/// Earnings summary model
class EarningsSummary {
  final double totalEarnings;
  final double totalTips;
  final double totalRequests;
  final double pendingAmount;
  final double availableForPayout;
  final int totalTransactions;
  final DateTime periodStart;
  final DateTime periodEnd;

  EarningsSummary({
    required this.totalEarnings,
    required this.totalTips,
    required this.totalRequests,
    required this.pendingAmount,
    required this.availableForPayout,
    required this.totalTransactions,
    required this.periodStart,
    required this.periodEnd,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
      totalTips: (json['totalTips'] ?? 0.0).toDouble(),
      totalRequests: (json['totalRequests'] ?? 0.0).toDouble(),
      pendingAmount: (json['pendingAmount'] ?? 0.0).toDouble(),
      availableForPayout: (json['availableForPayout'] ?? 0.0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? 0,
      periodStart: DateTime.parse(json['periodStart']),
      periodEnd: DateTime.parse(json['periodEnd']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEarnings': totalEarnings,
      'totalTips': totalTips,
      'totalRequests': totalRequests,
      'pendingAmount': pendingAmount,
      'availableForPayout': availableForPayout,
      'totalTransactions': totalTransactions,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }
}

/// Tip payment model
class TipPayment {
  final String id;
  final String receiptNumber;
  final String payerName;
  final String phoneNumber;
  final double amount;
  final DateTime transactionDate;
  final String? djId;

  TipPayment({
    required this.id,
    required this.receiptNumber,
    required this.payerName,
    required this.phoneNumber,
    required this.amount,
    required this.transactionDate,
    this.djId,
  });

  factory TipPayment.fromJson(Map<String, dynamic> json) {
    return TipPayment(
      id: json['id'],
      receiptNumber: json['receiptNumber'],
      payerName: json['payerName'],
      phoneNumber: json['phoneNumber'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      transactionDate: DateTime.parse(json['transactionDate']),
      djId: json['dj']?['id'],
    );
  }
}

/// Request payment model
class RequestPayment {
  final String id;
  final String receiptNumber;
  final String payerName;
  final String phoneNumber;
  final double amount;
  final DateTime transactionDate;
  final String? requestId;

  RequestPayment({
    required this.id,
    required this.receiptNumber,
    required this.payerName,
    required this.phoneNumber,
    required this.amount,
    required this.transactionDate,
    this.requestId,
  });

  factory RequestPayment.fromJson(Map<String, dynamic> json) {
    return RequestPayment(
      id: json['id'],
      receiptNumber: json['receiptNumber'],
      payerName: json['payerName'],
      phoneNumber: json['phoneNumber'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      transactionDate: DateTime.parse(json['transactionDate']),
      requestId: json['request']?['id'],
    );
  }
}
