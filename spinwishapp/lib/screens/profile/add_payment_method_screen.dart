import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spinwishapp/models/payment_method.dart';
import 'package:spinwishapp/services/profile_service.dart';
import 'package:spinwishapp/widgets/animated_button.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _emailController = TextEditingController();

  PaymentMethodType _selectedType = PaymentMethodType.creditCard;
  bool _isLoading = false;
  bool _setAsDefault = false;
  CardBrand _detectedBrand = CardBrand.unknown;

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_detectCardBrand);
  }

  void _detectCardBrand() {
    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    CardBrand brand = CardBrand.unknown;

    if (cardNumber.startsWith('4')) {
      brand = CardBrand.visa;
    } else if (cardNumber.startsWith(RegExp(r'^5[1-5]')) ||
        cardNumber.startsWith(RegExp(r'^2[2-7]'))) {
      brand = CardBrand.mastercard;
    } else if (cardNumber.startsWith(RegExp(r'^3[47]'))) {
      brand = CardBrand.americanExpress;
    } else if (cardNumber.startsWith('6')) {
      brand = CardBrand.discover;
    }

    if (brand != _detectedBrand) {
      setState(() {
        _detectedBrand = brand;
      });
    }
  }

  String _formatCardNumber(String value) {
    value = value.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += value[i];
    }
    return formatted;
  }

  String _formatExpiry(String value) {
    value = value.replaceAll('/', '');
    if (value.length >= 2) {
      return '${value.substring(0, 2)}/${value.substring(2)}';
    }
    return value;
  }

  Future<void> _addPaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final request = AddPaymentMethodRequest(
        type: _selectedType,
        cardNumber: _selectedType == PaymentMethodType.creditCard ||
                _selectedType == PaymentMethodType.debitCard
            ? _cardNumberController.text.replaceAll(' ', '')
            : null,
        expiryMonth: _selectedType == PaymentMethodType.creditCard ||
                _selectedType == PaymentMethodType.debitCard
            ? _expiryController.text.split('/')[0]
            : null,
        expiryYear: _selectedType == PaymentMethodType.creditCard ||
                _selectedType == PaymentMethodType.debitCard
            ? _expiryController.text.split('/')[1]
            : null,
        cvv: _selectedType == PaymentMethodType.creditCard ||
                _selectedType == PaymentMethodType.debitCard
            ? _cvvController.text
            : null,
        holderName: _selectedType == PaymentMethodType.creditCard ||
                _selectedType == PaymentMethodType.debitCard
            ? _holderNameController.text.trim()
            : null,
        email: _selectedType == PaymentMethodType.paypal
            ? _emailController.text.trim()
            : null,
        setAsDefault: _setAsDefault,
      );

      final paymentMethod = await ProfileService.addPaymentMethod(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Payment method added successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.pop(context, paymentMethod);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add payment method: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
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

  Widget _buildPaymentTypeSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method Type',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PaymentMethodType.creditCard,
            PaymentMethodType.debitCard,
            PaymentMethodType.paypal,
            PaymentMethodType.applePay,
            PaymentMethodType.googlePay,
          ].map((type) {
            final isSelected = _selectedType == type;
            return FilterChip(
              label: Text(type
                  .toString()
                  .split('.')
                  .last
                  .replaceAllMapped(
                    RegExp(r'([A-Z])'),
                    (match) => ' ${match.group(1)}',
                  )
                  .trim()),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedType = type;
                  });
                }
              },
              backgroundColor: theme.colorScheme.surfaceContainer,
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        TextFormField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: 'Card Number',
            prefixIcon: const Icon(Icons.credit_card),
            suffixIcon: _detectedBrand != CardBrand.unknown
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _detectedBrand.toString().split('.').last.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            TextInputFormatter.withFunction((oldValue, newValue) {
              return TextEditingValue(
                text: _formatCardNumber(newValue.text),
                selection: TextSelection.collapsed(
                  offset: _formatCardNumber(newValue.text).length,
                ),
              );
            }),
          ],
          validator: (value) {
            if (value?.replaceAll(' ', '').isEmpty ?? true) {
              return 'Please enter card number';
            }
            final cardNumber = value!.replaceAll(' ', '');
            if (cardNumber.length < 13 || cardNumber.length > 16) {
              return 'Please enter a valid card number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                decoration: InputDecoration(
                  labelText: 'MM/YY',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return TextEditingValue(
                      text: _formatExpiry(newValue.text),
                      selection: TextSelection.collapsed(
                        offset: _formatExpiry(newValue.text).length,
                      ),
                    );
                  }),
                ],
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Required';
                  }
                  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value!)) {
                    return 'Invalid format';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Required';
                  }
                  if (value!.length < 3) {
                    return 'Invalid CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _holderNameController,
          decoration: InputDecoration(
            labelText: 'Cardholder Name',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Please enter cardholder name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPayPalForm() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'PayPal Email',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'Please enter PayPal email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildDigitalWalletInfo() {
    final theme = Theme.of(context);
    final walletName = _selectedType == PaymentMethodType.applePay
        ? 'Apple Pay'
        : 'Google Pay';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            _selectedType == PaymentMethodType.applePay
                ? Icons.phone_iphone
                : Icons.android,
            size: 48,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(height: 12),
          Text(
            '$walletName will be set up automatically',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your default payment method from $walletName will be used for transactions.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _holderNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Payment Method',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPaymentTypeSelector(),
              const SizedBox(height: 24),

              if (_selectedType == PaymentMethodType.creditCard ||
                  _selectedType == PaymentMethodType.debitCard)
                _buildCardForm()
              else if (_selectedType == PaymentMethodType.paypal)
                _buildPayPalForm()
              else
                _buildDigitalWalletInfo(),

              const SizedBox(height: 24),

              // Set as default checkbox
              CheckboxListTile(
                title: const Text('Set as default payment method'),
                value: _setAsDefault,
                onChanged: (value) {
                  setState(() {
                    _setAsDefault = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 32),

              // Add button
              SizedBox(
                width: double.infinity,
                child: AnimatedButton(
                  text: 'Add Payment Method',
                  onPressed: _addPaymentMethod,
                  isLoading: _isLoading,
                  icon: Icons.add,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
