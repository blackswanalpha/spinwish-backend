import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spinwishapp/models/payment.dart';
import 'package:spinwishapp/services/payment_service.dart';

import 'package:spinwishapp/screens/payment/payment_success_screen.dart';
import 'package:spinwishapp/screens/payment/mpesa_payment_screen.dart';
import 'package:spinwishapp/screens/payment/payme_payment_screen.dart';

class PaymentScreen extends StatefulWidget {
  final PaymentType type;
  final double amount;
  final String description;
  final Map<String, dynamic>? metadata;

  const PaymentScreen({
    super.key,
    required this.type,
    required this.amount,
    required this.description,
    this.metadata,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod? selectedPaymentMethod;
  List<PaymentMethod> availablePaymentMethods = [];
  bool isLoading = false;
  bool isLoadingMethods = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => isLoadingMethods = true);

    try {
      final methods = await PaymentService.getAvailablePaymentMethods();
      setState(() {
        availablePaymentMethods = methods;
        selectedPaymentMethod = methods.isNotEmpty ? methods.first : null;
        isLoadingMethods = false;
      });
    } catch (e) {
      setState(() => isLoadingMethods = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load payment methods'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processPayment() async {
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Handle M-Pesa separately
    if (selectedPaymentMethod == PaymentMethod.mpesa) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MpesaPaymentScreen(
            type: widget.type,
            amount: widget.amount,
            description: widget.description,
            metadata: widget.metadata,
          ),
        ),
      ).then((result) {
        if (result == true && mounted) {
          Navigator.pop(context, true);
        }
      });
      return;
    }

    // Handle PayMe separately
    if (selectedPaymentMethod == PaymentMethod.payme) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymePaymentScreen(
            type: widget.type,
            amount: widget.amount,
            description: widget.description,
            metadata: widget.metadata,
          ),
        ),
      ).then((result) {
        if (result == true && mounted) {
          Navigator.pop(context, true);
        }
      });
      return;
    }

    setState(() => isLoading = true);
    HapticFeedback.lightImpact();

    try {
      Payment payment;

      if (widget.type == PaymentType.songRequest) {
        payment = await PaymentService.processSongRequestPayment(
          userId: 'current_user_id', // TODO: Get from AuthService
          sessionId: widget.metadata?['sessionId'] ?? '',
          songId: widget.metadata?['songId'] ?? '',
          amount: widget.amount,
          method: selectedPaymentMethod!,
          message: widget.metadata?['message'],
        );
      } else if (widget.type == PaymentType.tip) {
        payment = await PaymentService.processTipPayment(
          userId: 'current_user_id', // TODO: Get from AuthService
          djId: widget.metadata?['djId'] ?? '',
          sessionId: widget.metadata?['sessionId'] ?? '',
          amount: widget.amount,
          method: selectedPaymentMethod!,
          message: widget.metadata?['message'],
          isAnonymous: widget.metadata?['isAnonymous'] ?? false,
        );
      } else {
        throw Exception('Unsupported payment type');
      }

      setState(() => isLoading = false);

      if (payment.status == PaymentStatus.completed) {
        HapticFeedback.heavyImpact();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(payment: payment),
            ),
          );
        }
      } else {
        _showPaymentFailedDialog();
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showPaymentFailedDialog();
    }
  }

  void _showPaymentFailedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: const Text(
          'We were unable to process your payment. Please try again or use a different payment method.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final processingFee = PaymentService.calculateProcessingFee(widget.amount);
    final totalAmount = widget.amount + processingFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        elevation: 0,
      ),
      body: isLoadingMethods
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Summary
                  Card(
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
                                widget.type == PaymentType.tip
                                    ? Icons.favorite
                                    : Icons.music_note,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Transaction Summary',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.description,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow(
                            theme,
                            'Amount',
                            'KSH ${widget.amount.toStringAsFixed(2)}',
                          ),
                          _buildSummaryRow(
                            theme,
                            'Processing Fee',
                            'KSH ${processingFee.toStringAsFixed(2)}',
                          ),
                          const Divider(height: 24),
                          _buildSummaryRow(
                            theme,
                            'Total',
                            'KSH ${totalAmount.toStringAsFixed(2)}',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment Method Selection
                  Text(
                    'Payment Method',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...availablePaymentMethods
                      .map((method) => _buildPaymentMethodTile(
                            theme,
                            method,
                            selectedPaymentMethod == method,
                            () =>
                                setState(() => selectedPaymentMethod = method),
                          )),

                  const SizedBox(height: 24),

                  // Security Notice
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your payment information is encrypted and secure',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Total amount display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'KSH ${totalAmount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Pay button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading || selectedPaymentMethod == null
                      ? null
                      : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('Processing...'),
                          ],
                        )
                      : Text(
                          'Pay KSH ${totalAmount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(ThemeData theme, String label, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(
    ThemeData theme,
    PaymentMethod method,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getPaymentMethodIcon(method),
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _getPaymentMethodDisplayName(method),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        return Icons.credit_card;
      case PaymentMethod.paypal:
        return Icons.account_balance_wallet;
      case PaymentMethod.applePay:
        return Icons.phone_iphone;
      case PaymentMethod.googlePay:
        return Icons.android;
      case PaymentMethod.venmo:
      case PaymentMethod.cashApp:
        return Icons.mobile_friendly;
      case PaymentMethod.mpesa:
        return Icons.phone_android;
      case PaymentMethod.payme:
        return Icons.payment;
    }
  }

  String _getPaymentMethodDisplayName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.venmo:
        return 'Venmo';
      case PaymentMethod.cashApp:
        return 'Cash App';
      case PaymentMethod.mpesa:
        return 'M-Pesa';
      case PaymentMethod.payme:
        return 'PayMe';
    }
  }
}
