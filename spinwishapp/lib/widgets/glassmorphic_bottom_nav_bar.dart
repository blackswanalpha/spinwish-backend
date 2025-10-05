import 'package:flutter/material.dart';

class NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class GlassmorphicBottomNavBar extends StatefulWidget {
  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double height;
  final double blurRadius;

  const GlassmorphicBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.height = 80,
    this.blurRadius = 12,
  });

  @override
  State<GlassmorphicBottomNavBar> createState() =>
      _GlassmorphicBottomNavBarState();
}

class _GlassmorphicBottomNavBarState extends State<GlassmorphicBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _scaleController;
  int? _tappedIndex;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: widget.height + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        // Glassmorphic background without backdrop filter
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (isDark
                ? theme.colorScheme.surface.withOpacity(0.85)
                : theme.colorScheme.surface.withOpacity(0.95)),
            (isDark
                ? theme.colorScheme.surface.withOpacity(0.9)
                : theme.colorScheme.surface.withOpacity(0.98)),
          ],
        ),
        // Glassmorphic border effect
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.15)
                : theme.colorScheme.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        // Enhanced shadow for glass depth
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
            spreadRadius: -2,
          ),
          // Inner glow effect
          BoxShadow(
            color: isDark
                ? theme.colorScheme.primary.withOpacity(0.05)
                : Colors.white.withOpacity(0.6),
            blurRadius: 8,
            offset: const Offset(0, -1),
            spreadRadius: -1,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Expanded(
                child: _buildNavItem(context, item, index),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, NavItem item, int index) {
    final theme = Theme.of(context);
    final isSelected = widget.currentIndex == index;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _tappedIndex = index);
        _scaleController.forward();
      },
      onTapUp: (_) {
        _scaleController.reverse();
        _rippleController.forward().then((_) {
          _rippleController.reset();
        });
        widget.onTap(index);
        setState(() => _tappedIndex = null);
      },
      onTapCancel: () {
        _scaleController.reverse();
        setState(() => _tappedIndex = null);
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_rippleController, _scaleController]),
        builder: (context, child) {
          final scale = _tappedIndex == index
              ? 1.0 - (_scaleController.value * 0.05)
              : 1.0;

          return Transform.scale(
            scale: scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.15),
                          theme.colorScheme.primary.withOpacity(0.08),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.2)
                            : theme.colorScheme.primary.withOpacity(0.3),
                        width: 1,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white.withOpacity(0.8),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                          spreadRadius: -1,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color: isSelected
                          ? (isDark
                              ? theme.colorScheme.primary.withOpacity(0.9)
                              : theme.colorScheme.primary)
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: theme.textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? (isDark
                                  ? theme.colorScheme.primary.withOpacity(0.9)
                                  : theme.colorScheme.primary)
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ) ??
                        const TextStyle(),
                    child: Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
