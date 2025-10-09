import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spinwishapp/models/payment.dart';
import 'package:spinwishapp/services/payme_service.dart';
import 'package:spinwishapp/screens/payment/payment_success_screen.dart';

class PaymePaymentScreen extends StatefulWidget {
  final PaymentType type;
  final double amount;
  final String description;
  final Map<String, dynamic>? metadata;

  const PaymePaymentScreen({
    super.key,
    required this.type,
    required this.amount,
    required this.description,
    this.metadata,
  });

  @override
  State<PaymePaymentScreen> createState() => _PaymePaymentScreenState();
}

class _PaymePaymentScreenState extends State<PaymePaymentScreen> {
  final _accountNumberController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  bool _isProcessingPayment = false;
  String? _errorMessage;
  String? _transactionId;

  @override
  void dispose() {
    _accountNumberController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    if (_accountNumberController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your PayMe account number';
      });
      return;
    }

    if (_pinController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your PIN';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await PaymeService.initiateDemoPayment(
        accountNumber: _accountNumberController.text.trim(),
        pin: _pinController.text.trim(),
        amount: widget.amount,
        requestId: widget.metadata?['requestId'],
        djId: widget.metadata?['djId'],
      );

      if (response.isSuccess) {
        setState(() {
          _transactionId = response.transactionId;
          _isLoading = false;
          _isProcessingPayment = true;
        });

        // Simulate payment processing
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          // Create payment object for success screen
          final payment = Payment(
            id: 'payme_${DateTime.now().millisecondsSinceEpoch}',
            userId: 'current_user_id', // TODO: Get from AuthService
            type: widget.type,
            amount: widget.amount,
            method: PaymentMethod.payme,
            status: PaymentStatus.completed,
            timestamp: DateTime.now(),
            description: widget.description,
            sessionId: widget.metadata?['sessionId'],
            djId: widget.metadata?['djId'],
            songId: widget.metadata?['songId'],
            transactionId: response.transactionId,
            metadata: widget.metadata,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(payment: payment),
            ),
          ).then((_) {
            if (mounted) {
              Navigator.pop(context, true);
            }
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              response.message ?? 'Payment failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PayMe Payment'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // PayMe Logo/Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.payment,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Payment Info
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Amount to Pay',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'KSH ${widget.amount.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              if (!_isProcessingPayment) ...[
                // Account Number Input
                TextField(
                  controller: _accountNumberController,
                  decoration: InputDecoration(
                    labelText: 'PayMe Account Number',
                    hintText: 'Enter your account number',
                    prefixIcon: const Icon(Icons.account_circle),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  keyboardType: TextInputType.text,
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 16),

                // PIN Input
                TextField(
                  controller: _pinController,
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    hintText: 'Enter your 4-digit PIN',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  enabled: !_isLoading,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),

                const SizedBox(height: 8),

                // Demo Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This is a demo payment. Any account number and PIN will work.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Pay Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _initiatePayment,
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
                        : Text(
                            'Pay KSH ${widget.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ] else ...[
                // Processing Payment UI
                _buildProcessingUI(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingUI(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 32),
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text(
          'Processing Payment...',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Please wait while we process your payment',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        if (_transactionId != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Transaction ID',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _transactionId!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
