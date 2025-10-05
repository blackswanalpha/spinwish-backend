import 'package:flutter/material.dart';
import 'package:spinwishapp/services/error_service.dart';
import 'package:spinwishapp/widgets/error_widgets.dart';

class ErrorHandler {
  static final ErrorService _errorService = ErrorService();

  /// Handle and display errors with appropriate UI feedback
  static void handleError(
    BuildContext context,
    Exception exception, {
    ErrorType? type,
    ErrorSeverity severity = ErrorSeverity.medium,
    String? userMessage,
    Map<String, dynamic>? errorContext,
    VoidCallback? onRetry,
    bool showDialog = false,
    bool showSnackBar = true,
  }) {
    final error = AppError.fromException(
      exception,
      type: type,
      severity: severity,
      userMessage: userMessage,
      context: errorContext,
    );

    _errorService.logError(error);

    if (showDialog) {
      _showErrorDialog(context, error, onRetry);
    } else if (showSnackBar) {
      _showErrorSnackBar(context, error, onRetry);
    }
  }

  /// Handle network errors specifically
  static void handleNetworkError(
    BuildContext context,
    Exception exception, {
    String? userMessage,
    VoidCallback? onRetry,
  }) {
    handleError(
      context,
      exception,
      type: ErrorType.network,
      severity: ErrorSeverity.medium,
      userMessage:
          userMessage ?? 'Please check your internet connection and try again.',
      onRetry: onRetry,
    );
  }

  /// Handle authentication errors
  static void handleAuthError(
    BuildContext context,
    Exception exception, {
    String? userMessage,
    VoidCallback? onRetry,
  }) {
    handleError(
      context,
      exception,
      type: ErrorType.authentication,
      severity: ErrorSeverity.high,
      userMessage: userMessage ?? 'Please log in again to continue.',
      onRetry: onRetry,
      showDialog: true,
      showSnackBar: false,
    );
  }

  /// Handle validation errors
  static void handleValidationError(
    BuildContext context,
    Exception exception, {
    String? userMessage,
    VoidCallback? onRetry,
  }) {
    handleError(
      context,
      exception,
      type: ErrorType.validation,
      severity: ErrorSeverity.low,
      userMessage: userMessage ?? 'Please check your input and try again.',
      onRetry: onRetry,
    );
  }

  /// Handle server errors
  static void handleServerError(
    BuildContext context,
    Exception exception, {
    String? userMessage,
    VoidCallback? onRetry,
  }) {
    handleError(
      context,
      exception,
      type: ErrorType.server,
      severity: ErrorSeverity.high,
      userMessage: userMessage ?? 'Server error. Please try again later.',
      onRetry: onRetry,
    );
  }

  /// Handle permission errors
  static void handlePermissionError(
    BuildContext context,
    Exception exception, {
    String? userMessage,
    VoidCallback? onRetry,
  }) {
    handleError(
      context,
      exception,
      type: ErrorType.permission,
      severity: ErrorSeverity.medium,
      userMessage:
          userMessage ?? 'You don\'t have permission to perform this action.',
      onRetry: onRetry,
      showDialog: true,
      showSnackBar: false,
    );
  }

  /// Show error dialog
  static void _showErrorDialog(
    BuildContext context,
    AppError error,
    VoidCallback? onRetry,
  ) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(error: error, onRetry: onRetry),
    );
  }

  /// Show error snackbar
  static void _showErrorSnackBar(
    BuildContext context,
    AppError error,
    VoidCallback? onRetry,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(ErrorSnackBar(error: error, onRetry: onRetry));
  }

  /// Execute a function with error handling
  static Future<T?> executeWithErrorHandling<T>(
    BuildContext context,
    Future<T> Function() function, {
    String? errorMessage,
    VoidCallback? onRetry,
    bool showDialog = false,
    bool showSnackBar = true,
  }) async {
    try {
      return await function();
    } catch (e) {
      if (e is Exception) {
        handleError(
          context,
          e,
          userMessage: errorMessage,
          onRetry: onRetry,
          showDialog: showDialog,
          showSnackBar: showSnackBar,
        );
      } else {
        handleError(
          context,
          Exception(e.toString()),
          userMessage: errorMessage,
          onRetry: onRetry,
          showDialog: showDialog,
          showSnackBar: showSnackBar,
        );
      }
      return null;
    }
  }

  /// Execute a function with network error handling
  static Future<T?> executeWithNetworkErrorHandling<T>(
    BuildContext context,
    Future<T> Function() function, {
    String? errorMessage,
    VoidCallback? onRetry,
  }) async {
    try {
      return await function();
    } catch (e) {
      handleNetworkError(
        context,
        e is Exception ? e : Exception(e.toString()),
        userMessage: errorMessage,
        onRetry: onRetry,
      );
      return null;
    }
  }

  /// Get error service instance
  static ErrorService get errorService => _errorService;

  /// Clear all errors
  static void clearAllErrors() {
    _errorService.clearAllErrors();
  }

  /// Clear specific error
  static void clearError(String errorId) {
    _errorService.clearError(errorId);
  }

  /// Get latest error
  static AppError? getLatestError() {
    return _errorService.getLatestError();
  }

  /// Check if there are any errors
  static bool hasErrors() {
    return _errorService.hasErrors;
  }

  /// Check if there are critical errors
  static bool hasCriticalErrors() {
    return _errorService.hasCriticalErrors;
  }
}
