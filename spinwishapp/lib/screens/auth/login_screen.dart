import 'package:flutter/material.dart';
import 'package:spinwishapp/services/auth_service.dart';
import 'package:spinwishapp/screens/home/main_screen.dart';
import 'package:spinwishapp/screens/auth/verification_method_screen.dart';
import 'package:spinwishapp/widgets/animated_text_field.dart';
import 'package:spinwishapp/widgets/animated_password_field.dart';
import 'package:spinwishapp/widgets/animated_phone_field.dart';
import 'package:spinwishapp/utils/page_transitions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  String _phoneNumber = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // Login flow
        final success = await AuthService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (success && mounted) {
          // Use animated transition to main screen
          context.pushReplacementFade(const MainScreen());
        }
      } else {
        // Registration flow - navigate to verification
        final registerResponse = await AuthService.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          _confirmPasswordController.text,
          phoneNumber: _phoneNumber.isNotEmpty ? _phoneNumber : null,
        );

        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageTransitions.authTransition(
              VerificationMethodScreen(
                emailAddress: registerResponse.emailAddress,
                phoneNumber: _phoneNumber.isNotEmpty ? _phoneNumber : null,
                username: registerResponse.username,
                isDJ: false, // Mark this as regular user verification
              ),
            ),
          );
        }
      }
    } on UnverifiedUserException catch (e) {
      if (mounted) {
        // Redirect to verification screen for unverified users
        Navigator.of(context).pushReplacement(
          PageTransitions.authTransition(
            VerificationMethodScreen(
              emailAddress: e.emailAddress,
              username: e.username,
              isDJ: e.isDJ,
              isFromLogin: true, // User came from login attempt
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Show more user-friendly error messages
        String errorMessage = e.toString();
        if (errorMessage.contains('Login failed:')) {
          errorMessage = errorMessage.replaceFirst('Login failed: ', '');
        }
        if (errorMessage.contains('Registration failed:')) {
          errorMessage = errorMessage.replaceFirst('Registration failed: ', '');
        }
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Title only (removed icon logo)
              Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      'SpinWish',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Request your favorite tracks',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!_isLogin) ...[
                      AnimatedTextField(
                        controller: _nameController,
                        labelText: 'Full Name',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    AnimatedTextField(
                      controller: _emailController,
                      labelText: 'Email Address',
                      prefixIcon: Icons
                          .email_outlined, // Huge icon will be applied in widget
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email address';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    AnimatedPasswordField(
                      controller: _passwordController,
                      labelText: 'Password',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 20),
                      AnimatedPasswordField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirm Password',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      AnimatedPhoneField(
                        controller: _phoneController,
                        label: 'Phone Number (Optional)',
                        initialCountryCode: '+254',
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            // Basic phone number validation
                            if (value.length < 10) {
                              return 'Please enter a valid phone number';
                            }
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _phoneNumber = value;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button with custom styling
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(28), // 30% increase from 12
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _isLoading ? null : _submit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoading) ...[
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            _isLoading
                                ? 'Loading...'
                                : (_isLogin ? 'Sign In' : 'Sign Up'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white, // White text
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Forgot Password Link (only show during login)
              if (_isLogin) ...[
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: Text(
                    'Forgot Password?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Toggle between login and register
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? 'Don\'t have an account? Sign Up'
                      : 'Already have an account? Sign In',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Completely Redesigned DJ Authentication Button
              Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A1B2E), // Dark blue-black
                      const Color(0xFF2D1B69), // Deep purple
                      const Color(0xFF6C63FF), // Bright purple
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.pushNamed(context, '/dj-auth');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          // DJ Icon with animated glow effect
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.headphones,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Text content
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'For DJs',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Start your DJ journey',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Arrow with glow effect
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
