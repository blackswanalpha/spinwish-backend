import 'package:flutter/material.dart';
import 'package:spinwishapp/models/payment_method.dart';
import 'package:spinwishapp/services/profile_service.dart';
import 'package:spinwishapp/screens/profile/add_payment_method_screen.dart';
import 'package:spinwishapp/widgets/animated_button.dart';
import 'package:spinwishapp/theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<PaymentMethodModel> _paymentMethods = [];
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final methods = await ProfileService.getPaymentMethods();
      if (mounted) {
        setState(() {
          _paymentMethods = methods;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show more user-friendly error messages
        String errorMessage = 'Failed to load payment methods';
        if (e.toString().contains('not yet implemented') ||
            e.toString().contains('NOT_IMPLEMENTED')) {
          errorMessage = 'Payment methods feature is coming soon!';
        } else if (e.toString().contains('network') ||
            e.toString().contains('connection')) {
          errorMessage = 'Please check your internet connection and try again';
        } else if (e.toString().contains('server')) {
          errorMessage = 'Server error. Please try again later';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadPaymentMethods,
            ),
          ),
        );
      }
    }
  }

  Future<void> _setDefaultPaymentMethod(PaymentMethodModel method) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await ProfileService.setDefaultPaymentMethod(method.id);
      await _loadPaymentMethods(); // Reload to get updated data

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${method.displayName} set as default'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set default payment method: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _deletePaymentMethod(PaymentMethodModel method) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete ${method.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isUpdating = true;
      });

      try {
        await ProfileService.deletePaymentMethod(method.id);
        await _loadPaymentMethods(); // Reload to get updated data

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${method.displayName} deleted'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete payment method: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUpdating = false;
          });
        }
      }
    }
  }

  Future<void> _addPaymentMethod() async {
    final result = await Navigator.push<PaymentMethodModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPaymentMethodScreen(),
      ),
    );

    if (result != null) {
      await _loadPaymentMethods();
    }
  }

  Widget _buildPaymentMethodCard(PaymentMethodModel method) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: method.isDefault
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getPaymentMethodColor(method.type),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getPaymentMethodIcon(method.type),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                method.displayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (method.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Default',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              method.maskedNumber,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (method.isExpired)
              Text(
                'Expired',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              )
            else if (method.isExpiringSoon)
              Text(
                'Expires soon',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SpinWishColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'default':
                if (!method.isDefault) {
                  _setDefaultPaymentMethod(method);
                }
                break;
              case 'delete':
                _deletePaymentMethod(method);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!method.isDefault)
              const PopupMenuItem(
                value: 'default',
                child: Row(
                  children: [
                    Icon(Icons.star_outline),
                    SizedBox(width: 8),
                    Text('Set as Default'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        return Icons.credit_card;
      case PaymentMethodType.paypal:
        return Icons.account_balance_wallet;
      case PaymentMethodType.applePay:
        return Icons.phone_iphone;
      case PaymentMethodType.googlePay:
        return Icons.android;
      case PaymentMethodType.bankTransfer:
        return Icons.account_balance;
      case PaymentMethodType.cryptocurrency:
        return Icons.currency_bitcoin;
      case PaymentMethodType.mpesa:
        return Icons.phone_android;
    }
  }

  Color _getPaymentMethodColor(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        return Colors.blue;
      case PaymentMethodType.paypal:
        return Colors.indigo;
      case PaymentMethodType.applePay:
        return Colors.black;
      case PaymentMethodType.googlePay:
        return Colors.green;
      case PaymentMethodType.bankTransfer:
        return Colors.purple;
      case PaymentMethodType.cryptocurrency:
        return Colors.orange;
      case PaymentMethodType.mpesa:
        return Colors.green.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Methods',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _paymentMethods.isEmpty
                      ? _buildEmptyState()
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            ..._paymentMethods.map(_buildPaymentMethodCard),
                            const SizedBox(height: 80), // Space for FAB
                          ],
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "payment_methods_fab",
        onPressed: _isUpdating ? null : _addPaymentMethod,
        icon: const Icon(Icons.add),
        label: const Text('Add Payment Method'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.payment,
                size: 60,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Payment Methods',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a payment method to make song requests and send tips to DJs. Your payment information is securely encrypted and stored.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.security,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Secure & Encrypted',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All payment data is encrypted and PCI compliant',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: AnimatedButton(
                text: 'Add Payment Method',
                onPressed: _addPaymentMethod,
                icon: Icons.add,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
