class SessionAnalytics {
  final String sessionId;
  final String title;
  final String status;
  final DateTime startTime;
  final DateTime? endTime;

  // Listener metrics
  final int? activeListeners;
  final int? peakListeners;

  // Request metrics
  final int totalRequests;
  final int pendingRequests;
  final int acceptedRequests;
  final int rejectedRequests;

  // Earnings metrics
  final double totalEarnings;
  final double totalTips;
  final double totalRequestPayments;
  final double averageTipAmount;
  final double averageRequestAmount;

  // Performance metrics
  final double acceptanceRate;
  final int sessionDurationMinutes;
  final double earningsPerHour;
  final double requestsPerHour;

  SessionAnalytics({
    required this.sessionId,
    required this.title,
    required this.status,
    required this.startTime,
    this.endTime,
    this.activeListeners,
    this.peakListeners,
    required this.totalRequests,
    required this.pendingRequests,
    required this.acceptedRequests,
    required this.rejectedRequests,
    required this.totalEarnings,
    required this.totalTips,
    required this.totalRequestPayments,
    required this.averageTipAmount,
    required this.averageRequestAmount,
    required this.acceptanceRate,
    required this.sessionDurationMinutes,
    required this.earningsPerHour,
    required this.requestsPerHour,
  });

  factory SessionAnalytics.fromJson(Map<String, dynamic> json) {
    return SessionAnalytics(
      sessionId: json['sessionId'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      activeListeners: json['activeListeners'] as int?,
      peakListeners: json['peakListeners'] as int?,
      totalRequests: json['totalRequests'] as int? ?? 0,
      pendingRequests: json['pendingRequests'] as int? ?? 0,
      acceptedRequests: json['acceptedRequests'] as int? ?? 0,
      rejectedRequests: json['rejectedRequests'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalTips: (json['totalTips'] as num?)?.toDouble() ?? 0.0,
      totalRequestPayments: (json['totalRequestPayments'] as num?)?.toDouble() ?? 0.0,
      averageTipAmount: (json['averageTipAmount'] as num?)?.toDouble() ?? 0.0,
      averageRequestAmount: (json['averageRequestAmount'] as num?)?.toDouble() ?? 0.0,
      acceptanceRate: (json['acceptanceRate'] as num?)?.toDouble() ?? 0.0,
      sessionDurationMinutes: json['sessionDurationMinutes'] as int? ?? 0,
      earningsPerHour: (json['earningsPerHour'] as num?)?.toDouble() ?? 0.0,
      requestsPerHour: (json['requestsPerHour'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'title': title,
      'status': status,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'activeListeners': activeListeners,
      'peakListeners': peakListeners,
      'totalRequests': totalRequests,
      'pendingRequests': pendingRequests,
      'acceptedRequests': acceptedRequests,
      'rejectedRequests': rejectedRequests,
      'totalEarnings': totalEarnings,
      'totalTips': totalTips,
      'totalRequestPayments': totalRequestPayments,
      'averageTipAmount': averageTipAmount,
      'averageRequestAmount': averageRequestAmount,
      'acceptanceRate': acceptanceRate,
      'sessionDurationMinutes': sessionDurationMinutes,
      'earningsPerHour': earningsPerHour,
      'requestsPerHour': requestsPerHour,
    };
  }

  String get formattedDuration {
    final hours = sessionDurationMinutes ~/ 60;
    final minutes = sessionDurationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get formattedAcceptanceRate {
    return '${acceptanceRate.toStringAsFixed(1)}%';
  }

  String get formattedEarningsPerHour {
    return 'KSH ${earningsPerHour.toStringAsFixed(2)}/hr';
  }

  String get formattedRequestsPerHour {
    return '${requestsPerHour.toStringAsFixed(1)}/hr';
  }
}

