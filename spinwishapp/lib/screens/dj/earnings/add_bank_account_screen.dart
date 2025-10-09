import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spinwishapp/models/payout.dart';
import 'package:spinwishapp/services/payout_api_service.dart';

class AddBankAccountScreen extends StatefulWidget {
  const AddBankAccountScreen({super.key});

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderNameController = TextEditingController();
  final _bankBranchController = TextEditingController();
  final _bankCodeController = TextEditingController();

  bool _setAsDefault = false;
  bool _isLoading = false;

  // Common Kenyan banks
  final List<String> _kenyanBanks = [
    'Equity Bank',
    'KCB Bank',
    'Cooperative Bank',
    'NCBA Bank',
    'Absa Bank Kenya',
    'Standard Chartered Bank',
    'Stanbic Bank',
    'I&M Bank',
    'Diamond Trust Bank',
    'Family Bank',
    'Barclays Bank',
    'Commercial Bank of Africa',
    'Other',
  ];

  @override
  void dispose() {
    _displayNameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderNameController.dispose();
    _bankBranchController.dispose();
    _bankCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveBankAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = AddPayoutMethodRequest(
        methodType: PayoutMethodType.bankAccount,
        displayName: _displayNameController.text.trim(),
        bankName: _bankNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        accountHolderName: _accountHolderNameController.text.trim(),
        bankBranch: _bankBranchController.text.trim(),
        bankCode: _bankCodeController.text.trim(),
        setAsDefault: _setAsDefault,
      );

      await PayoutApiService.addPayoutMethod(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bank account added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add bank account: ${e.toString()}'),
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
          'Add Bank Account',
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
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your bank account details are securely stored and will be used for payouts.',
                        style: theme.textTheme.bodySmall,
                      ),
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
                  hintText: 'e.g., My Main Account',
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

              // Bank Name
              DropdownButtonFormField<String>(
                value: null,
                decoration: InputDecoration(
                  labelText: 'Bank Name *',
                  prefixIcon: const Icon(Icons.account_balance),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _kenyanBanks.map((bank) {
                  return DropdownMenuItem(
                    value: bank,
                    child: Text(bank),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _bankNameController.text = value;
                  }
                },
                validator: (value) {
                  if (_bankNameController.text.trim().isEmpty) {
                    return 'Bank name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Account Number
              TextFormField(
                controller: _accountNumberController,
                decoration: InputDecoration(
                  labelText: 'Account Number *',
                  hintText: 'Enter your account number',
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Account number is required';
                  }
                  if (value.length < 6) {
                    return 'Account number must be at least 6 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Account Holder Name
              TextFormField(
                controller: _accountHolderNameController,
                decoration: InputDecoration(
                  labelText: 'Account Holder Name *',
                  hintText: 'Full name as per bank records',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Account holder name is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Please enter a valid name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Bank Branch (Optional)
              TextFormField(
                controller: _bankBranchController,
                decoration: InputDecoration(
                  labelText: 'Bank Branch (Optional)',
                  hintText: 'e.g., Nairobi Branch',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Bank Code (Optional)
              TextFormField(
                controller: _bankCodeController,
                decoration: InputDecoration(
                  labelText: 'Bank Code (Optional)',
                  hintText: 'e.g., SWIFT/BIC code',
                  prefixIcon: const Icon(Icons.code),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
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
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveBankAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Bank Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
}

