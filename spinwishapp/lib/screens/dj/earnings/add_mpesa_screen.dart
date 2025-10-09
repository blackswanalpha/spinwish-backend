import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spinwishapp/models/payout.dart';
import 'package:spinwishapp/services/payout_api_service.dart';

class AddMpesaScreen extends StatefulWidget {
  const AddMpesaScreen({super.key});

  @override
  State<AddMpesaScreen> createState() => _AddMpesaScreenState();
}

class _AddMpesaScreenState extends State<AddMpesaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _accountNameController = TextEditingController();

  bool _setAsDefault = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Format to 254XXXXXXXXX
    if (cleaned.startsWith('254')) {
      return cleaned;
    } else if (cleaned.startsWith('0')) {
      return '254${cleaned.substring(1)}';
    } else if (cleaned.length == 9) {
      return '254$cleaned';
    }
    return cleaned;
  }

  bool _isValidKenyanPhoneNumber(String phone) {
    String formatted = _formatPhoneNumber(phone);
    // Kenyan numbers: 254 followed by 7 or 1, then 8 more digits
    return RegExp(r'^254[71][0-9]{8}$').hasMatch(formatted);
  }

  Future<void> _saveMpesaAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final formattedPhone = _formatPhoneNumber(_phoneNumberController.text.trim());

      final request = AddPayoutMethodRequest(
        methodType: PayoutMethodType.mpesa,
        displayName: _displayNameController.text.trim(),
        mpesaPhoneNumber: formattedPhone,
        mpesaAccountName: _accountNameController.text.trim(),
        setAsDefault: _setAsDefault,
      );

      await PayoutApiService.addPayoutMethod(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('M-Pesa account added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add M-Pesa account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add M-Pesa Account',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // M-Pesa logo/icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_android,
                    size: 64,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'M-Pesa Payout Information',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Payouts are sent directly to your M-Pesa number\n'
                      '• Ensure your number is registered with M-Pesa\n'
                      '• Processing typically takes 1-3 business days\n'
                      '• You will receive an SMS confirmation',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Display Name
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: 'Display Name *',
                  hintText: 'e.g., My M-Pesa',
                  prefixIcon: const Icon(Icons.label),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Display name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'M-Pesa Phone Number *',
                  hintText: '0712345678 or 254712345678',
                  prefixIcon: const Icon(Icons.phone),
                  helperText: 'Enter your Safaricom M-Pesa number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (!_isValidKenyanPhoneNumber(value)) {
                    return 'Please enter a valid Kenyan mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Account Name
              TextFormField(
                controller: _accountNameController,
                decoration: InputDecoration(
                  labelText: 'Account Name *',
                  hintText: 'Name registered with M-Pesa',
                  prefixIcon: const Icon(Icons.person),
                  helperText: 'Full name as registered with Safaricom',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Account name is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Please enter a valid name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Set as default checkbox
              CheckboxListTile(
                value: _setAsDefault,
                onChanged: (value) {
                  setState(() {
                    _setAsDefault = value ?? false;
                  });
                },
                title: const Text('Set as default payout method'),
                subtitle: const Text(
                  'This will be used for automatic payouts',
                  style: TextStyle(fontSize: 12),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveMpesaAccount,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: const Text(
                    'Save M-Pesa Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Help text
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('M-Pesa Help'),
                        content: const Text(
                          'To receive M-Pesa payouts:\n\n'
                          '1. Ensure your number is registered with Safaricom M-Pesa\n'
                          '2. Your M-Pesa account should be active\n'
                          '3. You will receive payouts as M-Pesa transfers\n'
                          '4. Check your M-Pesa balance after payout\n\n'
                          'For issues, contact Safaricom customer care.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Got it'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.help_outline),
                  label: const Text('Need help with M-Pesa?'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

