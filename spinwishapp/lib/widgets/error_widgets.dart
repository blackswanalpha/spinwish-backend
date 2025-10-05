import 'package:flutter/material.dart';
import 'package:spinwishapp/services/error_service.dart';

class ErrorBanner extends StatelessWidget {
  final AppError error;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  const ErrorBanner({
    super.key,
    required this.error,
    this.onDismiss,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = error.getColor(theme.colorScheme);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            error.icon,
            color: errorColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error.displayMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      foregroundColor: errorColor,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close),
              iconSize: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
        ],
      ),
    );
  }
}

class ErrorDialog extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;

  const ErrorDialog({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = error.getColor(theme.colorScheme);

    return AlertDialog(
      icon: Icon(
        error.icon,
        color: errorColor,
        size: 48,
      ),
      title: Text(
        _getErrorTitle(),
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        error.displayMessage,
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: const Text('Retry'),
          ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  String _getErrorTitle() {
    switch (error.type) {
      case ErrorType.network:
        return 'Connection Error';
      case ErrorType.authentication:
        return 'Authentication Error';
      case ErrorType.validation:
        return 'Validation Error';
      case ErrorType.permission:
        return 'Permission Denied';
      case ErrorType.server:
        return 'Server Error';
      case ErrorType.unknown:
        return 'Error';
    }
  }
}

class ErrorSnackBar extends SnackBar {
  ErrorSnackBar({
    super.key,
    required AppError error,
    VoidCallback? onRetry,
  }) : super(
          content: Row(
            children: [
              Icon(
                error.icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error.displayMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: error.getColor(
            const ColorScheme.light(), // Default color scheme for snackbar
          ),
          action: onRetry != null
              ? SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: onRetry,
                )
              : null,
          duration: Duration(
            seconds: error.severity == ErrorSeverity.critical ? 10 : 4,
          ),
        );
}

class ErrorListTile extends StatelessWidget {
  final AppError error;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const ErrorListTile({
    super.key,
    required this.error,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = error.getColor(theme.colorScheme);

    return Dismissible(
      key: Key(error.id),
      direction: onDismiss != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: onDismiss != null ? (_) => onDismiss!() : null,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: errorColor.withOpacity(0.1),
          child: Icon(
            error.icon,
            color: errorColor,
            size: 20,
          ),
        ),
        title: Text(
          error.displayMessage,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _formatTimestamp(error.timestamp),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: error.severity == ErrorSeverity.critical
            ? Icon(
                Icons.priority_high,
                color: errorColor,
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class ErrorPage extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;

  const ErrorPage({
    super.key,
    required this.error,
    this.onRetry,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = error.getColor(theme.colorScheme);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        leading: onGoBack != null
            ? IconButton(
                onPressed: onGoBack,
                icon: const Icon(Icons.arrow_back),
              )
            : null,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                error.icon,
                size: 80,
                color: errorColor,
              ),
              const SizedBox(height: 24),
              Text(
                error.displayMessage,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We apologize for the inconvenience. Please try again.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
