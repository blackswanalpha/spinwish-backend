enum SessionType { club, online }

enum SessionStatus { preparing, live, paused, ended }

class DJSession {
  final String id;
  final String djId;
  final String? clubId;
  final SessionType type;
  final SessionStatus status;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final int listenerCount;
  final List<String> requestQueue;
  final double totalEarnings;
  final double totalTips;
  final int totalRequests;
  final int acceptedRequests;
  final int rejectedRequests;
  final String? currentSongId;
  final bool isAcceptingRequests;
  final double minTipAmount;
  final List<String> genres;
  final String? shareableLink;
  final String? imageUrl;
  final String? thumbnailUrl;

  DJSession({
    required this.id,
    required this.djId,
    this.clubId,
    required this.type,
    required this.status,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    required this.listenerCount,
    required this.requestQueue,
    required this.totalEarnings,
    required this.totalTips,
    required this.totalRequests,
    required this.acceptedRequests,
    required this.rejectedRequests,
    this.currentSongId,
    required this.isAcceptingRequests,
    required this.minTipAmount,
    required this.genres,
    this.shareableLink,
    this.imageUrl,
    this.thumbnailUrl,
  });

  factory DJSession.fromJson(Map<String, dynamic> json) => DJSession(
        id: json['id'],
        djId: json['djId'],
        clubId: json['clubId'],
        type: SessionType.values.firstWhere((e) => e.name == json['type']),
        status:
            SessionStatus.values.firstWhere((e) => e.name == json['status']),
        title: json['title'],
        description: json['description'],
        startTime: DateTime.parse(json['startTime']),
        endTime:
            json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        listenerCount: json['listenerCount'],
        requestQueue: List<String>.from(json['requestQueue']),
        totalEarnings: json['totalEarnings'].toDouble(),
        totalTips: json['totalTips'].toDouble(),
        totalRequests: json['totalRequests'],
        acceptedRequests: json['acceptedRequests'],
        rejectedRequests: json['rejectedRequests'],
        currentSongId: json['currentSongId'],
        isAcceptingRequests: json['isAcceptingRequests'],
        minTipAmount: json['minTipAmount'].toDouble(),
        genres: List<String>.from(json['genres']),
        shareableLink: json['shareableLink'],
        imageUrl: json['imageUrl'],
        thumbnailUrl: json['thumbnailUrl'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'djId': djId,
        'clubId': clubId,
        'type': type.name,
        'status': status.name,
        'title': title,
        'description': description,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'listenerCount': listenerCount,
        'requestQueue': requestQueue,
        'totalEarnings': totalEarnings,
        'totalTips': totalTips,
        'totalRequests': totalRequests,
        'acceptedRequests': acceptedRequests,
        'rejectedRequests': rejectedRequests,
        'currentSongId': currentSongId,
        'isAcceptingRequests': isAcceptingRequests,
        'minTipAmount': minTipAmount,
        'genres': genres,
        'shareableLink': shareableLink,
        'imageUrl': imageUrl,
        'thumbnailUrl': thumbnailUrl,
      };

  DJSession copyWith({
    String? id,
    String? djId,
    String? clubId,
    SessionType? type,
    SessionStatus? status,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    int? listenerCount,
    List<String>? requestQueue,
    double? totalEarnings,
    double? totalTips,
    int? totalRequests,
    int? acceptedRequests,
    int? rejectedRequests,
    String? currentSongId,
    bool? isAcceptingRequests,
    double? minTipAmount,
    List<String>? genres,
    String? shareableLink,
  }) {
    return DJSession(
      id: id ?? this.id,
      djId: djId ?? this.djId,
      clubId: clubId ?? this.clubId,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      listenerCount: listenerCount ?? this.listenerCount,
      requestQueue: requestQueue ?? this.requestQueue,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalTips: totalTips ?? this.totalTips,
      totalRequests: totalRequests ?? this.totalRequests,
      acceptedRequests: acceptedRequests ?? this.acceptedRequests,
      rejectedRequests: rejectedRequests ?? this.rejectedRequests,
      currentSongId: currentSongId ?? this.currentSongId,
      isAcceptingRequests: isAcceptingRequests ?? this.isAcceptingRequests,
      minTipAmount: minTipAmount ?? this.minTipAmount,
      genres: genres ?? this.genres,
      shareableLink: shareableLink ?? this.shareableLink,
    );
  }

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  double get acceptanceRate {
    if (totalRequests == 0) return 0.0;
    return acceptedRequests / totalRequests;
  }

  double get averageEarningsPerRequest {
    if (acceptedRequests == 0) return 0.0;
    return totalEarnings / acceptedRequests;
  }
}
