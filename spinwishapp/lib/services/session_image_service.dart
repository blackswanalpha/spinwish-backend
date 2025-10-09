import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:spinwishapp/services/api_service.dart';
import 'package:spinwishapp/models/session.dart';
import 'dart:convert';

class SessionImageService {
  static const String _sessionEndpoint = '/sessions';

  /// Upload an image for a session from XFile (works on all platforms)
  /// Returns the updated Session object with the new image URL
  static Future<Session> uploadSessionImageFromXFile(
      String sessionId, XFile imageFile) async {
    try {
      final baseUrl = await ApiService.getBaseUrl();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$_sessionEndpoint/$sessionId/upload-image'),
      );

      // Add authorization header
      final token = await ApiService.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add the image file - works on all platforms
      if (kIsWeb) {
        // For web, read bytes directly
        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: imageFile.name,
          ),
        );
      } else {
        // For mobile/desktop, use path
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);

          // Debug: Log response to understand structure
          if (kDebugMode) {
            print('Upload response: $jsonResponse');
          }

          // Try to parse the session
          return Session.fromApiResponse(jsonResponse);
        } catch (parseError) {
          if (kDebugMode) {
            print('Parse error: $parseError');
            print('Response body: ${response.body}');
          }
          throw Exception(
              'Failed to parse session response: ${parseError.toString()}');
        }
      } else {
        throw Exception(
            'Failed to upload session image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Upload error: $e');
      }
      throw Exception('Failed to upload session image: ${e.toString()}');
    }
  }

  /// Delete the image for a session
  /// Returns the updated Session object with the image URL removed
  static Future<Session> deleteSessionImage(String sessionId) async {
    try {
      final baseUrl = await ApiService.getBaseUrl();
      final token = await ApiService.getToken();

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(
        Uri.parse('$baseUrl$_sessionEndpoint/$sessionId/image'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Session.fromApiResponse(jsonResponse);
      } else {
        throw Exception(
            'Failed to delete session image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to delete session image: ${e.toString()}');
    }
  }

  /// Get the full image URL for a session
  /// Handles both relative and absolute URLs
  static Future<String?> getSessionImageUrl(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      return null;
    }

    // If it's already a full URL, return it
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // Otherwise, prepend the base URL
    final baseUrl = await ApiService.getBaseUrl();
    return '$baseUrl$imageUrl';
  }

  /// Validate image file before upload (works on all platforms)
  /// Returns true if valid, throws exception if invalid
  static Future<bool> validateImageFile(XFile imageFile) async {
    // Check file size (max 10MB)
    final fileSize = await imageFile.length();
    const maxSize = 10 * 1024 * 1024; // 10MB in bytes
    if (fileSize > maxSize) {
      throw Exception('Image file size exceeds 10MB limit');
    }

    // Check file extension
    final fileName = imageFile.name.toLowerCase();
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final hasValidExtension =
        validExtensions.any((ext) => fileName.endsWith(ext));

    if (!hasValidExtension) {
      throw Exception(
          'Invalid image format. Only JPEG, PNG, GIF, and WebP are allowed');
    }

    return true;
  }
}
