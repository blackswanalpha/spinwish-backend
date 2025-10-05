import 'package:flutter/material.dart';
import 'package:spinwishapp/services/mpesa_service.dart';

/// Utility class for handling payment errors and providing user-friendly messages
class PaymentErrorHandler {
  /// Get user-friendly error message from exception
  static String getUserFriendlyMessage(dynamic error) {
    if (error is MpesaException) {
      return error.message;
    }

    // Handle common error patterns
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network connection failed. Please check your internet connection and try again.';
    }

    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (errorString.contains('insufficient funds')) {
      return 'Insufficient funds in your M-Pesa account. Please top up and try again.';
    }

    if (errorString.contains('invalid phone') || errorString.contains('phone number')) {
      return 'Invalid phone number. Please enter a valid Kenyan mobile number.';
    }

    if (errorString.contains('cancelled') || errorString.contains('user cancelled')) {
      return 'Payment was cancelled. Please try again if you want to complete the payment.';
    }

    if (errorString.contains('duplicate')) {
      return 'This payment has already been processed.';
    }

    if (errorString.contains('limit exceeded')) {
      return 'Transaction limit exceeded. Please try with a smaller amount.';
    }

    if (errorString.contains('unauthorized') || errorString.contains('authentication')) {
      return 'Authentication failed. Please log in again and try.';
    }

    // Default message for unknown errors
    return 'Payment failed. Please try again or contact support if the problem persists.';
  }

  /// Show error dialog with appropriate message and actions
  static void showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) {
    final message = getUserFriendlyMessage(error);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Payment Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          if (onCancel != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel();
              },
              child: const Text('Cancel'),
            ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Try Again'),
            ),
          if (onRetry == null && onCancel == null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
        ],
      ),
    );
  }

  /// Show error snackbar with appropriate message
  static void showErrorSnackBar(
    BuildContext context,
    dynamic error, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final message = getUserFriendlyMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Determine if error is retryable
  static bool isRetryableError(dynamic error) {
    if (error is MpesaException) {
      // Don't retry validation errors
      if (error.message.contains('Invalid') || 
          error.message.contains('required') ||
          error.message.contains('format')) {
        return false;
      }
    }

    final errorString = error.toString().toLowerCase();
    
    // Retryable errors
    if (errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('connection') ||
        errorString.contains('server error') ||
        errorString.contains('service unavailable')) {
      return true;
    }

    // Non-retryable errors
    if (errorString.contains('invalid') ||
        errorString.contains('unauthorized') ||
        errorString.contains('duplicate') ||
        errorString.contains('cancelled')) {
      return false;
    }

    // Default to retryable for unknown errors
    return true;
  }

  /// Get appropriate icon for error type
  static IconData getErrorIcon(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return Icons.wifi_off;
    }

    if (errorString.contains('timeout')) {
      return Icons.access_time;
    }

    if (errorString.contains('insufficient funds')) {
      return Icons.account_balance_wallet;
    }

    if (errorString.contains('phone')) {
      return Icons.phone;
    }

    if (errorString.contains('cancelled')) {
      return Icons.cancel;
    }

    return Icons.error_outline;
  }

  /// Get error color based on severity
  static Color getErrorColor(BuildContext context, dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('cancelled')) {
      return Theme.of(context).colorScheme.secondary;
    }

    if (errorString.contains('network') || errorString.contains('timeout')) {
      return Colors.orange;
    }

    return Theme.of(context).colorScheme.error;
  }
}
