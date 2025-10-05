import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spinwishapp/services/theme_service.dart' as theme_service;
import 'package:spinwishapp/theme.dart';

class ThemeSwitcherWidget extends StatefulWidget {
  final bool showPresets;
  final bool compact;

  const ThemeSwitcherWidget({
    super.key,
    this.showPresets = true,
    this.compact = false,
  });

  @override
  State<ThemeSwitcherWidget> createState() => _ThemeSwitcherWidgetState();
}

class _ThemeSwitcherWidgetState extends State<ThemeSwitcherWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<theme_service.ThemeService>(
      builder: (context, themeService, child) {
        if (widget.compact) {
          return _buildCompactSwitcher(context, themeService);
        }
        return _buildFullSwitcher(context, themeService);
      },
    );
  }

  Widget _buildCompactSwitcher(
      BuildContext context, theme_service.ThemeService themeService) {
    final theme = Theme.of(context);
    final isDark = themeService.isDarkMode(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () async {
              _animationController.forward().then((_) {
                _animationController.reverse();
              });
              await themeService.toggleTheme();
            },
            child: Container(
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [Colors.indigo.shade800, Colors.purple.shade800]
                      : [Colors.orange.shade300, Colors.yellow.shade300],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: isDark ? 28 : 4,
                    top: 4,
                    child: RotationTransition(
                      turns: _rotationAnimation,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isDark ? Icons.nightlight_round : Icons.wb_sunny,
                          size: 16,
                          color: isDark
                              ? Colors.indigo.shade800
                              : Colors.orange.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFullSwitcher(
      BuildContext context, theme_service.ThemeService themeService) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Theme Mode Section
          _buildThemeModeSection(context, themeService),

          if (widget.showPresets) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Artistic Presets Section
            _buildArtisticPresetsSection(context, themeService),
          ],
        ],
      ),
    );
  }

  Widget _buildThemeModeSection(
      BuildContext context, theme_service.ThemeService themeService) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.palette,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Theme Mode',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildThemeModeButton(
              context,
              themeService,
              theme_service.ThemeMode.light,
              Icons.wb_sunny,
              'Light',
            ),
            const SizedBox(width: 8),
            _buildThemeModeButton(
              context,
              themeService,
              theme_service.ThemeMode.dark,
              Icons.nightlight_round,
              'Dark',
            ),
            const SizedBox(width: 8),
            _buildThemeModeButton(
              context,
              themeService,
              theme_service.ThemeMode.system,
              Icons.settings_system_daydream,
              'System',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeModeButton(
    BuildContext context,
    theme_service.ThemeService themeService,
    theme_service.ThemeMode mode,
    IconData icon,
    String label,
  ) {
    final theme = Theme.of(context);
    final isSelected = themeService.themeMode == mode;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => themeService.setThemeMode(mode),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArtisticPresetsSection(
      BuildContext context, theme_service.ThemeService themeService) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Artistic Themes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: theme_service.ArtisticThemePreset.values.map((preset) {
            return _buildPresetChip(context, themeService, preset);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPresetChip(
    BuildContext context,
    theme_service.ThemeService themeService,
    theme_service.ArtisticThemePreset preset,
  ) {
    final theme = Theme.of(context);
    final isSelected = themeService.artisticPreset == preset;
    final presetColors = _getPresetPreviewColors(preset);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => themeService.setArtisticPreset(preset),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient:
                  isSelected ? LinearGradient(colors: presetColors) : null,
              color: !isSelected ? theme.colorScheme.surface : null,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: presetColors),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  themeService.getArtisticPresetDisplayName(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color:
                        isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getPresetPreviewColors(
      theme_service.ArtisticThemePreset preset) {
    switch (preset) {
      case theme_service.ArtisticThemePreset.classic:
        return [SpinWishColors.primary500, SpinWishColors.secondary500];
      case theme_service.ArtisticThemePreset.neon:
        return [ArtisticThemePalettes.neonPink, ArtisticThemePalettes.neonBlue];
      case theme_service.ArtisticThemePreset.cyberpunk:
        return [
          ArtisticThemePalettes.cyberpunkRed,
          ArtisticThemePalettes.cyberpunkBlue
        ];
      case theme_service.ArtisticThemePreset.sunset:
        return [
          ArtisticThemePalettes.sunsetOrange,
          ArtisticThemePalettes.sunsetPink
        ];
      case theme_service.ArtisticThemePreset.ocean:
        return [
          ArtisticThemePalettes.oceanBlue,
          ArtisticThemePalettes.oceanTeal
        ];
      case theme_service.ArtisticThemePreset.forest:
        return [
          ArtisticThemePalettes.forestGreen,
          ArtisticThemePalettes.forestEmerald
        ];
      case theme_service.ArtisticThemePreset.cosmic:
        return [
          ArtisticThemePalettes.cosmicPurple,
          ArtisticThemePalettes.cosmicBlue
        ];
      case theme_service.ArtisticThemePreset.minimalist:
        return [
          ArtisticThemePalettes.minimalGray,
          ArtisticThemePalettes.minimalBeige
        ];
    }
  }
}
