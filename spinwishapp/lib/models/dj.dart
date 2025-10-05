class DJ {
  final String id;
  final String name;
  final String bio;
  final String profileImage;
  final String clubId;
  final bool isLive;
  final int followers;
  final List<String> genres;
  final double rating;
  final String instagramHandle;

  DJ({
    required this.id,
    required this.name,
    required this.bio,
    required this.profileImage,
    required this.clubId,
    required this.isLive,
    required this.followers,
    required this.genres,
    required this.rating,
    required this.instagramHandle,
  });

  factory DJ.fromJson(Map<String, dynamic> json) => DJ(
        id: json['id'],
        name: json['name'],
        bio: json['bio'],
        profileImage: json['profileImage'],
        clubId: json['clubId'],
        isLive: json['isLive'],
        followers: json['followers'],
        genres: List<String>.from(json['genres']),
        rating: json['rating'].toDouble(),
        instagramHandle: json['instagramHandle'],
      );

  // Factory constructor for API response from backend
  factory DJ.fromApiResponse(Map<String, dynamic> json) => DJ(
        id: json['id']?.toString() ?? '',
        name: json['actualUsername'] ?? json['username'] ?? '',
        bio: json['bio'] ?? '',
        profileImage: json['profileImage'] ?? '',
        clubId:
            '', // This might need to be handled differently based on backend structure
        isLive: json['isLive'] ?? false,
        followers: json['followers'] ?? 0,
        genres: json['genres'] != null ? List<String>.from(json['genres']) : [],
        rating: (json['rating'] ?? 0.0).toDouble(),
        instagramHandle: json['instagramHandle'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bio': bio,
        'profileImage': profileImage,
        'clubId': clubId,
        'isLive': isLive,
        'followers': followers,
        'genres': genres,
        'rating': rating,
        'instagramHandle': instagramHandle,
      };
}
