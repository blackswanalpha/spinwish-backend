import 'package:flutter/material.dart';
import 'package:spinwishapp/models/payout.dart';
import 'package:spinwishapp/services/payout_api_service.dart';
import 'package:spinwishapp/screens/dj/earnings/add_bank_account_screen.dart';
import 'package:spinwishapp/screens/dj/earnings/add_mpesa_screen.dart';

class PayoutSettingsScreen extends StatefulWidget {
  const PayoutSettingsScreen({super.key});

  @override
  State<PayoutSettingsScreen> createState() => _PayoutSettingsScreenState();
}

class _PayoutSettingsScreenState extends State<PayoutSettingsScreen> {
  List<PayoutMethodModel> _payoutMethods = [];
  bool _isLoading = true;
  String? _errorMessage;

  double _minimumPayoutAmount = 50.0;
  bool _autoPayoutEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPayoutMethods();
  }

  Future<void> _loadPayoutMethods() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final methods = await PayoutApiService.getPayoutMethods();

      setState(() {
        _payoutMethods = methods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load payout methods: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payout Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPayoutMethodsSection(theme),
            const SizedBox(height: 32),
            _buildPayoutSettingsSection(theme),
            const SizedBox(height: 32),
            _buildAddPayoutMethodButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutMethodsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payout Methods',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_payoutMethods.isEmpty)
          _buildEmptyPayoutMethods(theme)
        else
          ..._payoutMethods.map(
            (method) => _buildPayoutMethodCard(theme, method),
          ),
      ],
    );
  }

  Widget _buildPayoutMethodCard(ThemeData theme, PayoutMethodModel method) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Method icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getMethodColor(
                      method.methodType,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getMethodIcon(method.methodType),
                    color: _getMethodColor(method.methodType),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Method details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              method.displayName,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (method.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Default',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        method.details,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(
                            0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                PopupMenuButton<String>(
                  onSelected: (action) =>
                      _handlePayoutMethodAction(action, method),
                  itemBuilder: (context) => [
                    if (!method.isDefault)
                      const PopupMenuItem(
                        value: 'set_default',
                        child: ListTile(
                          leading: Icon(Icons.star),
                          title: Text('Set as Default'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('Delete'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  method.isVerified ? Icons.verified : Icons.warning,
                  color: method.isVerified ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  method.isVerified ? 'Verified' : 'Verification Required',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: method.isVerified ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPayoutMethods(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No payout methods added',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a payout method to receive your earnings',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutSettingsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payout Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Minimum payout amount
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Minimum Payout Amount',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set the minimum amount before automatic payouts are triggered',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '\$${_minimumPayoutAmount.toStringAsFixed(0)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              Slider(
                value: _minimumPayoutAmount,
                min: 10.0,
                max: 500.0,
                divisions: 49,
                onChanged: (value) {
                  setState(() {
                    _minimumPayoutAmount = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Auto payout toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Automatic Payouts',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Automatically transfer earnings when minimum amount is reached',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _autoPayoutEnabled,
                onChanged: (value) {
                  setState(() {
                    _autoPayoutEnabled = value;
                  });
                },
                activeColor: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddPayoutMethodButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showAddPayoutMethodDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Payout Method'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Color _getMethodColor(PayoutMethodType method) {
    switch (method) {
      case PayoutMethodType.bankAccount:
        return Colors.blue;
      case PayoutMethodType.mpesa:
        return Colors.green;
    }
  }

  IconData _getMethodIcon(PayoutMethodType method) {
    switch (method) {
      case PayoutMethodType.bankAccount:
        return Icons.account_balance;
      case PayoutMethodType.mpesa:
        return Icons.phone_android;
    }
  }

  Future<void> _handlePayoutMethodAction(
      String action, PayoutMethodModel method) async {
    switch (action) {
      case 'set_default':
        try {
          await PayoutApiService.setDefaultPayoutMethod(method.id);
          await _loadPayoutMethods();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${method.displayName} set as default'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to set default: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        break;
      case 'delete':
        _showDeleteConfirmationDialog(method);
        break;
    }
  }

  void _showAddPayoutMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payout Method'),
        content: const Text('Choose a payout method to add:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddBankAccountScreen(),
                ),
              );
              if (result == true) {
                _loadPayoutMethods();
              }
            },
            child: const Text('Add Bank Account'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddMpesaScreen(),
                ),
              );
              if (result == true) {
                _loadPayoutMethods();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Add M-Pesa'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(PayoutMethodModel method) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payout Method'),
        content: Text(
          'Are you sure you want to delete ${method.displayName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await PayoutApiService.deletePayoutMethod(method.id);
        await _loadPayoutMethods();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payout method deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
