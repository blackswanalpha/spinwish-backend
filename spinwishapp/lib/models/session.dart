enum SessionType { club, online }

enum SessionStatus { preparing, live, ended, paused }

class Session {
  final String id;
  final String djId;
  final String? clubId;
  final SessionType type;
  final SessionStatus status;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final int? listenerCount;
  final List<String> requestQueue;
  final double? totalEarnings;
  final double? totalTips;
  final int? totalRequests;
  final int? acceptedRequests;
  final int? rejectedRequests;
  final bool? isAcceptingRequests;
  final double? minTipAmount;
  final List<String> genres;
  final String? shareableLink;
  final String? imageUrl;
  final String? thumbnailUrl;

  // Legacy fields for backward compatibility
  final String? currentSongId;
  final List<String> upcomingRequests;
  final double avgRequestPrice;

  Session({
    required this.id,
    required this.djId,
    this.clubId,
    required this.type,
    required this.status,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    this.listenerCount,
    this.requestQueue = const [],
    this.totalEarnings,
    this.totalTips,
    this.totalRequests,
    this.acceptedRequests,
    this.rejectedRequests,
    this.isAcceptingRequests,
    this.minTipAmount,
    this.genres = const [],
    this.shareableLink,
    this.imageUrl,
    this.thumbnailUrl,
    // Legacy fields
    this.currentSongId,
    this.upcomingRequests = const [],
    this.avgRequestPrice = 0.0,
  });

  // Legacy constructor for backward compatibility
  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id']?.toString() ?? '',
        djId: json['djId']?.toString() ?? '',
        clubId: json['clubId']?.toString(),
        type: _parseSessionType(json['type']),
        status: _parseSessionStatus(json['status'] ?? json['isActive']),
        title: json['title'] ?? '',
        description: json['description'],
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'])
            : DateTime.now(),
        endTime:
            json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        listenerCount: json['listeners'] ?? json['listenerCount'] ?? 0,
        requestQueue: json['requestQueue'] != null
            ? List<String>.from(json['requestQueue'])
            : [],
        totalEarnings: json['totalEarnings']?.toDouble(),
        totalTips: json['totalTips']?.toDouble(),
        totalRequests: json['totalRequests'],
        acceptedRequests: json['acceptedRequests'],
        rejectedRequests: json['rejectedRequests'],
        isAcceptingRequests: json['isAcceptingRequests'],
        minTipAmount: json['minTipAmount']?.toDouble(),
        genres: json['genres'] != null ? List<String>.from(json['genres']) : [],
        shareableLink: json['shareableLink'],
        imageUrl: json['imageUrl'],
        thumbnailUrl: json['thumbnailUrl'],
        // Legacy fields
        currentSongId: json['currentSongId'],
        upcomingRequests: json['upcomingRequests'] != null
            ? List<String>.from(json['upcomingRequests'])
            : [],
        avgRequestPrice: json['avgRequestPrice']?.toDouble() ?? 0.0,
      );

  // Factory constructor for API response from backend
  factory Session.fromApiResponse(Map<String, dynamic> json) => Session(
        id: json['id']?.toString() ?? '',
        djId: json['djId']?.toString() ?? '',
        clubId: json['clubId']?.toString(),
        type: _parseSessionType(json['type']),
        status: _parseSessionStatus(json['status']),
        title: json['title'] ?? '',
        description: json['description'],
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'])
            : DateTime.now(),
        endTime:
            json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        listenerCount: json['listenerCount'] ?? 0,
        requestQueue: json['requestQueue'] != null
            ? List<String>.from(json['requestQueue'])
            : [],
        totalEarnings: json['totalEarnings']?.toDouble(),
        totalTips: json['totalTips']?.toDouble(),
        totalRequests: json['totalRequests'],
        acceptedRequests: json['acceptedRequests'],
        rejectedRequests: json['rejectedRequests'],
        isAcceptingRequests: json['isAcceptingRequests'],
        minTipAmount: json['minTipAmount']?.toDouble(),
        genres: json['genres'] != null ? List<String>.from(json['genres']) : [],
        shareableLink: json['shareableLink'],
        imageUrl: json['imageUrl'],
        thumbnailUrl: json['thumbnailUrl'],
      );

  static SessionType _parseSessionType(dynamic type) {
    if (type == null) return SessionType.online;
    if (type is String) {
      switch (type.toUpperCase()) {
        case 'CLUB':
          return SessionType.club;
        case 'ONLINE':
          return SessionType.online;
        default:
          return SessionType.online;
      }
    }
    return SessionType.online;
  }

  static SessionStatus _parseSessionStatus(dynamic status) {
    if (status == null) return SessionStatus.preparing;
    if (status is bool) {
      return status ? SessionStatus.live : SessionStatus.ended;
    }
    if (status is String) {
      switch (status.toUpperCase()) {
        case 'PREPARING':
          return SessionStatus.preparing;
        case 'LIVE':
          return SessionStatus.live;
        case 'ENDED':
          return SessionStatus.ended;
        case 'PAUSED':
          return SessionStatus.paused;
        default:
          return SessionStatus.preparing;
      }
    }
    return SessionStatus.preparing;
  }

  // Legacy getters for backward compatibility
  bool get isActive => status == SessionStatus.live;
  int get listeners => listenerCount ?? 0;

  // CopyWith method for updating session instances
  Session copyWith({
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
    bool? isAcceptingRequests,
    double? minTipAmount,
    List<String>? genres,
    String? shareableLink,
    String? imageUrl,
    String? thumbnailUrl,
    String? currentSongId,
    List<String>? upcomingRequests,
    double? avgRequestPrice,
  }) {
    return Session(
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
      isAcceptingRequests: isAcceptingRequests ?? this.isAcceptingRequests,
      minTipAmount: minTipAmount ?? this.minTipAmount,
      genres: genres ?? this.genres,
      shareableLink: shareableLink ?? this.shareableLink,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      currentSongId: currentSongId ?? this.currentSongId,
      upcomingRequests: upcomingRequests ?? this.upcomingRequests,
      avgRequestPrice: avgRequestPrice ?? this.avgRequestPrice,
    );
  }

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
        'isAcceptingRequests': isAcceptingRequests,
        'minTipAmount': minTipAmount,
        'genres': genres,
        'shareableLink': shareableLink,
        'imageUrl': imageUrl,
        'thumbnailUrl': thumbnailUrl,
      };
}
