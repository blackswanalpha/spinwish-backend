import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spinwishapp/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _pulseController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Logo animations - faster and more impactful
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    // Text animations - smoother timing
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textSlideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Progress animation - synchronized with overall timing
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Pulse animation for subtle logo effect after main animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    // Add haptic feedback
    try {
      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }

    try {
      // Start logo animation immediately
      if (mounted && !_isDisposed) {
        _logoController.forward();
      }

      // Start text animation after logo begins (overlapping for smoother flow)
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted && !_isDisposed) {
        _textController.forward();
      }

      // Start progress animation after text begins
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted && !_isDisposed) {
        _progressController.forward();
      }

      // Start subtle pulse animation after main animations
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted && !_isDisposed) {
        _pulseController.repeat(reverse: true);
      }
    } catch (e) {
      // Handle any animation errors gracefully
      debugPrint('Animation error: $e');
      // Ensure animations are in a valid state
      if (mounted && !_isDisposed) {
        try {
          _logoController.value = 1.0;
          _textController.value = 1.0;
          _progressController.value = 1.0;
        } catch (resetError) {
          debugPrint('Animation reset error: $resetError');
        }
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Fallback colors in case theme extensions aren't available
    final primaryGradientStart = theme.colorScheme.primaryGradientStart;
    final primaryGradientEnd = theme.colorScheme.primaryGradientEnd;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryGradientStart.withOpacity(0.1),
              primaryGradientEnd.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top spacer
              const Spacer(flex: 2),

              // Logo section
              AnimatedBuilder(
                animation:
                    Listenable.merge([_logoController, _pulseController]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value * _pulseAnimation.value,
                    child: Transform.rotate(
                      angle: _logoRotationAnimation.value * 0.1,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryGradientStart,
                              primaryGradientEnd,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.music_note_rounded,
                            size: 60,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // App name and tagline
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textFadeAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, _textSlideAnimation.value),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'SpinWish',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: 1.2,
                              fontSize: 32,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Request your favorite tracks',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                              letterSpacing: 0.5,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const Spacer(flex: 2),

              // Loading section
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _progressAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Loading...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: size.width * 0.6,
                            child: LinearProgressIndicator(
                              backgroundColor:
                                  theme.colorScheme.outline.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                primaryGradientStart,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
