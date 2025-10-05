class DJUser {
  final String id;
  final String name;
  final String email;
  final String djName;
  final String bio;
  final String profileImage;
  final List<String> genres;
  final double rating;
  final int followers;
  final int totalSessions;
  final double totalEarnings;
  final bool isLive;
  final String? currentSessionId;
  final DateTime createdAt;
  final DateTime lastActive;

  DJUser({
    required this.id,
    required this.name,
    required this.email,
    required this.djName,
    required this.bio,
    required this.profileImage,
    required this.genres,
    required this.rating,
    required this.followers,
    required this.totalSessions,
    required this.totalEarnings,
    required this.isLive,
    this.currentSessionId,
    required this.createdAt,
    required this.lastActive,
  });

  factory DJUser.fromJson(Map<String, dynamic> json) => DJUser(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    djName: json['djName'],
    bio: json['bio'],
    profileImage: json['profileImage'],
    genres: List<String>.from(json['genres']),
    rating: json['rating'].toDouble(),
    followers: json['followers'],
    totalSessions: json['totalSessions'],
    totalEarnings: json['totalEarnings'].toDouble(),
    isLive: json['isLive'],
    currentSessionId: json['currentSessionId'],
    createdAt: DateTime.parse(json['createdAt']),
    lastActive: DateTime.parse(json['lastActive']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'djName': djName,
    'bio': bio,
    'profileImage': profileImage,
    'genres': genres,
    'rating': rating,
    'followers': followers,
    'totalSessions': totalSessions,
    'totalEarnings': totalEarnings,
    'isLive': isLive,
    'currentSessionId': currentSessionId,
    'createdAt': createdAt.toIso8601String(),
    'lastActive': lastActive.toIso8601String(),
  };

  DJUser copyWith({
    String? id,
    String? name,
    String? email,
    String? djName,
    String? bio,
    String? profileImage,
    List<String>? genres,
    double? rating,
    int? followers,
    int? totalSessions,
    double? totalEarnings,
    bool? isLive,
    String? currentSessionId,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return DJUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      djName: djName ?? this.djName,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      genres: genres ?? this.genres,
      rating: rating ?? this.rating,
      followers: followers ?? this.followers,
      totalSessions: totalSessions ?? this.totalSessions,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      isLive: isLive ?? this.isLive,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
