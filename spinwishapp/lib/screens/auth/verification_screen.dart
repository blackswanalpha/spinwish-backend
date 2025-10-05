import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:spinwishapp/widgets/animated_button.dart';
import 'package:spinwishapp/services/verification_service.dart';
import 'package:spinwishapp/screens/home/main_screen.dart';
import 'package:spinwishapp/screens/dj/dj_main_screen.dart';
import 'package:spinwishapp/utils/page_transitions.dart';

class VerificationScreen extends StatefulWidget {
  final String emailAddress;
  final String verificationType; // "EMAIL" or "PHONE"
  final String? phoneNumber;
  final String username;
  final bool isDJ; // Flag to distinguish DJ verification from user verification

  const VerificationScreen({
    Key? key,
    required this.emailAddress,
    required this.verificationType,
    this.phoneNumber,
    required this.username,
    this.isDJ = false, // Default to false for regular users
  }) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _shakeAnimation;

  bool _isLoading = false;
  bool _isResending = false;
  String _errorMessage = '';
  int _resendCountdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _animationController.forward();
    _sendVerificationCode();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    _countdownTimer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    try {
      setState(() {
        _isResending = true;
        _errorMessage = '';
      });

      await VerificationService.sendVerificationCode(
        widget.emailAddress,
        widget.verificationType,
      );

      _startResendCountdown();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Verification code sent to ${widget.verificationType == 'EMAIL' ? 'your email' : 'your phone'}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send verification code. Please try again.';
      });
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCountdown--;
      });

      if (_resendCountdown <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyCode() async {
    final code = _controllers.map((c) => c.text).join();

    if (code.length != 6) {
      _showError('Please enter the complete 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final success = await VerificationService.verifyCode(
        widget.emailAddress,
        code,
        widget.verificationType,
      );

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate based on user type
        if (widget.isDJ) {
          // For DJs, navigate directly to DJ main screen after verification
          // (tokens are already stored, so they're automatically logged in)
          Navigator.of(context).pushAndRemoveUntil(
            PageTransitions.authTransition(const DJMainScreen()),
            (route) => false,
          );
        } else {
          // For regular users, navigate to main screen
          Navigator.of(context).pushAndRemoveUntil(
            PageTransitions.authTransition(const MainScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
      _shakeController.forward().then((_) => _shakeController.reverse());
      _clearCode();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _clearCode() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-verify when all digits are entered
    if (index == 5 && value.isNotEmpty) {
      _verifyCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom -
                          48,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Header
                        const SizedBox(height: 20),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Icon(
                            widget.verificationType == 'EMAIL'
                                ? Icons.email
                                : Icons.sms,
                            size: 40,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          'Enter Verification Code',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'We sent a 6-digit code to ${widget.verificationType == 'EMAIL' ? 'your email address' : 'your phone number'}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Code Input Fields
                        SlideTransition(
                          position: _shakeAnimation,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                                6, (index) => _buildCodeField(index)),
                          ),
                        ),

                        if (_errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Verify Button
                        AnimatedButton(
                          text: 'Verify Account',
                          onPressed: _isLoading ? null : _verifyCode,
                          isLoading: _isLoading,
                          width: double.infinity,
                          backgroundColor: theme.colorScheme.primary,
                          textColor: theme.colorScheme.onPrimary,
                        ),

                        const SizedBox(height: 24),

                        // Resend Code
                        if (_resendCountdown > 0)
                          Text(
                            'Resend code in ${_resendCountdown}s',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          )
                        else
                          TextButton(
                            onPressed:
                                _isResending ? null : _sendVerificationCode,
                            child: Text(
                              _isResending ? 'Sending...' : 'Resend Code',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCodeField(int index) {
    final theme = Theme.of(context);

    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(
          color: _controllers[index].text.isNotEmpty
              ? theme.colorScheme.primary
              : Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (value) => _onCodeChanged(value, index),
        onTap: () {
          _controllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: _controllers[index].text.length),
          );
        },
      ),
    );
  }
}
