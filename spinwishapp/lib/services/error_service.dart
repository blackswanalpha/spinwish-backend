import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum ErrorType {
  network,
  authentication,
  validation,
  permission,
  server,
  unknown,
}

enum ErrorSeverity { low, medium, high, critical }

class AppError {
  final String id;
  final ErrorType type;
  final ErrorSeverity severity;
  final String message;
  final String? technicalMessage;
  final String? userMessage;
  final DateTime timestamp;
  final String? stackTrace;
  final Map<String, dynamic>? context;

  AppError({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    this.technicalMessage,
    this.userMessage,
    required this.timestamp,
    this.stackTrace,
    this.context,
  });

  String get displayMessage {
    return userMessage ?? _getDefaultUserMessage();
  }

  String _getDefaultUserMessage() {
    switch (type) {
      case ErrorType.network:
        return 'Network connection error. Please check your internet connection and try again.';
      case ErrorType.authentication:
        return 'Authentication failed. Please log in again.';
      case ErrorType.validation:
        return 'Please check your input and try again.';
      case ErrorType.permission:
        return 'You don\'t have permission to perform this action.';
      case ErrorType.server:
        return 'Server error. Please try again later.';
      case ErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  IconData get icon {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.authentication:
        return Icons.lock;
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.permission:
        return Icons.block;
      case ErrorType.server:
        return Icons.error;
      case ErrorType.unknown:
        return Icons.help_outline;
    }
  }

  Color getColor(ColorScheme colorScheme) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.amber;
      case ErrorSeverity.medium:
        return Colors.orange;
      case ErrorSeverity.high:
        return colorScheme.error;
      case ErrorSeverity.critical:
        return Colors.red.shade700;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'severity': severity.name,
      'message': message,
      'technicalMessage': technicalMessage,
      'userMessage': userMessage,
      'timestamp': timestamp.toIso8601String(),
      'stackTrace': stackTrace,
      'context': context,
    };
  }

  factory AppError.fromException(
    Exception exception, {
    ErrorType? type,
    ErrorSeverity severity = ErrorSeverity.medium,
    String? userMessage,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type ?? ErrorType.unknown,
      severity: severity,
      message: exception.toString(),
      technicalMessage: exception.toString(),
      userMessage: userMessage,
      timestamp: DateTime.now(),
      stackTrace: kDebugMode ? StackTrace.current.toString() : null,
      context: context,
    );
  }
}

class ErrorService extends ChangeNotifier {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  final List<AppError> _errors = [];
  final List<AppError> _criticalErrors = [];

  List<AppError> get errors => List.unmodifiable(_errors);
  List<AppError> get criticalErrors => List.unmodifiable(_criticalErrors);

  bool get hasErrors => _errors.isNotEmpty;
  bool get hasCriticalErrors => _criticalErrors.isNotEmpty;

  void logError(AppError error) {
    _errors.add(error);

    if (error.severity == ErrorSeverity.critical) {
      _criticalErrors.add(error);
    }

    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('ERROR [${error.type.name}]: ${error.message}');
      if (error.stackTrace != null) {
        debugPrint('Stack trace: ${error.stackTrace}');
      }
    }

    notifyListeners();
  }

  void logException(
    Exception exception, {
    ErrorType? type,
    ErrorSeverity severity = ErrorSeverity.medium,
    String? userMessage,
    Map<String, dynamic>? context,
  }) {
    final error = AppError.fromException(
      exception,
      type: type,
      severity: severity,
      userMessage: userMessage,
      context: context,
    );
    logError(error);
  }

  void clearError(String errorId) {
    _errors.removeWhere((error) => error.id == errorId);
    _criticalErrors.removeWhere((error) => error.id == errorId);
    notifyListeners();
  }

  void clearAllErrors() {
    _errors.clear();
    _criticalErrors.clear();
    notifyListeners();
  }

  void clearErrorsByType(ErrorType type) {
    _errors.removeWhere((error) => error.type == type);
    _criticalErrors.removeWhere((error) => error.type == type);
    notifyListeners();
  }

  AppError? getLatestError() {
    if (_errors.isEmpty) return null;
    return _errors.last;
  }

  List<AppError> getErrorsByType(ErrorType type) {
    return _errors.where((error) => error.type == type).toList();
  }

  List<AppError> getErrorsBySeverity(ErrorSeverity severity) {
    return _errors.where((error) => error.severity == severity).toList();
  }

  // Recovery actions
  void retryLastAction() {
    // Implementation depends on the specific action that failed
    // This could be enhanced to store and retry failed actions
  }

  void reportError(AppError error) {
    // In a real app, this would send the error to a crash reporting service
    // like Firebase Crashlytics, Sentry, etc.
    if (kDebugMode) {
      debugPrint('Reporting error: ${error.toJson()}');
    }
  }
}
