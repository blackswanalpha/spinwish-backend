import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'network_config.dart';

class ApiService {
  // Configuration for different environments
  static const String _port = '8080';

  // Network IP address - this should be set to your host machine's IP
  // You can find this by running: ip route get 1.1.1.1 | grep -oP 'src \K\S+'
  static const String _networkIp =
      '192.168.100.72'; // Update this with your machine's IP

  // Try multiple base URLs in order of preference
  static const List<String> _baseUrls = [
    'http://$_networkIp:$_port/api/v1', // Network IP for WiFi access
    'http://localhost:$_port/api/v1', // Default for most platforms
    'http://10.0.2.2:$_port/api/v1', // Android emulator
    'http://127.0.0.1:$_port/api/v1', // Alternative localhost
  ];

  // Get base URL dynamically using NetworkConfig
  static Future<String> getBaseUrl() async {
    return await NetworkConfig.getCurrentBaseUrl();
  }

  // Deprecated: Use getBaseUrl() instead for dynamic configuration
  static String get baseUrl {
    // Prioritize network IP for WiFi access, with fallbacks
    try {
      if (!kIsWeb && Platform.isAndroid) {
        // For Android, try network IP first, then emulator IP
        return _baseUrls[0]; // Network IP
      }
    } catch (e) {
      // Platform detection failed, use network IP as default
    }
    return _baseUrls[0]; // Network IP for WiFi access
  }

  // Method to get all available base URLs for testing connectivity
  static Future<List<String>> getAllBaseUrls() async {
    return await NetworkConfig.getBaseUrls();
  }

  // Method to test connectivity to a specific URL
  static Future<bool> testConnectivity(String baseUrl) async {
    return await NetworkConfig.testConnectivity(baseUrl);
  }

  // Method to find the best working base URL
  static Future<String?> findWorkingBaseUrl() async {
    return await NetworkConfig.findWorkingBaseUrl();
  }

  static const String tokenKey = 'jwt_token';
  static const String refreshTokenKey = 'refresh_token';

  // Get stored JWT token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Store JWT token
  static Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // Store refresh token
  static Future<void> storeRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(refreshTokenKey, refreshToken);
  }

  // Clear stored tokens
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(refreshTokenKey);
  }

  // Get headers with authorization
  static Future<Map<String, String>> getHeaders(
      {bool includeAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Generic POST request with comprehensive error handling
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = false,
    int maxRetries = 3,
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final currentBaseUrl = await getBaseUrl();
        final url = Uri.parse('$currentBaseUrl$endpoint');
        final headers = await getHeaders(includeAuth: includeAuth);

        final response = await http
            .post(
              url,
              headers: headers,
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 30));

        return response;
      } on SocketException {
        if (retryCount == maxRetries - 1) {
          throw ApiException(
              'No internet connection. Please check your network and try again.');
        }
        retryCount++;
        await Future.delayed(Duration(seconds: retryCount * 2));
      } on TimeoutException {
        if (retryCount == maxRetries - 1) {
          throw ApiException(
              'Request timed out. Please check your connection and try again.');
        }
        retryCount++;
        await Future.delayed(Duration(seconds: retryCount * 2));
      } on HttpException catch (e) {
        throw ApiException('Network error: ${e.message}');
      } on HandshakeException {
        throw ApiException(
            'SSL connection error. Please check your internet connection.');
      } on FormatException {
        throw ApiException('Invalid data format. Please try again.');
      } on http.ClientException catch (e) {
        if (e.message.contains('Connection closed') ||
            e.message.contains('Connection refused') ||
            e.message.contains('failed to fetch') ||
            e.message.contains('Network is unreachable')) {
          if (retryCount == maxRetries - 1) {
            final errorBaseUrl = await getBaseUrl();
            throw ApiException(
                'Unable to connect to server at $errorBaseUrl. Please check if the server is running and try again.');
          }
          retryCount++;
          await Future.delayed(Duration(seconds: retryCount * 2));
        } else {
          throw ApiException('Connection error: ${e.message}');
        }
      } catch (e) {
        if (retryCount == maxRetries - 1) {
          // Check for specific "failed to fetch" error
          if (e.toString().toLowerCase().contains('failed to fetch')) {
            final errorBaseUrl = await getBaseUrl();
            throw ApiException(
                'Failed to connect to server at $errorBaseUrl. Please ensure:\n'
                '1. Backend server is running on port 8080\n'
                '2. Network permissions are enabled\n'
                '3. CORS is properly configured');
          }
          throw ApiException('Unexpected error occurred: ${e.toString()}');
        }
        retryCount++;
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }

    throw ApiException('Request failed after $maxRetries attempts');
  }

  // Generic GET request with comprehensive error handling
  static Future<http.Response> get(
    String endpoint, {
    bool includeAuth = true,
    int maxRetries = 3,
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final currentBaseUrl = await getBaseUrl();
        final url = Uri.parse('$currentBaseUrl$endpoint');
        final headers = await getHeaders(includeAuth: includeAuth);

        final response = await http
            .get(
              url,
              headers: headers,
            )
            .timeout(const Duration(seconds: 30));

        return response;
      } on SocketException {
        if (retryCount == maxRetries - 1) {
          throw ApiException(
              'No internet connection. Please check your network and try again.');
        }
        retryCount++;
        await Future.delayed(Duration(seconds: retryCount * 2));
      } on TimeoutException {
        if (retryCount == maxRetries - 1) {
          throw ApiException(
              'Request timed out. Please check your connection and try again.');
        }
        retryCount++;
        await Future.delayed(Duration(seconds: retryCount * 2));
      } on HttpException catch (e) {
        throw ApiException('Network error: ${e.message}');
      } on HandshakeException {
        throw ApiException(
            'SSL connection error. Please check your internet connection.');
      } on FormatException {
        throw ApiException('Invalid data format. Please try again.');
      } on http.ClientException catch (e) {
        if (e.message.contains('Connection closed') ||
            e.message.contains('Connection refused') ||
            e.message.contains('failed to fetch') ||
            e.message.contains('Network is unreachable')) {
          if (retryCount == maxRetries - 1) {
            final errorBaseUrl = await getBaseUrl();
            throw ApiException(
                'Unable to connect to server at $errorBaseUrl. Please check if the server is running and try again.');
          }
          retryCount++;
          await Future.delayed(Duration(seconds: retryCount * 2));
        } else {
          throw ApiException('Connection error: ${e.message}');
        }
      } catch (e) {
        if (retryCount == maxRetries - 1) {
          // Check for specific "failed to fetch" error
          if (e.toString().toLowerCase().contains('failed to fetch')) {
            final errorBaseUrl = await getBaseUrl();
            throw ApiException(
                'Failed to connect to server at $errorBaseUrl. Please ensure:\n'
                '1. Backend server is running on port 8080\n'
                '2. Network permissions are enabled\n'
                '3. CORS is properly configured');
          }
          throw ApiException('Unexpected error occurred: ${e.toString()}');
        }
        retryCount++;
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }

    throw ApiException('Request failed after $maxRetries attempts');
  }

  // Handle API response with enhanced error messages
  static dynamic handleResponse(http.Response response) {
    try {
      switch (response.statusCode) {
        case 200:
        case 201:
          return jsonDecode(response.body);
        case 400:
          // Try to parse error message from response body
          try {
            final errorData = jsonDecode(response.body);
            final message =
                errorData['message'] ?? errorData['error'] ?? 'Bad request';
            throw ApiException(message);
          } catch (e) {
            throw ApiException('Bad request: Invalid data provided');
          }
        case 401:
          try {
            final errorData = jsonDecode(response.body);
            final message = errorData['message'] ?? 'Invalid credentials';
            throw ApiException(message);
          } catch (e) {
            throw ApiException('Unauthorized: Please check your credentials');
          }
        case 403:
          try {
            final errorData = jsonDecode(response.body);
            final message = errorData['message'] ?? 'Access denied';
            throw ApiException(message);
          } catch (e) {
            throw ApiException(
                'Forbidden: You don\'t have permission to access this resource');
          }
        case 404:
          try {
            final errorData = jsonDecode(response.body);
            final message = errorData['message'] ?? 'Resource not found';
            throw ApiException(message);
          } catch (e) {
            throw ApiException(
                'Not found: The requested resource was not found');
          }
        case 409:
          try {
            final errorData = jsonDecode(response.body);
            final message = errorData['message'] ?? 'Conflict occurred';
            throw ApiException(message);
          } catch (e) {
            throw ApiException(
                'Conflict: The request conflicts with existing data');
          }
        case 422:
          try {
            final errorData = jsonDecode(response.body);
            final message = errorData['message'] ?? 'Validation failed';
            throw ApiException(message);
          } catch (e) {
            throw ApiException(
                'Validation error: Please check your input data');
          }
        case 429:
          throw ApiException(
              'Too many requests: Please wait a moment before trying again');
        case 500:
          throw ApiException('Server error: Please try again later');
        case 502:
          throw ApiException('Bad gateway: Server is temporarily unavailable');
        case 503:
          throw ApiException('Service unavailable: Please try again later');
        case 504:
          throw ApiException(
              'Gateway timeout: The server took too long to respond');
        default:
          throw ApiException(
              'Request failed with status ${response.statusCode}: Please try again');
      }
    } on FormatException {
      throw ApiException('Invalid response format from server');
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to process server response: ${e.toString()}');
    }
  }

  // Generic PUT request with comprehensive error handling
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
    int maxRetries = 3,
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final headers = await getHeaders(includeAuth: includeAuth);
        final currentBaseUrl = await getBaseUrl();
        final uri = Uri.parse('$currentBaseUrl$endpoint');

        final response = await http
            .put(
              uri,
              headers: headers,
              body: json.encode(body),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return json.decode(response.body);
        } else {
          throw ApiException('HTTP ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw ApiException('PUT request failed: $e');
        }
        await Future.delayed(Duration(seconds: retryCount));
      }
    }

    throw ApiException('Request failed after $maxRetries attempts');
  }

  // GET request that returns parsed JSON
  static Future<Map<String, dynamic>> getJson(
    String endpoint, {
    bool includeAuth = true,
    int maxRetries = 3,
  }) async {
    final response =
        await get(endpoint, includeAuth: includeAuth, maxRetries: maxRetries);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw ApiException('Invalid JSON response: $e');
      }
    } else {
      throw ApiException('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // POST request that returns parsed JSON
  static Future<Map<String, dynamic>> postJson(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = false,
    int maxRetries = 3,
  }) async {
    final response = await post(endpoint, body,
        includeAuth: includeAuth, maxRetries: maxRetries);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw ApiException('Invalid JSON response: $e');
      }
    } else {
      throw ApiException('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // PUT request that returns parsed JSON
  static Future<Map<String, dynamic>> putJson(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = false,
    int maxRetries = 3,
  }) async {
    // The put method already returns parsed JSON, so we can return it directly
    return await put(endpoint, body,
        includeAuth: includeAuth, maxRetries: maxRetries);
  }

  // Generic DELETE request with comprehensive error handling
  static Future<void> delete(
    String endpoint, {
    bool includeAuth = true,
    int maxRetries = 3,
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final headers = await getHeaders(includeAuth: includeAuth);
        final currentBaseUrl = await getBaseUrl();
        final uri = Uri.parse('$currentBaseUrl$endpoint');

        final response = await http
            .delete(
              uri,
              headers: headers,
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return;
        } else {
          throw ApiException('HTTP ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw ApiException('DELETE request failed: $e');
        }
        await Future.delayed(Duration(seconds: retryCount));
      }
    }

    throw ApiException('Request failed after $maxRetries attempts');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
