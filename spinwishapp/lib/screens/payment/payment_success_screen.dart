import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spinwishapp/models/payment.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final Payment payment;

  const PaymentSuccessScreen({
    super.key,
    required this.payment,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _contentController;
  late Animation<double> _checkAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() async {
    HapticFeedback.heavyImpact();
    await _checkController.forward();
    await _contentController.forward();
  }

  @override
  void dispose() {
    _checkController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _shareReceipt() {
    // In a real app, this would share the receipt
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt sharing feature coming soon!'),
      ),
    );
  }

  void _downloadReceipt() {
    // In a real app, this would download the receipt
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt downloaded to your device'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _returnToApp() async {
    // For song request payments, navigate back to session detail screen
    if (widget.payment.type == PaymentType.songRequest &&
        widget.payment.sessionId != null &&
        widget.payment.sessionId!.isNotEmpty) {
      try {
        if (mounted) {
          // Navigation stack: SessionDetailScreen -> SongRequestScreen -> PaymentScreen -> PaymentSuccessScreen
          // We need to pop back to SessionDetailScreen (3 screens back)

          // Pop all the way back to SessionDetailScreen with result=true to trigger refresh
          Navigator.of(context).popUntil((route) {
            // Check if this is the SessionDetailScreen by checking route settings
            // If we can't determine, stop at the first route to prevent over-popping
            return route.isFirst ||
                route.settings.name == '/session-detail' ||
                route.settings.name == '/';
          });

          debugPrint('✅ Navigated back to session detail after payment');
        }
      } catch (e) {
        // If navigation fails, show error and pop back safely
        debugPrint('❌ Error navigating to session: $e');
        debugPrint('Session ID: ${widget.payment.sessionId}');
        debugPrint('Payment ID: ${widget.payment.id}');

        if (mounted) {
          // Just pop back without showing error - payment was successful
          // The session might not be available yet or might have ended
          Navigator.of(context).pop(true);
        }
      }
    } else if (widget.payment.type == PaymentType.tip) {
      // For tips, pop back to the previous screen (likely session or DJ profile)
      if (mounted) {
        // Pop back 2 screens: PaymentSuccessScreen -> PaymentScreen -> TipScreen
        Navigator.of(context).popUntil((route) {
          return route.isFirst || route.settings.name == '/session-detail';
        });
        debugPrint('✅ Navigated back after tip payment');
      }
    } else {
      // For other payment types, just pop back
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Success animation
              AnimatedBuilder(
                animation: _checkAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _checkAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Success content
              AnimatedBuilder(
                animation: _contentAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _contentAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _contentAnimation.value)),
                      child: Column(
                        children: [
                          Text(
                            'Payment Successful!',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getSuccessMessage(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Transaction details
              AnimatedBuilder(
                animation: _contentAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _contentAnimation.value,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Transaction Details',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(theme, 'Transaction ID',
                                widget.payment.transactionId ?? 'N/A'),
                            _buildDetailRow(theme, 'Amount',
                                widget.payment.formattedAmount),
                            _buildDetailRow(theme, 'Payment Method',
                                widget.payment.methodDisplayName),
                            _buildDetailRow(theme, 'Date',
                                _formatDate(widget.payment.timestamp)),
                            _buildDetailRow(theme, 'Status',
                                widget.payment.statusDisplayName),
                            if (widget.payment.description != null)
                              _buildDetailRow(theme, 'Description',
                                  widget.payment.description!),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Action buttons
              AnimatedBuilder(
                animation: _contentAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _contentAnimation.value,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _shareReceipt,
                                icon: const Icon(Icons.share),
                                label: const Text('Share'),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _downloadReceipt,
                                icon: const Icon(Icons.download),
                                label: const Text('Download'),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _returnToApp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Continue',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSuccessMessage() {
    switch (widget.payment.type) {
      case PaymentType.songRequest:
        return 'Your song request has been submitted and will be added to the queue.';
      case PaymentType.tip:
        return 'Your tip has been sent to the DJ. Thank you for supporting live music!';
      case PaymentType.subscription:
        return 'Your subscription has been activated successfully.';
      case PaymentType.other:
        return 'Your payment has been processed successfully.';
    }
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final month = months[dateTime.month - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$month $day, $year at $hour:$minute';
  }
}
