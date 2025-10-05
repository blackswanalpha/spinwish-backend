import 'user_response.dart';

class LoginResponse {
  final UserResponse userDetails;
  final String token;
  final String refreshToken;

  LoginResponse({
    required this.userDetails,
    required this.token,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    userDetails: UserResponse.fromJson(json['userDetails']),
    token: json['token'],
    refreshToken: json['refreshToken'],
  );

  Map<String, dynamic> toJson() => {
    'userDetails': userDetails.toJson(),
    'token': token,
    'refreshToken': refreshToken,
  };
}
