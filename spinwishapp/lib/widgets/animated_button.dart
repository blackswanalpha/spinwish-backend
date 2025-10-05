import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:spinwishapp/utils/design_system.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final Duration animationDuration;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _loadingController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    ));

    // Start fade-in animation
    _fadeController.forward();

    // Start loading animation if needed
    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
      }
    }
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleController,
        _fadeController,
        _loadingController,
      ]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: widget.animationDuration,
              width: widget.width,
              height: widget.height,
              decoration: isEnabled
                  ? _buildEnabledDecoration(theme)
                  : _buildDisabledDecoration(theme),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(SpinWishDesignSystem.radiusSM),
                  onTap: isEnabled ? widget.onPressed : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading) ...[
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: RotationTransition(
                              turns: _rotationAnimation,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.textColor ?? Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ] else if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: widget.textColor ??
                                (isEnabled
                                    ? Colors.white
                                    : Colors.grey.shade600),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Flexible(
                          child: Text(
                            widget.isLoading ? 'Loading...' : widget.text,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: widget.textColor ??
                                  (isEnabled
                                      ? Colors.white
                                      : Colors.grey.shade600),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildEnabledDecoration(ThemeData theme) {
    final baseColor = widget.backgroundColor ?? theme.colorScheme.primary;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor,
          baseColor.withOpacity(0.8),
        ],
      ),
      borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusSM),
      boxShadow: [
        // Enhanced shadow system
        ...SpinWishDesignSystem.shadowLG(theme.colorScheme.shadow),
        // Glow effect for primary buttons
        ...SpinWishDesignSystem.glowSM(baseColor),
      ],
      border: Border.all(
        color: baseColor.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  BoxDecoration _buildDisabledDecoration(ThemeData theme) {
    return BoxDecoration(
      color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
      borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusSM),
      boxShadow: SpinWishDesignSystem.shadowSM(theme.colorScheme.shadow),
      border: Border.all(
        color: theme.colorScheme.outline.withOpacity(0.2),
        width: 1,
      ),
    );
  }
}
