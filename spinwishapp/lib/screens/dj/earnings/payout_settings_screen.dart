import 'package:flutter/material.dart';

enum PayoutMethod { bankAccount, paypal, stripe, crypto }

class PayoutMethodData {
  final String id;
  final PayoutMethod method;
  final String displayName;
  final String details;
  final bool isDefault;
  final bool isVerified;

  PayoutMethodData({
    required this.id,
    required this.method,
    required this.displayName,
    required this.details,
    required this.isDefault,
    required this.isVerified,
  });
}

class PayoutSettingsScreen extends StatefulWidget {
  const PayoutSettingsScreen({super.key});

  @override
  State<PayoutSettingsScreen> createState() => _PayoutSettingsScreenState();
}

class _PayoutSettingsScreenState extends State<PayoutSettingsScreen> {
  List<PayoutMethodData> _payoutMethods = [];
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

      // TODO: Load payout methods from backend API
      // For now, show empty state to indicate no mock data
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _payoutMethods = []; // No mock data - will show empty state
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

  Widget _buildPayoutMethodCard(ThemeData theme, PayoutMethodData method) {
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
                      method.method,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getMethodIcon(method.method),
                    color: _getMethodColor(method.method),
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
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
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

  Color _getMethodColor(PayoutMethod method) {
    switch (method) {
      case PayoutMethod.bankAccount:
        return Colors.blue;
      case PayoutMethod.paypal:
        return Colors.indigo;
      case PayoutMethod.stripe:
        return Colors.purple;
      case PayoutMethod.crypto:
        return Colors.orange;
    }
  }

  IconData _getMethodIcon(PayoutMethod method) {
    switch (method) {
      case PayoutMethod.bankAccount:
        return Icons.account_balance;
      case PayoutMethod.paypal:
        return Icons.payment;
      case PayoutMethod.stripe:
        return Icons.credit_card;
      case PayoutMethod.crypto:
        return Icons.currency_bitcoin;
    }
  }

  void _handlePayoutMethodAction(String action, PayoutMethodData method) {
    switch (action) {
      case 'set_default':
        setState(() {
          _payoutMethods = _payoutMethods
              .map(
                (m) => PayoutMethodData(
                  id: m.id,
                  method: m.method,
                  displayName: m.displayName,
                  details: m.details,
                  isDefault: m.id == method.id,
                  isVerified: m.isVerified,
                ),
              )
              .toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Default payout method updated')),
        );
        break;
      case 'edit':
        _showEditPayoutMethodDialog(method);
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add payout method feature coming soon'),
                ),
              );
            },
            child: const Text('Add Bank Account'),
          ),
        ],
      ),
    );
  }

  void _showEditPayoutMethodDialog(PayoutMethodData method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Payout Method'),
        content: Text('Edit ${method.displayName}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit feature coming soon')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(PayoutMethodData method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payout Method'),
        content: Text(
          'Are you sure you want to delete ${method.displayName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _payoutMethods.removeWhere((m) => m.id == method.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payout method deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
