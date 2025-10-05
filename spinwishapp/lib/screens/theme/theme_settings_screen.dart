import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spinwishapp/services/theme_service.dart';
import 'package:spinwishapp/widgets/theme_switcher_widget.dart';
import 'package:spinwishapp/widgets/particle_animation_widget.dart';
import 'package:spinwishapp/widgets/enhanced_card.dart';
import 'package:spinwishapp/utils/design_system.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;
  late AnimationController _contentAnimationController;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _contentAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final theme = Theme.of(context);

        return Scaffold(
          body: ParticleAnimationWidget(
            enabled: true,
            particleColor: theme.colorScheme.primary.withOpacity(0.3),
            particleCount: 30,
            child: MorphingBackgroundWidget(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
                theme.colorScheme.tertiary,
              ],
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(theme, themeService),
                  SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: _contentAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 50 * (1 - _contentAnimation.value)),
                          child: Opacity(
                            opacity: _contentAnimation.value,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildQuickToggleSection(theme, themeService),
                                  const SizedBox(height: 32),
                                  _buildThemeCustomizationSection(
                                      theme, themeService),
                                  const SizedBox(height: 32),
                                  _buildPreviewSection(theme, themeService),
                                  const SizedBox(height: 32),
                                  _buildAdvancedSettingsSection(
                                      theme, themeService),
                                  const SizedBox(height: 100),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _buildSliverAppBar(ThemeData theme, ThemeService themeService) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
      flexibleSpace: FlexibleSpaceBar(
        title: AnimatedBuilder(
          animation: _headerAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _headerAnimation.value,
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ).createShader(bounds),
                child: const Text(
                  'Theme Studio',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.8),
                theme.colorScheme.secondary.withOpacity(0.6),
                theme.colorScheme.tertiary.withOpacity(0.4),
              ],
            ),
          ),
          child: FloatingElementsWidget(
            enabled: true,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
              theme.colorScheme.tertiary,
            ],
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickToggleSection(ThemeData theme, ThemeService themeService) {
    return EnhancedCard(
      style: CardStyle.elevated,
      padding: EdgeInsets.all(SpinWishDesignSystem.spaceLG),
      margin: EdgeInsets.symmetric(horizontal: SpinWishDesignSystem.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.palette,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Theme Toggle',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: SpinWishDesignSystem.spaceLG),
          const Center(
            child: ThemeSwitcherWidget(
              showPresets: false,
              compact: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCustomizationSection(
      ThemeData theme, ThemeService themeService) {
    return EnhancedCard(
      style: CardStyle.hero,
      padding: EdgeInsets.all(SpinWishDesignSystem.spaceLG),
      margin: EdgeInsets.symmetric(horizontal: SpinWishDesignSystem.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.secondary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Artistic Themes',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: SpinWishDesignSystem.spaceLG),
          const ThemeSwitcherWidget(
            showPresets: true,
            compact: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(ThemeData theme, ThemeService themeService) {
    return EnhancedCard(
      style: CardStyle.glass,
      padding: EdgeInsets.all(SpinWishDesignSystem.spaceLG),
      margin: EdgeInsets.symmetric(horizontal: SpinWishDesignSystem.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.tertiary,
                      theme.colorScheme.primary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.preview,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Theme Preview',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: SpinWishDesignSystem.spaceLG),
          _buildThemePreviewCards(theme),
        ],
      ),
    );
  }

  Widget _buildThemePreviewCards(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(
                Icons.music_note,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.headphones,
                color: theme.colorScheme.primary,
                size: 40,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedSettingsSection(
      ThemeData theme, ThemeService themeService) {
    return EnhancedCard(
      style: CardStyle.interactive,
      padding: EdgeInsets.all(SpinWishDesignSystem.spaceLG),
      margin: EdgeInsets.symmetric(horizontal: SpinWishDesignSystem.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Advanced Settings',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Icon(
              Icons.refresh,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Reset to Default'),
            subtitle: const Text('Restore original theme settings'),
            onTap: () async {
              await themeService.resetToDefault();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Theme reset to default'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
