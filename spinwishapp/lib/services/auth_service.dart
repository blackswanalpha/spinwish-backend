import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spinwishapp/models/user.dart';
import 'package:spinwishapp/models/auth/login_request.dart';
import 'package:spinwishapp/models/auth/login_response.dart';
import 'package:spinwishapp/models/auth/register_request.dart';
import 'package:spinwishapp/models/auth/register_response.dart';
import 'package:spinwishapp/models/auth/dj_register_response.dart';
import 'package:spinwishapp/models/auth/user_response.dart';

import 'package:spinwishapp/services/api_service.dart';

/// Custom exception for unverified users
class UnverifiedUserException implements Exception {
  final String message;
  final String emailAddress;
  final String username;
  final bool isDJ;

  UnverifiedUserException({
    required this.message,
    required this.emailAddress,
    required this.username,
    this.isDJ = false,
  });

  @override
  String toString() => message;
}

class AuthService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userTypeKey = 'user_type';
  static const String _djDataKey = 'dj_data';

  static Future<bool> login(String email, String password) async {
    try {
      // Validate input
      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw Exception('Email and password are required');
      }

      final loginRequest = LoginRequest(
        emailAddress: email.trim(),
        password: password,
      );

      final response = await ApiService.post(
        '/users/login',
        loginRequest.toJson(),
      );

      final responseData = ApiService.handleResponse(response);
      if (responseData is! Map<String, dynamic>) {
        throw ApiException(
            'Invalid response format: Expected object, got ${responseData.runtimeType}');
      }
      final loginResponse = LoginResponse.fromJson(responseData);

      // Check if user email is verified
      if (!loginResponse.userDetails.emailVerified) {
        throw UnverifiedUserException(
          message: 'Please verify your email address to continue',
          emailAddress: loginResponse.userDetails.emailAddress,
          username: loginResponse.userDetails.username,
          isDJ: loginResponse.userDetails.role.toUpperCase() == 'DJ',
        );
      }

      // Store tokens
      await ApiService.storeToken(loginResponse.token);
      await ApiService.storeRefreshToken(loginResponse.refreshToken);

      // Store user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userKey, loginResponse.userDetails.emailAddress);
      await prefs.setString(
          _userTypeKey, loginResponse.userDetails.role.toLowerCase());

      // Store user details as JSON
      final user = User.fromUserResponse(loginResponse.userDetails);
      await prefs.setString('user_details', jsonEncode(user.toJson()));

      return true;
    } on ApiException catch (e) {
      // Re-throw API exceptions with their specific messages
      throw Exception(e.message);
    } on FormatException catch (e) {
      throw Exception('Invalid response format from server');
    } catch (e) {
      // Handle any other exceptions
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      throw Exception('Login failed: $errorMessage');
    }
  }

  static Future<bool> djLogin(String email, String password) async {
    // DJ login uses the same API endpoint but expects DJ role
    try {
      final loginRequest = LoginRequest(
        emailAddress: email,
        password: password,
      );

      final response = await ApiService.post(
        '/users/login',
        loginRequest.toJson(),
      );

      final responseData = ApiService.handleResponse(response);
      if (responseData is! Map<String, dynamic>) {
        throw ApiException(
            'Invalid response format: Expected object, got ${responseData.runtimeType}');
      }
      final loginResponse = LoginResponse.fromJson(responseData);

      // Verify user has DJ role
      if (loginResponse.userDetails.role.toUpperCase() != 'DJ') {
        throw Exception('User is not registered as a DJ');
      }

      // Check if DJ email is verified
      if (!loginResponse.userDetails.emailVerified) {
        throw UnverifiedUserException(
          message: 'Please verify your email address to continue',
          emailAddress: loginResponse.userDetails.emailAddress,
          username: loginResponse.userDetails.username,
          isDJ: true,
        );
      }

      // Store tokens
      await ApiService.storeToken(loginResponse.token);
      await ApiService.storeRefreshToken(loginResponse.refreshToken);

      // Store user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userKey, loginResponse.userDetails.emailAddress);
      await prefs.setString(_userTypeKey, 'dj');

      // Store user details as JSON
      final user = User.fromUserResponse(loginResponse.userDetails);
      await prefs.setString('user_details', jsonEncode(user.toJson()));

      return true;
    } catch (e) {
      throw Exception('DJ login failed: ${e.toString()}');
    }
  }

  static Future<RegisterResponse> register(
    String name,
    String email,
    String password,
    String confirmPassword, {
    String? phoneNumber,
  }) async {
    try {
      // Validate input
      if (name.trim().isEmpty) {
        throw Exception('Name is required');
      }
      if (email.trim().isEmpty) {
        throw Exception('Email is required');
      }
      if (password.trim().isEmpty) {
        throw Exception('Password is required');
      }
      if (confirmPassword.trim().isEmpty) {
        throw Exception('Password confirmation is required');
      }
      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      final registerRequest = RegisterRequest(
        emailAddress: email.trim(),
        username: name.trim(),
        password: password,
        confirmPassword: confirmPassword,
        phoneNumber: phoneNumber?.trim(),
        roleName: 'CLIENT', // Default role for regular users
      );

      final response = await ApiService.post(
        '/users/signup',
        registerRequest.toJson(),
      );

      final responseData = ApiService.handleResponse(response);
      if (responseData is! Map<String, dynamic>) {
        throw ApiException(
            'Invalid response format: Expected object, got ${responseData.runtimeType}');
      }

      // Return registration response for verification flow
      return RegisterResponse.fromJson(responseData);
    } on ApiException catch (e) {
      // Re-throw API exceptions with their specific messages
      throw Exception(e.message);
    } on FormatException {
      throw Exception('Invalid response format from server');
    } catch (e) {
      // Handle any other exceptions
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      throw Exception('Registration failed: $errorMessage');
    }
  }

  static Future<DJRegisterResponse> djRegister(
    String name,
    String email,
    String password,
    String confirmPassword,
    String djName,
    String bio,
    List<String> genres, {
    String? phoneNumber,
  }) async {
    try {
      final djRegisterRequest = {
        'username': name,
        'emailAddress': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'phoneNumber': phoneNumber,
        'djName': djName,
        'bio': bio,
        'genres': genres,
        'instagramHandle': null, // Can be added later
        'profileImage': null, // Can be added later
      };

      final response = await ApiService.post(
        '/users/dj-signup',
        djRegisterRequest,
      );

      final responseData = ApiService.handleResponse(response);
      if (responseData is! Map<String, dynamic>) {
        throw ApiException(
            'Invalid response format: Expected object, got ${responseData.runtimeType}');
      }

      // Store DJ-specific data locally from the response
      final prefs = await SharedPreferences.getInstance();
      final djData = {
        'name': responseData['username'] ?? name,
        'djName': djName,
        'bio': responseData['bio'] ?? bio,
        'genres': responseData['genres'] ?? genres,
        'rating': responseData['rating'] ?? 0.0,
        'totalEarnings': 0.0,
        'activeSession': false,
        'totalSessions': 0,
        'followers': responseData['followers'] ?? 0,
        'emailVerified': responseData['emailVerified'] ?? false,
        'instagramHandle': responseData['instagramHandle'],
        'profileImage': responseData['profileImage'],
      };
      await prefs.setString(_djDataKey, jsonEncode(djData));

      // Return DJ registration response for verification flow
      return DJRegisterResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('DJ registration failed: ${e.toString()}');
    }
  }

  static Future<void> logout() async {
    // Clear API tokens
    await ApiService.clearTokens();

    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<User?> getCurrentUser({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (!isLoggedIn) {
      return null;
    }

    // If force refresh is requested or no cached data exists, fetch from API
    if (forceRefresh || prefs.getString('user_details') == null) {
      try {
        final userResponse = await fetchCurrentUserFromAPI();
        if (userResponse != null) {
          // Store updated user details
          await prefs.setString(
              'user_details', jsonEncode(userResponse.toJson()));
          return userResponse;
        }
      } catch (e) {
        // If API call fails, fall back to cached data if available
        print('Failed to fetch user from API: $e');
      }
    }

    // Return cached user data
    final userDetailsString = prefs.getString('user_details');
    if (userDetailsString != null) {
      try {
        final userJson = jsonDecode(userDetailsString);
        return User.fromJson(userJson);
      } catch (e) {
        // If parsing fails, clear invalid data and return null
        await logout();
        return null;
      }
    }

    return null;
  }

  /// Fetch current user data from API
  static Future<User?> fetchCurrentUserFromAPI() async {
    try {
      final response = await ApiService.getJson('/users/me', includeAuth: true);

      // Convert API response to User model
      final user = User(
        id: response['id'] ?? response['emailAddress'],
        name: response['username'] ?? '',
        email: response['emailAddress'] ?? '',
        profileImage: response['profileImage'] ?? '',
        credits: (response['credits'] ?? 0.0).toDouble(),
        favoriteDJs: List<String>.from(response['favoriteDJs'] ?? []),
        favoriteGenres: List<String>.from(response['favoriteGenres'] ?? []),
        role: response['role'],
        createdAt: response['createdAt'] != null
            ? DateTime.parse(response['createdAt'])
            : null,
      );

      return user;
    } catch (e) {
      throw Exception('Failed to fetch current user: $e');
    }
  }

  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }

  static Future<bool> isDJ() async {
    final userType = await getUserType();
    return userType == 'dj';
  }

  static Future<Map<String, dynamic>?> getDJData() async {
    final prefs = await SharedPreferences.getInstance();
    final djDataString = prefs.getString(_djDataKey);
    if (djDataString != null) {
      try {
        return jsonDecode(djDataString);
      } catch (e) {
        // If parsing fails, return null
        return null;
      }
    }
    return null;
  }

  // Store JWT tokens (used by verification service)
  static Future<void> storeTokens(String token, String refreshToken) async {
    await ApiService.storeToken(token);
    await ApiService.storeRefreshToken(refreshToken);
  }

  // Store user data (used by verification service)
  static Future<void> storeUserData(dynamic userResponse) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert UserResponse to User model for storage
    final user = User.fromUserResponse(userResponse);

    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userTypeKey, userResponse.role);
  }

  static Future<void> updateDJData(Map<String, dynamic> djData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_djDataKey, jsonEncode(djData));
  }

  /// Update current user profile
  static Future<User?> updateUserProfile(
      Map<String, dynamic> updateData) async {
    try {
      final response =
          await ApiService.putJson('/users/me', updateData, includeAuth: true);

      // Convert API response to User model
      final user = User(
        id: response['id'] ?? response['emailAddress'],
        name: response['username'] ?? '',
        email: response['emailAddress'] ?? '',
        profileImage: response['profileImage'] ?? '',
        credits: (response['credits'] ?? 0.0).toDouble(),
        favoriteDJs: List<String>.from(response['favoriteDJs'] ?? []),
        favoriteGenres: List<String>.from(response['favoriteGenres'] ?? []),
        role: response['role'],
        createdAt: response['createdAt'] != null
            ? DateTime.parse(response['createdAt'])
            : null,
      );

      // Update cached user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_details', jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Refresh user data from server
  static Future<User?> refreshUserData() async {
    return getCurrentUser(forceRefresh: true);
  }

  /// Check if user has valid authentication
  static Future<bool> isAuthenticated() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) return false;

    try {
      // Try to fetch current user to validate token
      final user = await fetchCurrentUserFromAPI();
      return user != null;
    } catch (e) {
      // If API call fails, token might be invalid
      await logout();
      return false;
    }
  }

  /// Get user credits
  static Future<double> getUserCredits() async {
    final user = await getCurrentUser();
    return user?.credits ?? 0.0;
  }

  /// Update user credits locally (should be called after successful payment)
  static Future<void> updateUserCredits(double newCredits) async {
    final user = await getCurrentUser();
    if (user != null) {
      final updatedUser = User(
        id: user.id,
        name: user.name,
        email: user.email,
        profileImage: user.profileImage,
        credits: newCredits,
        favoriteDJs: user.favoriteDJs,
        favoriteGenres: user.favoriteGenres,
        role: user.role,
        createdAt: user.createdAt,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_details', jsonEncode(updatedUser.toJson()));
    }
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Validate input
      if (email.trim().isEmpty) {
        throw Exception('Email address is required');
      }

      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(email.trim())) {
        throw Exception('Please enter a valid email address');
      }

      final requestData = {
        'emailAddress': email.trim(),
      };

      final response = await ApiService.post(
        '/users/forgot-password',
        requestData,
      );

      final responseData = ApiService.handleResponse(response);

      // The API should return a success message
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('message')) {
        // Success - email sent
        return;
      } else {
        throw Exception('Unexpected response from server');
      }
    } on ApiException catch (e) {
      // Re-throw API exceptions with their specific messages
      throw Exception(e.message);
    } catch (e) {
      // Handle any other exceptions
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      throw Exception('Failed to send reset email: $errorMessage');
    }
  }

  /// Check if user exists but is unverified
  /// This can be used to show appropriate messages or redirect to verification
  static Future<Map<String, dynamic>?> checkUserVerificationStatus(
      String email) async {
    try {
      // Validate input
      if (email.trim().isEmpty) {
        throw Exception('Email address is required');
      }

      final requestData = {
        'emailAddress': email.trim(),
      };

      final response = await ApiService.post(
        '/users/check-verification-status',
        requestData,
      );

      final responseData = ApiService.handleResponse(response);

      if (responseData is Map<String, dynamic>) {
        return {
          'exists': responseData['exists'] ?? false,
          'verified': responseData['verified'] ?? false,
          'username': responseData['username'] ?? '',
          'isDJ': responseData['role']?.toString().toUpperCase() == 'DJ',
        };
      }

      return null;
    } catch (e) {
      // If endpoint doesn't exist or fails, return null
      return null;
    }
  }

  /// Resend verification email for existing unverified user
  static Future<void> resendVerificationEmail(String email) async {
    try {
      // Validate input
      if (email.trim().isEmpty) {
        throw Exception('Email address is required');
      }

      final requestData = {
        'emailAddress': email.trim(),
      };

      final response = await ApiService.post(
        '/users/resend-verification',
        requestData,
      );

      final responseData = ApiService.handleResponse(response);

      // The API should return a success message
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('message')) {
        // Success - verification email sent
        return;
      } else {
        throw Exception('Unexpected response from server');
      }
    } on ApiException catch (e) {
      // Re-throw API exceptions with their specific messages
      throw Exception(e.message);
    } catch (e) {
      // Handle any other exceptions
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      throw Exception('Failed to resend verification email: $errorMessage');
    }
  }
}
