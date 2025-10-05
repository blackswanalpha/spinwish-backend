import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:spinwishapp/services/api_service.dart';
import 'package:spinwishapp/models/user.dart';
import 'package:spinwishapp/models/profile_settings.dart';
import 'package:spinwishapp/models/payment_method.dart';
import 'package:spinwishapp/models/feedback.dart';
import 'package:spinwishapp/models/request_history.dart';

class ProfileService {
  static const String _profileEndpoint = '/profile';
  static const String _settingsEndpoint = '/profile/settings';
  static const String _paymentMethodsEndpoint = '/profile/payment-methods';
  static const String _feedbackEndpoint = '/feedback';
  static const String _requestHistoryEndpoint = '/profile/request-history';

  // Profile Management
  static Future<User> getProfile() async {
    try {
      final response = await ApiService.getJson(_profileEndpoint);
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  static Future<User> updateProfile({
    String? name,
    String? email,
    String? profileImage,
    List<String>? favoriteGenres,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (profileImage != null) data['profileImage'] = profileImage;
      if (favoriteGenres != null) data['favoriteGenres'] = favoriteGenres;

      final response = await ApiService.put(_profileEndpoint, data);
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  static Future<String> uploadProfileImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiService.baseUrl}$_profileEndpoint'),
      );

      final token = await ApiService.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Return the imageUrl from the profile response
        return data['imageUrl'] ?? data['profileImage'] ?? '';
      } else {
        String errorMessage = 'Failed to upload image: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          // If we can't parse the error response, use the default message
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format from server');
      }
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Settings Management
  static Future<ProfileSettings> getSettings() async {
    try {
      final response = await ApiService.getJson(_settingsEndpoint);
      return ProfileSettings.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load settings: $e');
    }
  }

  static Future<ProfileSettings> updateSettings(
      ProfileSettings settings) async {
    try {
      final response =
          await ApiService.put(_settingsEndpoint, settings.toJson());
      return ProfileSettings.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }

  // Payment Methods Management
  static Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await ApiService.getJson(_paymentMethodsEndpoint);
      final List<dynamic> data = response['paymentMethods'] ?? [];
      return data.map((json) => PaymentMethodModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load payment methods: $e');
    }
  }

  static Future<PaymentMethodModel> addPaymentMethod(
      AddPaymentMethodRequest request) async {
    try {
      final response =
          await ApiService.postJson(_paymentMethodsEndpoint, request.toJson());
      return PaymentMethodModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add payment method: $e');
    }
  }

  static Future<PaymentMethodModel> updatePaymentMethod(
    String paymentMethodId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await ApiService.put(
        '$_paymentMethodsEndpoint/$paymentMethodId',
        updates,
      );
      return PaymentMethodModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update payment method: $e');
    }
  }

  static Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      await ApiService.delete('$_paymentMethodsEndpoint/$paymentMethodId');
    } catch (e) {
      throw Exception('Failed to delete payment method: $e');
    }
  }

  static Future<PaymentMethodModel> setDefaultPaymentMethod(
      String paymentMethodId) async {
    try {
      final response = await ApiService.put(
        '$_paymentMethodsEndpoint/$paymentMethodId/set-default',
        {},
      );
      return PaymentMethodModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to set default payment method: $e');
    }
  }

  // Feedback Management
  static Future<FeedbackModel> submitFeedback(
      CreateFeedbackRequest request) async {
    try {
      final response =
          await ApiService.postJson(_feedbackEndpoint, request.toJson());
      return FeedbackModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }

  static Future<List<FeedbackModel>> getUserFeedback({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await ApiService.getJson(
        '$_feedbackEndpoint/user?page=$page&limit=$limit',
      );
      final List<dynamic> data = response['feedback'] ?? [];
      return data.map((json) => FeedbackModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load feedback: $e');
    }
  }

  // Request History Management
  static Future<List<RequestHistoryItem>> getRequestHistory({
    int page = 1,
    int limit = 20,
    RequestHistoryFilter? filter,
    String? searchQuery,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      if (filter != null) {
        final filterJson = filter.toJson();
        filterJson.forEach((key, value) {
          if (value != null) {
            queryParams[key] = value.toString();
          }
        });
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await ApiService.getJson(
        '$_requestHistoryEndpoint?$queryString',
      );

      final List<dynamic> data = response['history'] ?? [];
      return data.map((json) => RequestHistoryItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load request history: $e');
    }
  }

  static Future<RequestHistoryItem> getRequestHistoryItem(String itemId) async {
    try {
      final response =
          await ApiService.getJson('$_requestHistoryEndpoint/$itemId');
      return RequestHistoryItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load request history item: $e');
    }
  }

  // Notification Preferences
  static Future<List<NotificationPreference>>
      getNotificationPreferences() async {
    try {
      final response =
          await ApiService.getJson('/profile/notification-preferences');
      final List<dynamic> data = response['preferences'] ?? [];
      return data.map((json) => NotificationPreference.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load notification preferences: $e');
    }
  }

  static Future<NotificationPreference> updateNotificationPreference(
    NotificationPreference preference,
  ) async {
    try {
      final response = await ApiService.put(
        '/profile/notification-preferences/${preference.type.toString().split('.').last}',
        preference.toJson(),
      );
      return NotificationPreference.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update notification preference: $e');
    }
  }

  // Account Management
  static Future<void> deleteAccount() async {
    try {
      await ApiService.delete('/profile/delete-account');
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await ApiService.put('/profile/change-password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // App Information
  static Future<Map<String, dynamic>> getAppInfo() async {
    try {
      final response = await ApiService.getJson('/app/info');
      return response;
    } catch (e) {
      throw Exception('Failed to load app info: $e');
    }
  }
}
