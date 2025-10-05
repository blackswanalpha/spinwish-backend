import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spinwishapp/services/mpesa_service.dart';
import 'package:spinwishapp/models/payment.dart';
import 'package:spinwishapp/screens/payment/payment_success_screen.dart';
import 'package:spinwishapp/utils/payment_error_handler.dart';

class MpesaPaymentScreen extends StatefulWidget {
  final PaymentType type;
  final double amount;
  final String description;
  final Map<String, dynamic>? metadata;

  const MpesaPaymentScreen({
    super.key,
    required this.type,
    required this.amount,
    required this.description,
    this.metadata,
  });

  @override
  State<MpesaPaymentScreen> createState() => _MpesaPaymentScreenState();
}

class _MpesaPaymentScreenState extends State<MpesaPaymentScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isProcessingPayment = false;
  String? _checkoutRequestId;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await MpesaService.initiateStkPush(
        phoneNumber: _phoneController.text.trim(),
        amount: widget.amount,
        requestId: widget.metadata?['requestId'],
        djName: widget.metadata?['djName'],
      );

      if (response.isSuccess) {
        setState(() {
          _checkoutRequestId = response.checkoutRequestId;
          _isLoading = false;
          _isProcessingPayment = true;
        });

        // Start polling for payment status
        _pollPaymentStatus(response.checkoutRequestId);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response.customerMessage.isNotEmpty
              ? response.customerMessage
              : 'Failed to initiate payment. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = PaymentErrorHandler.getUserFriendlyMessage(e);
      });

      // Show error dialog for better UX
      if (mounted) {
        PaymentErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Payment Initiation Failed',
          onRetry:
              PaymentErrorHandler.isRetryableError(e) ? _initiatePayment : null,
          onCancel: () => Navigator.of(context).pop(),
        );
      }
    }
  }

  Future<void> _pollPaymentStatus(String checkoutRequestId) async {
    try {
      final status = await MpesaService.pollPaymentStatus(checkoutRequestId);

      if (mounted) {
        if (status == PaymentStatus.completed) {
          // Create payment object for success screen
          final payment = Payment(
            id: 'mpesa_${DateTime.now().millisecondsSinceEpoch}',
            userId: 'current_user_id', // TODO: Get from AuthService
            type: widget.type,
            amount: widget.amount,
            method: PaymentMethod.mpesa,
            status: PaymentStatus.completed,
            timestamp: DateTime.now(),
            description: widget.description,
            sessionId: widget.metadata?['sessionId'],
            djId: widget.metadata?['djId'],
            songId: widget.metadata?['songId'],
            transactionId: checkoutRequestId,
            metadata: widget.metadata,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(payment: payment),
            ),
          ).then((result) {
            if (result == true && mounted) {
              Navigator.pop(context, true);
            }
          });
        } else if (status == PaymentStatus.failed) {
          setState(() {
            _isProcessingPayment = false;
            _errorMessage =
                'Payment was cancelled or failed. Please try again.';
          });
        } else {
          // Still pending - show timeout message
          setState(() {
            _isProcessingPayment = false;
            _errorMessage =
                'Payment is taking longer than expected. Please check your phone for the M-Pesa prompt.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
          _errorMessage =
              'Unable to verify payment status. Please contact support if money was deducted.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('M-Pesa Payment'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Summary Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.phone_android,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'M-Pesa Payment',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            'KSH ${widget.amount.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              if (!_isProcessingPayment) ...[
                // Phone Number Input
                Text(
                  'Enter your M-Pesa phone number',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You will receive an M-Pesa prompt on your phone to complete the payment.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '0712345678 or 254712345678',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!MpesaService.isValidKenyanPhoneNumber(value)) {
                      return 'Please enter a valid Kenyan phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Error Message
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

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
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Processing Payment',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please check your phone for the M-Pesa prompt and enter your PIN to complete the payment.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              if (_checkoutRequestId != null)
                Text(
                  'Transaction ID: ${_checkoutRequestId!.substring(0, 8)}...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontFamily: 'monospace',
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'This may take up to 2 minutes',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
