import 'auth/user_response.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String profileImage;
  final double credits;
  final List<String> favoriteDJs;
  final List<String> favoriteGenres;
  final String? role;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.credits,
    required this.favoriteDJs,
    required this.favoriteGenres,
    this.role,
    this.createdAt,
  });

  // Create User from backend UserResponse
  factory User.fromUserResponse(UserResponse userResponse) => User(
        id: userResponse.id?.toString() ??
            userResponse.emailAddress, // Use actual UUID from backend
        name: userResponse.username,
        email: userResponse.emailAddress,
        profileImage: '', // Default empty, will be set from profile
        credits: 0.0, // Default credits
        favoriteDJs: [], // Default empty
        favoriteGenres: [], // Default empty
        role: userResponse.role,
        createdAt: userResponse.createdAt,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        profileImage: json['profileImage'] ?? '',
        credits: (json['credits'] ?? 0.0).toDouble(),
        favoriteDJs: List<String>.from(json['favoriteDJs'] ?? []),
        favoriteGenres: List<String>.from(json['favoriteGenres'] ?? []),
        role: json['role'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'profileImage': profileImage,
        'credits': credits,
        'favoriteDJs': favoriteDJs,
        'favoriteGenres': favoriteGenres,
        'role': role,
        'createdAt': createdAt?.toIso8601String(),
      };
}
