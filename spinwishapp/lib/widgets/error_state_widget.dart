import 'package:flutter/material.dart';
import 'package:spinwishapp/utils/error_handler.dart';

enum ErrorType {
  network,
  server,
  authentication,
  validation,
  permission,
  notFound,
  timeout,
  unknown,
}

class ErrorStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final ErrorType errorType;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final Widget? customIcon;
  final List<Widget>? actions;
  final bool showRetryButton;
  final bool showDismissButton;

  const ErrorStateWidget({
    Key? key,
    this.title,
    this.message,
    this.errorType = ErrorType.unknown,
    this.onRetry,
    this.onDismiss,
    this.customIcon,
    this.actions,
    this.showRetryButton = true,
    this.showDismissButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorInfo = _getErrorInfo(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: errorInfo.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: customIcon ??
                  Icon(
                    errorInfo.icon,
                    size: 48,
                    color: errorInfo.color,
                  ),
            ),
            const SizedBox(height: 24),

            // Error Title
            Text(
              title ?? errorInfo.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Error Message
            Text(
              message ?? errorInfo.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Action Buttons
            if (actions != null)
              ...actions!
            else
              _buildDefaultActions(context, errorInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultActions(BuildContext context, _ErrorInfo errorInfo) {
    final buttons = <Widget>[];

    if (showRetryButton && onRetry != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Try Again'),
          style: ElevatedButton.styleFrom(
            backgroundColor: errorInfo.color,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    if (showDismissButton && onDismiss != null) {
      buttons.add(
        TextButton(
          onPressed: onDismiss,
          child: const Text('Dismiss'),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: buttons,
    );
  }

  _ErrorInfo _getErrorInfo(BuildContext context) {
    final theme = Theme.of(context);

    switch (errorType) {
      case ErrorType.network:
        return _ErrorInfo(
          title: 'Connection Problem',
          message: 'Please check your internet connection and try again.',
          icon: Icons.wifi_off,
          color: Colors.orange,
        );

      case ErrorType.server:
        return _ErrorInfo(
          title: 'Server Error',
          message: 'Something went wrong on our end. Please try again later.',
          icon: Icons.error_outline,
          color: Colors.red,
        );

      case ErrorType.authentication:
        return _ErrorInfo(
          title: 'Authentication Required',
          message: 'Please log in to continue.',
          icon: Icons.lock_outline,
          color: Colors.amber,
        );

      case ErrorType.validation:
        return _ErrorInfo(
          title: 'Invalid Input',
          message: 'Please check your input and try again.',
          icon: Icons.warning_outlined,
          color: Colors.orange,
        );

      case ErrorType.permission:
        return _ErrorInfo(
          title: 'Access Denied',
          message: 'You don\'t have permission to perform this action.',
          icon: Icons.block,
          color: Colors.red,
        );

      case ErrorType.notFound:
        return _ErrorInfo(
          title: 'Not Found',
          message: 'The requested resource could not be found.',
          icon: Icons.search_off,
          color: Colors.grey,
        );

      case ErrorType.timeout:
        return _ErrorInfo(
          title: 'Request Timeout',
          message: 'The request took too long. Please try again.',
          icon: Icons.timer_off,
          color: Colors.orange,
        );

      case ErrorType.unknown:
      default:
        return _ErrorInfo(
          title: 'Something Went Wrong',
          message: 'An unexpected error occurred. Please try again.',
          icon: Icons.error_outline,
          color: theme.colorScheme.error,
        );
    }
  }
}

class _ErrorInfo {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  _ErrorInfo({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });
}

class ErrorSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    ErrorType errorType = ErrorType.unknown,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    final theme = Theme.of(context);
    final color = _getErrorColor(errorType, theme);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(errorType),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static Color _getErrorColor(ErrorType errorType, ThemeData theme) {
    switch (errorType) {
      case ErrorType.network:
      case ErrorType.timeout:
        return Colors.orange;
      case ErrorType.server:
      case ErrorType.permission:
        return Colors.red;
      case ErrorType.authentication:
        return Colors.amber.shade700;
      case ErrorType.validation:
        return Colors.orange.shade700;
      case ErrorType.notFound:
        return Colors.grey.shade600;
      case ErrorType.unknown:
      default:
        return theme.colorScheme.error;
    }
  }

  static IconData _getErrorIcon(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.server:
        return Icons.error_outline;
      case ErrorType.authentication:
        return Icons.lock_outline;
      case ErrorType.validation:
        return Icons.warning_outlined;
      case ErrorType.permission:
        return Icons.block;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.timeout:
        return Icons.timer_off;
      case ErrorType.unknown:
      default:
        return Icons.error_outline;
    }
  }
}

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final ErrorType errorType;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    this.errorType = ErrorType.unknown,
    this.onRetry,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = ErrorSnackBar._getErrorColor(errorType, theme);

    return AlertDialog(
      icon: Icon(
        ErrorSnackBar._getErrorIcon(errorType),
        color: color,
        size: 32,
      ),
      title: Text(title),
      content: Text(message),
      actions: [
        if (onDismiss != null)
          TextButton(
            onPressed: onDismiss,
            child: const Text('Dismiss'),
          ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    ErrorType errorType = ErrorType.unknown,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        errorType: errorType,
        onRetry: onRetry,
        onDismiss: onDismiss,
      ),
    );
  }
}
