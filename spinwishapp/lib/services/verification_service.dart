import 'package:spinwishapp/services/api_service.dart';
import 'package:spinwishapp/models/auth/verification_request.dart';
import 'package:spinwishapp/models/auth/verification_response.dart';
import 'package:spinwishapp/services/auth_service.dart';

class VerificationService {
  static Future<SendVerificationResponse> sendVerificationCode(
    String emailAddress,
    String verificationType,
  ) async {
    try {
      final request = SendVerificationRequest(
        emailAddress: emailAddress,
        verificationType: verificationType,
      );

      final response = await ApiService.post(
        '/users/send-verification',
        request.toJson(),
      );

      final responseData = ApiService.handleResponse(response);
      return SendVerificationResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to send verification code: ${e.toString()}');
    }
  }

  static Future<bool> verifyCode(
    String emailAddress,
    String verificationCode,
    String verificationType,
  ) async {
    try {
      final request = VerificationRequest(
        emailAddress: emailAddress,
        verificationCode: verificationCode,
        verificationType: verificationType,
      );

      final response = await ApiService.post(
        '/users/verify',
        request.toJson(),
      );

      final responseData = ApiService.handleResponse(response);
      final verificationResponse = VerificationResponse.fromJson(responseData);

      if (verificationResponse.success) {
        // Store JWT tokens for automatic login
        if (verificationResponse.token != null &&
            verificationResponse.refreshToken != null) {
          await AuthService.storeTokens(
            verificationResponse.token!,
            verificationResponse.refreshToken!,
          );
        }

        // Store user data
        if (verificationResponse.userDetails != null) {
          await AuthService.storeUserData(verificationResponse.userDetails!);
        }

        return true;
      } else {
        throw Exception(verificationResponse.message);
      }
    } catch (e) {
      throw Exception('Verification failed: ${e.toString()}');
    }
  }

  static Future<bool> resendVerificationCode(
    String emailAddress,
    String verificationType,
  ) async {
    try {
      final response =
          await sendVerificationCode(emailAddress, verificationType);
      return response.success;
    } catch (e) {
      throw Exception('Failed to resend verification code: ${e.toString()}');
    }
  }
}
