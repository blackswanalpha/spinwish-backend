import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spinwishapp/models/payout.dart';
import 'package:spinwishapp/services/payout_api_service.dart';
import 'package:spinwishapp/screens/dj/earnings/payout_settings_screen.dart';

class RequestPayoutDialog extends StatefulWidget {
  final double availableAmount;

  const RequestPayoutDialog({
    super.key,
    required this.availableAmount,
  });

  @override
  State<RequestPayoutDialog> createState() => _RequestPayoutDialogState();
}

class _RequestPayoutDialogState extends State<RequestPayoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  List<PayoutMethodModel> _payoutMethods = [];
  PayoutMethodModel? _selectedMethod;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPayoutMethods();
    // Pre-fill with available amount
    _amountController.text = widget.availableAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
        // Select default method if available
        _selectedMethod = methods.firstWhere(
          (m) => m.isDefault,
          orElse: () => methods.isNotEmpty ? methods.first : throw Exception('No payout methods'),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitPayoutRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payout method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      
      final request = CreatePayoutRequest(
        payoutMethodId: _selectedMethod!.id,
        amount: amount,
      );

      final payoutRequest = await PayoutApiService.createPayoutRequest(request);

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        
        // Show success message with option to process demo payout
        _showSuccessDialog(payoutRequest);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit payout request: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog(PayoutRequestModel payoutRequest) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            const Text('Payout Requested'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your payout request has been submitted successfully.'),
            const SizedBox(height: 16),
            _buildInfoRow('Amount:', 'KES ${payoutRequest.amount.toStringAsFixed(2)}'),
            _buildInfoRow('Processing Fee:', 'KES ${payoutRequest.processingFee?.toStringAsFixed(2) ?? "0.00"}'),
            _buildInfoRow('Net Amount:', 'KES ${payoutRequest.netAmount?.toStringAsFixed(2) ?? "0.00"}'),
            _buildInfoRow('Method:', payoutRequest.payoutMethodDisplayName),
            _buildInfoRow('Status:', payoutRequest.statusDisplayName),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demo Mode: Click "Process Now" to simulate instant payout',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => _processDemoPayout(payoutRequest),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Process Now (Demo)'),
          ),
        ],
      ),
    );
  }

  Future<void> _processDemoPayout(PayoutRequestModel payoutRequest) async {
    try {
      // Show processing indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing payout...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Process the payout
      await PayoutApiService.processPayoutRequest(payoutRequest.id);

      if (mounted) {
        // Close processing dialog
        Navigator.of(context).pop();
        // Close success dialog
        Navigator.of(context).pop();
        
        // Show completion message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payout processed successfully! Check your transaction history.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close processing dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process payout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Request Payout'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              : _errorMessage != null
                  ? _buildErrorState(theme)
                  : _buildForm(theme),
        ),
      ),
      actions: _isLoading || _errorMessage != null
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ]
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPayoutRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Request'),
              ),
            ],
    );
  }

  Widget _buildForm(ThemeData theme) {
    final processingFee = PayoutApiService.calculateProcessingFee(
      double.tryParse(_amountController.text) ?? 0.0,
    );
    final netAmount = PayoutApiService.calculateNetAmount(
      double.tryParse(_amountController.text) ?? 0.0,
    );

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Available balance info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available Balance', style: TextStyle(fontSize: 12)),
                    Text(
                      'KES ${widget.availableAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payout method selection
          if (_payoutMethods.isEmpty)
            Column(
              children: [
                const Text('No payout methods available'),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PayoutSettingsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Payout Method'),
                ),
              ],
            )
          else
            DropdownButtonFormField<PayoutMethodModel>(
              value: _selectedMethod,
              decoration: InputDecoration(
                labelText: 'Payout Method',
                prefixIcon: const Icon(Icons.payment),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _payoutMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Row(
                    children: [
                      Icon(
                        method.methodType == PayoutMethodType.bankAccount
                            ? Icons.account_balance
                            : Icons.phone_android,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(method.displayName),
                      ),
                      if (method.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Default',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a payout method';
                }
                return null;
              },
            ),
          const SizedBox(height: 16),

          // Amount input
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Payout Amount',
              prefixText: 'KES ',
              prefixIcon: const Icon(Icons.money),
              helperText: 'Min: KES ${PayoutApiService.getMinimumPayoutAmount()}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Amount is required';
              }
              final amount = double.tryParse(value);
              if (amount == null) {
                return 'Invalid amount';
              }
              if (amount < PayoutApiService.getMinimumPayoutAmount()) {
                return 'Minimum amount is KES ${PayoutApiService.getMinimumPayoutAmount()}';
              }
              if (amount > widget.availableAmount) {
                return 'Amount exceeds available balance';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {}); // Rebuild to update fee calculation
            },
          ),
          const SizedBox(height: 16),

          // Fee breakdown
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildInfoRow('Processing Fee (2%):', 'KES ${processingFee.toStringAsFixed(2)}'),
                const Divider(),
                _buildInfoRow(
                  'You will receive:',
                  'KES ${netAmount.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Text(
          _errorMessage ?? 'Failed to load payout methods',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _loadPayoutMethods,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}

