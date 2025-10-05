class UserResponse {
  final String? id;
  final String emailAddress;
  final String username;
  final String role;
  final DateTime createdAt;
  final bool emailVerified;

  UserResponse({
    this.id,
    required this.emailAddress,
    required this.username,
    required this.role,
    required this.createdAt,
    required this.emailVerified,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        id: json['id']?.toString(),
        emailAddress: json['emailAddress'],
        username: json['username'],
        role: json['role'],
        createdAt: DateTime.parse(json['createdAt']),
        emailVerified: json['emailVerified'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'emailAddress': emailAddress,
        'username': username,
        'role': role,
        'createdAt': createdAt.toIso8601String(),
        'emailVerified': emailVerified,
      };
}
