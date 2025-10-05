import 'package:flutter/material.dart';
import 'package:spinwishapp/utils/design_system.dart';

enum ChipStyle {
  standard,
  outlined,
  filled,
  gradient,
  neon,
}

class EnhancedChip extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isSelected;
  final ChipStyle style;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final List<Color>? gradientColors;
  final EdgeInsets? padding;
  final double? fontSize;
  final FontWeight? fontWeight;

  const EnhancedChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.onDelete,
    this.isSelected = false,
    this.style = ChipStyle.standard,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.gradientColors,
    this.padding,
    this.fontSize,
    this.fontWeight,
  });

  @override
  State<EnhancedChip> createState() => _EnhancedChipState();
}

class _EnhancedChipState extends State<EnhancedChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
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
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _glowAnimation = Tween<double>(
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
      case ChipStyle.standard:
        return _buildStandardDecoration(theme);
      case ChipStyle.outlined:
        return _buildOutlinedDecoration(theme);
      case ChipStyle.filled:
        return _buildFilledDecoration(theme);
      case ChipStyle.gradient:
        return _buildGradientDecoration(theme);
      case ChipStyle.neon:
        return _buildNeonDecoration(theme);
    }
  }

  BoxDecoration _buildStandardDecoration(ThemeData theme) {
    return BoxDecoration(
      color: widget.isSelected
          ? theme.colorScheme.primary.withOpacity(0.1)
          : (widget.backgroundColor ?? theme.colorScheme.surfaceContainer),
      borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusFull),
      border: Border.all(
        color: widget.isSelected
            ? theme.colorScheme.primary.withOpacity(0.3)
            : (widget.borderColor ?? theme.colorScheme.outline.withOpacity(0.2)),
        width: widget.isSelected ? 1.5 : 1,
      ),
      boxShadow: [
        ...SpinWishDesignSystem.shadowSM(theme.colorScheme.shadow),
        if (widget.isSelected)
          ...SpinWishDesignSystem.glowSM(theme.colorScheme.primary),
      ],
    );
  }

  BoxDecoration _buildOutlinedDecoration(ThemeData theme) {
    return BoxDecoration(
      color: widget.isSelected
          ? theme.colorScheme.primary.withOpacity(0.05)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusFull),
      border: Border.all(
        color: widget.isSelected
            ? theme.colorScheme.primary
            : (widget.borderColor ?? theme.colorScheme.outline.withOpacity(0.4)),
        width: widget.isSelected ? 2 : 1.5,
      ),
      boxShadow: widget.isSelected
          ? SpinWishDesignSystem.glowSM(theme.colorScheme.primary)
          : [],
    );
  }

  BoxDecoration _buildFilledDecoration(ThemeData theme) {
    return BoxDecoration(
      color: widget.isSelected
          ? theme.colorScheme.primary
          : (widget.backgroundColor ?? theme.colorScheme.surfaceContainer),
      borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusFull),
      boxShadow: [
        ...SpinWishDesignSystem.shadowMD(theme.colorScheme.shadow),
        if (widget.isSelected)
          ...SpinWishDesignSystem.glowMD(theme.colorScheme.primary),
      ],
    );
  }

  BoxDecoration _buildGradientDecoration(ThemeData theme) {
    final gradientColors = widget.gradientColors ?? [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
    ];

    return BoxDecoration(
      gradient: widget.isSelected
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            )
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surfaceContainer,
                theme.colorScheme.surfaceContainer.withOpacity(0.8),
              ],
            ),
      borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusFull),
      border: Border.all(
        color: widget.isSelected
            ? Colors.transparent
            : theme.colorScheme.outline.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        ...SpinWishDesignSystem.shadowMD(theme.colorScheme.shadow),
        if (widget.isSelected)
          ...SpinWishDesignSystem.glowMD(gradientColors.first),
      ],
    );
  }

  BoxDecoration _buildNeonDecoration(ThemeData theme) {
    final neonColor = widget.backgroundColor ?? theme.colorScheme.primary;
    
    return BoxDecoration(
      color: widget.isSelected
          ? neonColor.withOpacity(0.2)
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusFull),
      border: Border.all(
        color: neonColor,
        width: widget.isSelected ? 2 : 1,
      ),
      boxShadow: [
        ...SpinWishDesignSystem.shadowMD(theme.colorScheme.shadow),
        if (widget.isSelected || _isHovered) ...[
          ...SpinWishDesignSystem.glowLG(neonColor),
          BoxShadow(
            color: neonColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ],
    );
  }

  Color _getTextColor(ThemeData theme) {
    if (widget.textColor != null) return widget.textColor!;

    switch (widget.style) {
      case ChipStyle.standard:
        return widget.isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface;
      case ChipStyle.outlined:
        return widget.isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface;
      case ChipStyle.filled:
        return widget.isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface;
      case ChipStyle.gradient:
        return widget.isSelected
            ? Colors.white
            : theme.colorScheme.onSurface;
      case ChipStyle.neon:
        return widget.isSelected
            ? widget.backgroundColor ?? theme.colorScheme.primary
            : theme.colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = _getTextColor(theme);

    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.95 : _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => _onTapDown(),
              onTapUp: (_) => _onTapUp(),
              onTapCancel: () => _onTapUp(),
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: _buildDecoration(theme),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusFull),
                    onTap: widget.onTap,
                    child: Container(
                      padding: widget.padding ?? 
                          EdgeInsets.symmetric(
                            horizontal: SpinWishDesignSystem.spaceMD,
                            vertical: SpinWishDesignSystem.spaceSM,
                          ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: 16,
                              color: textColor,
                            ),
                            SizedBox(width: SpinWishDesignSystem.spaceXS),
                          ],
                          Text(
                            widget.label,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: textColor,
                              fontSize: widget.fontSize ?? 14,
                              fontWeight: widget.fontWeight ?? FontWeight.w500,
                            ),
                          ),
                          if (widget.onDelete != null) ...[
                            SizedBox(width: SpinWishDesignSystem.spaceXS),
                            GestureDetector(
                              onTap: widget.onDelete,
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
