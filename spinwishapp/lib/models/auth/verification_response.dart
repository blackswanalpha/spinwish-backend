import 'user_response.dart';

class VerificationResponse {
  final bool success;
  final String message;
  final UserResponse? userDetails;
  final String? token;
  final String? refreshToken;

  VerificationResponse({
    required this.success,
    required this.message,
    this.userDetails,
    this.token,
    this.refreshToken,
  });

  factory VerificationResponse.fromJson(Map<String, dynamic> json) =>
      VerificationResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        userDetails: json['userDetails'] != null
            ? UserResponse.fromJson(json['userDetails'])
            : null,
        token: json['token'],
        refreshToken: json['refreshToken'],
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        if (userDetails != null) 'userDetails': userDetails!.toJson(),
        if (token != null) 'token': token,
        if (refreshToken != null) 'refreshToken': refreshToken,
      };
}

class SendVerificationResponse {
  final bool success;
  final String message;
  final String? verificationType;
  final String? destination; // masked email or phone

  SendVerificationResponse({
    required this.success,
    required this.message,
    this.verificationType,
    this.destination,
  });

  factory SendVerificationResponse.fromJson(Map<String, dynamic> json) =>
      SendVerificationResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        verificationType: json['verificationType'],
        destination: json['destination'],
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        if (verificationType != null) 'verificationType': verificationType,
        if (destination != null) 'destination': destination,
      };
}
