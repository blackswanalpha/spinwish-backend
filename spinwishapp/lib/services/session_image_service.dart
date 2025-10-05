import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:spinwishapp/services/api_service.dart';
import 'package:spinwishapp/models/session.dart';
import 'dart:convert';

class SessionImageService {
  static const String _sessionEndpoint = '/api/v1/sessions';

  /// Upload an image for a session
  /// Returns the updated Session object with the new image URL
  static Future<Session> uploadSessionImage(
      String sessionId, File imageFile) async {
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

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);

          // Debug: Print response to understand structure
          print('Upload response: $jsonResponse');

          // Try to parse the session
          return Session.fromApiResponse(jsonResponse);
        } catch (parseError) {
          print('Parse error: $parseError');
          print('Response body: ${response.body}');
          throw Exception(
              'Failed to parse session response: ${parseError.toString()}');
        }
      } else {
        throw Exception(
            'Failed to upload session image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Upload error: $e');
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

  /// Validate image file before upload
  /// Returns true if valid, throws exception if invalid
  static bool validateImageFile(File imageFile) {
    // Check if file exists
    if (!imageFile.existsSync()) {
      throw Exception('Image file does not exist');
    }

    // Check file size (max 10MB)
    final fileSize = imageFile.lengthSync();
    const maxSize = 10 * 1024 * 1024; // 10MB in bytes
    if (fileSize > maxSize) {
      throw Exception('Image file size exceeds 10MB limit');
    }

    // Check file extension
    final fileName = imageFile.path.toLowerCase();
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
