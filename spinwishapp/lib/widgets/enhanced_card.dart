import 'package:flutter/material.dart';
import 'package:spinwishapp/utils/design_system.dart';

enum CardStyle {
  standard,
  elevated,
  hero,
  glass,
  interactive,
}

class EnhancedCard extends StatefulWidget {
  final Widget child;
  final CardStyle style;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final bool isSelected;
  final Color? backgroundColor;
  final List<BoxShadow>? customShadows;
  final BorderRadius? customRadius;

  const EnhancedCard({
    super.key,
    required this.child,
    this.style = CardStyle.standard,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.isSelected = false,
    this.backgroundColor,
    this.customShadows,
    this.customRadius,
  });

  @override
  State<EnhancedCard> createState() => _EnhancedCardState();
}

class _EnhancedCardState extends State<EnhancedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.style == CardStyle.interactive ? 1.02 : 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onTapDown() {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp() {
    setState(() {
      _isPressed = false;
    });
  }

  BoxDecoration _buildDecoration(ThemeData theme) {
    switch (widget.style) {
      case CardStyle.standard:
        return _buildStandardDecoration(theme);
      case CardStyle.elevated:
        return _buildElevatedDecoration(theme);
      case CardStyle.hero:
        return _buildHeroDecoration(theme);
      case CardStyle.glass:
        return _buildGlassDecoration(theme);
      case CardStyle.interactive:
        return _buildInteractiveDecoration(theme);
    }
  }

  BoxDecoration _buildStandardDecoration(ThemeData theme) {
    return BoxDecoration(
      color: widget.backgroundColor ?? theme.colorScheme.surface,
      borderRadius: widget.customRadius ?? 
          BorderRadius.circular(SpinWishDesignSystem.radiusMD),
      border: Border.all(
        color: theme.colorScheme.outline.withOpacity(0.1),
        width: 1,
      ),
      boxShadow: widget.customShadows ?? 
          SpinWishDesignSystem.shadowSM(theme.colorScheme.shadow),
    );
  }

  BoxDecoration _buildElevatedDecoration(ThemeData theme) {
    final baseShadows = SpinWishDesignSystem.shadowLG(theme.colorScheme.shadow);
    final hoverShadows = SpinWishDesignSystem.shadowXL(theme.colorScheme.shadow);
    
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          widget.backgroundColor ?? theme.colorScheme.surface,
          (widget.backgroundColor ?? theme.colorScheme.surface).withOpacity(0.9),
        ],
      ),
      borderRadius: widget.customRadius ?? 
          BorderRadius.circular(SpinWishDesignSystem.radiusLG),
      border: Border.all(
        color: theme.colorScheme.outline.withOpacity(0.15),
        width: 1.5,
      ),
      boxShadow: widget.customShadows ?? [
        ...baseShadows,
        if (_isHovered) ...hoverShadows,
      ],
    );
  }

  BoxDecoration _buildHeroDecoration(ThemeData theme) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          widget.backgroundColor ?? theme.colorScheme.surface,
          (widget.backgroundColor ?? theme.colorScheme.surfaceContainer),
        ],
      ),
      borderRadius: widget.customRadius ?? 
          BorderRadius.circular(SpinWishDesignSystem.radiusXL),
      border: Border.all(
        color: theme.colorScheme.outline.withOpacity(0.2),
        width: 2,
      ),
      boxShadow: widget.customShadows ?? [
        ...SpinWishDesignSystem.shadow2XL(theme.colorScheme.shadow),
        ...SpinWishDesignSystem.glowSM(theme.colorScheme.primary),
      ],
    );
  }

  BoxDecoration _buildGlassDecoration(ThemeData theme) {
    return BoxDecoration(
      color: (widget.backgroundColor ?? theme.colorScheme.surface).withOpacity(0.7),
      borderRadius: widget.customRadius ?? 
          BorderRadius.circular(SpinWishDesignSystem.radiusLG),
      border: Border.all(
        color: theme.colorScheme.outline.withOpacity(0.3),
        width: 1,
      ),
      boxShadow: widget.customShadows ?? 
          SpinWishDesignSystem.shadowXL(theme.colorScheme.shadow),
    );
  }

  BoxDecoration _buildInteractiveDecoration(ThemeData theme) {
    final baseShadows = SpinWishDesignSystem.shadowMD(theme.colorScheme.shadow);
    final hoverShadows = SpinWishDesignSystem.shadowLG(theme.colorScheme.shadow);
    final pressedShadows = SpinWishDesignSystem.shadowSM(theme.colorScheme.shadow);
    
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          widget.backgroundColor ?? theme.colorScheme.surface,
          (widget.backgroundColor ?? theme.colorScheme.surface).withOpacity(0.95),
        ],
      ),
      borderRadius: widget.customRadius ?? 
          BorderRadius.circular(SpinWishDesignSystem.radiusMD),
      border: Border.all(
        color: widget.isSelected 
            ? theme.colorScheme.primary.withOpacity(0.5)
            : theme.colorScheme.outline.withOpacity(0.1),
        width: widget.isSelected ? 2 : 1,
      ),
      boxShadow: widget.customShadows ?? [
        if (_isPressed) ...pressedShadows
        else if (_isHovered) ...hoverShadows
        else ...baseShadows,
        if (widget.isSelected) ...SpinWishDesignSystem.glowSM(theme.colorScheme.primary),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget cardContent = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin ?? SpinWishDesignSystem.marginSM,
      decoration: _buildDecoration(theme),
      child: ClipRRect(
        borderRadius: widget.customRadius ?? 
            BorderRadius.circular(_getRadiusForStyle()),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: widget.onTap != null ? (_) => _onTapDown() : null,
            onTapUp: widget.onTap != null ? (_) => _onTapUp() : null,
            onTapCancel: widget.onTap != null ? () => _onTapUp() : null,
            borderRadius: widget.customRadius ?? 
                BorderRadius.circular(_getRadiusForStyle()),
            child: Container(
              padding: widget.padding ?? _getPaddingForStyle(),
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    if (widget.style == CardStyle.interactive || widget.onTap != null) {
      cardContent = MouseRegion(
        onEnter: (_) => _onHoverChanged(true),
        onExit: (_) => _onHoverChanged(false),
        child: cardContent,
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: cardContent,
        );
      },
    );
  }

  double _getRadiusForStyle() {
    switch (widget.style) {
      case CardStyle.standard:
        return SpinWishDesignSystem.radiusMD;
      case CardStyle.elevated:
        return SpinWishDesignSystem.radiusLG;
      case CardStyle.hero:
        return SpinWishDesignSystem.radiusXL;
      case CardStyle.glass:
        return SpinWishDesignSystem.radiusLG;
      case CardStyle.interactive:
        return SpinWishDesignSystem.radiusMD;
    }
  }

  EdgeInsets _getPaddingForStyle() {
    switch (widget.style) {
      case CardStyle.standard:
        return SpinWishDesignSystem.paddingMD;
      case CardStyle.elevated:
        return SpinWishDesignSystem.paddingLG;
      case CardStyle.hero:
        return SpinWishDesignSystem.paddingXL;
      case CardStyle.glass:
        return SpinWishDesignSystem.paddingLG;
      case CardStyle.interactive:
        return SpinWishDesignSystem.paddingMD;
    }
  }
}
