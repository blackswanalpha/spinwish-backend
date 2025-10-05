import 'dart:io';
import 'dart:async';

class NetworkUtils {
  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Check if the SpinWish backend server is reachable
  static Future<bool> isServerReachable() async {
    try {
      final result = await InternetAddress.lookup('localhost')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Get user-friendly network error message
  static String getNetworkErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('socketexception') || 
        errorString.contains('no internet connection')) {
      return 'No internet connection. Please check your network and try again.';
    }
    
    if (errorString.contains('timeoutexception') || 
        errorString.contains('timed out')) {
      return 'Connection timed out. Please check your internet connection and try again.';
    }
    
    if (errorString.contains('handshakeexception') || 
        errorString.contains('ssl')) {
      return 'Secure connection failed. Please check your internet connection.';
    }
    
    if (errorString.contains('connection refused') || 
        errorString.contains('connection closed')) {
      return 'Unable to connect to server. Please try again later.';
    }
    
    if (errorString.contains('formatexception') || 
        errorString.contains('invalid data format')) {
      return 'Invalid data received from server. Please try again.';
    }
    
    // Default message for unknown network errors
    return 'Network error occurred. Please check your connection and try again.';
  }

  /// Retry a network operation with exponential backoff
  static Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int retryCount = 0;
    Duration delay = initialDelay;
    
    while (retryCount < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        retryCount++;
        
        if (retryCount >= maxRetries) {
          rethrow;
        }
        
        // Wait before retrying with exponential backoff
        await Future.delayed(delay);
        delay = Duration(milliseconds: (delay.inMilliseconds * 1.5).round());
      }
    }
    
    throw Exception('Operation failed after $maxRetries attempts');
  }
}
