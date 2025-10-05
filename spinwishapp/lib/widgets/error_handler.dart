import 'package:flutter/material.dart';
import 'package:spinwishapp/utils/network_utils.dart';

class ErrorHandler {
  /// Show a user-friendly error dialog
  static void showErrorDialog(
    BuildContext context,
    String title,
    dynamic error, {
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    String message = customMessage ?? _getErrorMessage(error);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[600],
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
              if (_isNetworkError(error)) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Check your internet connection and try again.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show a simple error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    Duration duration = const Duration(seconds: 4),
  }) {
    String message = customMessage ?? _getErrorMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Get user-friendly error message
  static String _getErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';

    String errorString = error.toString();

    // Remove "Exception: " prefix if present
    if (errorString.startsWith('Exception: ')) {
      errorString = errorString.substring(11);
    }

    // Check for network-related errors
    if (_isNetworkError(error)) {
      return NetworkUtils.getNetworkErrorMessage(error);
    }

    // Check for common API errors
    if (errorString.contains('401') ||
        errorString.toLowerCase().contains('unauthorized')) {
      return 'Invalid credentials. Please check your email and password.';
    }

    if (errorString.contains('403') ||
        errorString.toLowerCase().contains('forbidden')) {
      return 'Access denied. You don\'t have permission to perform this action.';
    }

    if (errorString.contains('404') ||
        errorString.toLowerCase().contains('not found')) {
      return 'The requested resource was not found.';
    }

    if (errorString.contains('409') ||
        errorString.toLowerCase().contains('conflict')) {
      return 'This information already exists. Please use different details.';
    }

    if (errorString.contains('422') ||
        errorString.toLowerCase().contains('validation')) {
      return 'Please check your input and try again.';
    }

    if (errorString.contains('429') ||
        errorString.toLowerCase().contains('too many requests')) {
      return 'Too many attempts. Please wait a moment before trying again.';
    }

    if (errorString.contains('500') ||
        errorString.toLowerCase().contains('server error')) {
      return 'Server error. Please try again later.';
    }

    // Return the original message if it's already user-friendly
    if (errorString.length < 100 && !errorString.contains('Exception')) {
      return errorString;
    }

    // Default fallback message
    return 'Something went wrong. Please try again.';
  }

  /// Check if error is network-related
  static bool _isNetworkError(dynamic error) {
    if (error == null) return false;

    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') ||
        errorString.contains('timeoutexception') ||
        errorString.contains('handshakeexception') ||
        errorString.contains('no internet connection') ||
        errorString.contains('connection refused') ||
        errorString.contains('connection closed') ||
        errorString.contains('network error') ||
        errorString.contains('unable to connect');
  }

  /// Handle async operations with automatic error handling
  static Future<T?> handleAsyncOperation<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? loadingMessage,
    String? errorTitle,
    bool showErrorDialog = true,
    bool showErrorSnackBar = false,
    VoidCallback? onError,
  }) async {
    try {
      return await operation();
    } catch (e) {
      if (showErrorDialog) {
        ErrorHandler.showErrorDialog(
          context,
          errorTitle ?? 'Error',
          e,
        );
      } else if (showErrorSnackBar) {
        ErrorHandler.showErrorSnackBar(context, e);
      }

      onError?.call();
      return null;
    }
  }
}
