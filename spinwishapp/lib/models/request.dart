enum RequestStatus { pending, accepted, rejected, played }

class Request {
  final String id;
  final String userId;
  final String sessionId;
  final String songId;
  final RequestStatus status;
  final double amount;
  final DateTime timestamp;
  final String? message;
  final int? queuePosition;

  Request({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.songId,
    required this.status,
    required this.amount,
    required this.timestamp,
    this.message,
    this.queuePosition,
  });

  factory Request.fromJson(Map<String, dynamic> json) => Request(
    id: json['id'],
    userId: json['userId'],
    sessionId: json['sessionId'],
    songId: json['songId'],
    status: RequestStatus.values[json['status']],
    amount: json['amount'].toDouble(),
    timestamp: DateTime.parse(json['timestamp']),
    message: json['message'],
    queuePosition: json['queuePosition'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'sessionId': sessionId,
    'songId': songId,
    'status': status.index,
    'amount': amount,
    'timestamp': timestamp.toIso8601String(),
    'message': message,
    'queuePosition': queuePosition,
  };
}