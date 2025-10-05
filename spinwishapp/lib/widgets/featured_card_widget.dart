import 'package:flutter/material.dart';
import 'package:spinwishapp/utils/design_system.dart';

enum FeaturedCardGradient { purple, green, blue }

class FeaturedCardWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final FeaturedCardGradient gradientType;
  final VoidCallback? onPlay;
  final VoidCallback? onFavorite;
  final VoidCallback? onInfo;
  final VoidCallback? onMore;
  final bool isFavorite;
  final bool isPlaying;

  const FeaturedCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.gradientType = FeaturedCardGradient.purple,
    this.onPlay,
    this.onFavorite,
    this.onInfo,
    this.onMore,
    this.isFavorite = false,
    this.isPlaying = false,
  });

  @override
  State<FeaturedCardWidget> createState() => _FeaturedCardWidgetState();
}

class _FeaturedCardWidgetState extends State<FeaturedCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Color> _getGradientColors(ThemeData theme) {
    switch (widget.gradientType) {
      case FeaturedCardGradient.purple:
        return [
          const Color(0xFF8B5CF6),
          const Color(0xFFEC4899),
        ];
      case FeaturedCardGradient.green:
        return [
          const Color(0xFF10B981),
          const Color(0xFF059669),
        ];
      case FeaturedCardGradient.blue:
        return [
          const Color(0xFF3B82F6),
          const Color(0xFF1D4ED8),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradientColors = _getGradientColors(theme);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: 200,
            margin: const EdgeInsets.symmetric(
              horizontal: SpinWishDesignSystem.spaceMD,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusLG),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Artistic lighting effect
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(SpinWishDesignSystem.spaceLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.title.isNotEmpty)
                              Text(
                                widget.title,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (widget.title.isNotEmpty && widget.subtitle.isNotEmpty)
                              const SizedBox(height: SpinWishDesignSystem.spaceSM),
                            if (widget.subtitle.isNotEmpty)
                              Text(
                                widget.subtitle,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      
                      // Control Buttons
                      _buildControlButtons(theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButtons(ThemeData theme) {
    return Row(
      children: [
        // Play Button
        _buildControlButton(
          icon: widget.isPlaying ? Icons.pause : Icons.play_arrow,
          onTap: () {
            _animatePress();
            widget.onPlay?.call();
          },
          isPrimary: true,
        ),
        
        const SizedBox(width: SpinWishDesignSystem.spaceMD),
        
        // Heart Button
        _buildControlButton(
          icon: widget.isFavorite ? Icons.favorite : Icons.favorite_border,
          onTap: () {
            _animatePress();
            widget.onFavorite?.call();
          },
          isActive: widget.isFavorite,
        ),
        
        const SizedBox(width: SpinWishDesignSystem.spaceMD),
        
        // Info Button
        _buildControlButton(
          icon: Icons.info_outline,
          onTap: () {
            _animatePress();
            widget.onInfo?.call();
          },
        ),
        
        const SizedBox(width: SpinWishDesignSystem.spaceMD),
        
        // More Options Button
        _buildControlButton(
          icon: Icons.more_horiz,
          onTap: () {
            _animatePress();
            widget.onMore?.call();
          },
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
    bool isActive = false,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPrimary
            ? Colors.white
            : isActive
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Icon(
            icon,
            color: isPrimary
                ? widget.gradientType == FeaturedCardGradient.purple
                    ? const Color(0xFF8B5CF6)
                    : widget.gradientType == FeaturedCardGradient.green
                        ? const Color(0xFF10B981)
                        : const Color(0xFF3B82F6)
                : Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _animatePress() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }
}
