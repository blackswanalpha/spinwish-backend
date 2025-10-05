import 'package:flutter/material.dart';

import 'package:spinwishapp/screens/auth/verification_screen.dart';
import 'package:spinwishapp/services/auth_service.dart';
import 'package:spinwishapp/utils/page_transitions.dart';

class VerificationMethodScreen extends StatefulWidget {
  final String emailAddress;
  final String? phoneNumber;
  final String username;
  final bool isDJ; // Flag to distinguish DJ verification from user verification
  final bool isFromLogin; // Flag to indicate if user came from login attempt

  const VerificationMethodScreen({
    Key? key,
    required this.emailAddress,
    this.phoneNumber,
    required this.username,
    this.isDJ = false, // Default to false for regular users
    this.isFromLogin = false, // Default to false for registration flow
  }) : super(key: key);

  @override
  State<VerificationMethodScreen> createState() =>
      _VerificationMethodScreenState();
}

class _VerificationMethodScreenState extends State<VerificationMethodScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectVerificationMethod(String method) {
    Navigator.of(context).pushReplacement(
      PageTransitions.authTransition(
        VerificationScreen(
          emailAddress: widget.emailAddress,
          verificationType: method,
          phoneNumber: widget.phoneNumber,
          username: widget.username,
          isDJ: widget.isDJ, // Pass the DJ flag
        ),
      ),
    );
  }

  Future<void> _resendVerificationEmail() async {
    try {
      await AuthService.resendVerificationEmail(widget.emailAddress);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Verification email sent! Check your inbox.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('Exception:')) {
          errorMessage = errorMessage.replaceFirst('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
                        const SizedBox(height: 40),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Icon(
                            Icons.verified_user,
                            size: 40,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          widget.isFromLogin
                              ? 'Account Verification Required'
                              : 'Verify Your Account',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        Text(
                          widget.isFromLogin
                              ? 'Your account needs to be verified before you can sign in. Choose your preferred verification method below.'
                              : 'Choose how you\'d like to verify your SpinWish account',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Verification Options
                        // Email Verification Option
                        _buildVerificationOption(
                          context,
                          icon: Icons.email,
                          title: 'Email Verification',
                          subtitle:
                              'We\'ll send a code to\n${_maskEmail(widget.emailAddress)}',
                          onTap: () => _selectVerificationMethod('EMAIL'),
                          color: Colors.blue,
                        ),

                        const SizedBox(height: 20),

                        // Phone Verification Option (only if phone number provided)
                        if (widget.phoneNumber != null &&
                            widget.phoneNumber!.isNotEmpty)
                          _buildVerificationOption(
                            context,
                            icon: Icons.sms,
                            title: 'SMS Verification',
                            subtitle:
                                'We\'ll send a code to\n${_maskPhoneNumber(widget.phoneNumber!)}',
                            onTap: () => _selectVerificationMethod('PHONE'),
                            color: Colors.green,
                          ),

                        const SizedBox(height: 40),

                        // Resend verification email option (only for users from login)
                        if (widget.isFromLogin) ...[
                          TextButton.icon(
                            onPressed: _resendVerificationEmail,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Resend Verification Email'),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Info text
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.isFromLogin
                                      ? 'If you already received a verification email, check your inbox and spam folder.'
                                      : 'You\'ll receive a 6-digit verification code that expires in 10 minutes.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildVerificationOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _maskEmail(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) return email;

    final maskedUsername = username.substring(0, 2) + '****';
    return '$maskedUsername@$domain';
  }

  String _maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length < 4) return phoneNumber;
    return phoneNumber.substring(0, 4) +
        '****' +
        phoneNumber.substring(phoneNumber.length - 2);
  }
}
