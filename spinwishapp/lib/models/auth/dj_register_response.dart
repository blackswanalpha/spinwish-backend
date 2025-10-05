class DJRegisterResponse {
  final String emailAddress;
  final String username;
  final String djName;
  final String bio;
  final List<String> genres;
  final String? instagramHandle;
  final String? profileImage;
  final double rating;
  final int followers;
  final bool emailVerified;
  final String message;

  DJRegisterResponse({
    required this.emailAddress,
    required this.username,
    required this.djName,
    required this.bio,
    required this.genres,
    this.instagramHandle,
    this.profileImage,
    required this.rating,
    required this.followers,
    required this.emailVerified,
    required this.message,
  });

  factory DJRegisterResponse.fromJson(Map<String, dynamic> json) => DJRegisterResponse(
    emailAddress: json['emailAddress'] ?? '',
    username: json['username'] ?? '',
    djName: json['djName'] ?? '',
    bio: json['bio'] ?? '',
    genres: List<String>.from(json['genres'] ?? []),
    instagramHandle: json['instagramHandle'],
    profileImage: json['profileImage'],
    rating: (json['rating'] ?? 0.0).toDouble(),
    followers: json['followers'] ?? 0,
    emailVerified: json['emailVerified'] ?? false,
    message: json['message'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'emailAddress': emailAddress,
    'username': username,
    'djName': djName,
    'bio': bio,
    'genres': genres,
    'instagramHandle': instagramHandle,
    'profileImage': profileImage,
    'rating': rating,
    'followers': followers,
    'emailVerified': emailVerified,
    'message': message,
  };
}
