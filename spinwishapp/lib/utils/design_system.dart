import 'package:flutter/material.dart';

/// Enhanced Design System for SpinWish
/// Provides consistent spacing, shadows, radius, and visual styling
class SpinWishDesignSystem {
  // SPACING SYSTEM - Based on 8px grid
  static const double spaceXS = 4.0;   // 4px
  static const double spaceSM = 8.0;   // 8px
  static const double spaceMD = 16.0;  // 16px
  static const double spaceLG = 24.0;  // 24px
  static const double spaceXL = 32.0;  // 32px
  static const double space2XL = 48.0; // 48px
  static const double space3XL = 64.0; // 64px
  static const double space4XL = 96.0; // 96px

  // BORDER RADIUS SYSTEM
  static const double radiusXS = 6.0;   // Small elements
  static const double radiusSM = 12.0;  // Buttons, chips
  static const double radiusMD = 16.0;  // Cards, containers
  static const double radiusLG = 24.0;  // Large cards
  static const double radiusXL = 32.0;  // Hero elements
  static const double radiusFull = 999.0; // Fully rounded

  // ELEVATION SYSTEM
  static const double elevationNone = 0.0;
  static const double elevationSM = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationLG = 8.0;
  static const double elevationXL = 16.0;
  static const double elevation2XL = 24.0;

  // SHADOW SYSTEM - Enhanced for better visual depth
  static List<BoxShadow> shadowSM(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: color.withOpacity(0.04),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> shadowMD(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.12),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: color.withOpacity(0.06),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowLG(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: color.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowXL(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.18),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: color.withOpacity(0.10),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> shadow2XL(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.20),
      blurRadius: 32,
      offset: const Offset(0, 16),
    ),
    BoxShadow(
      color: color.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // GLOW EFFECTS - For interactive elements
  static List<BoxShadow> glowSM(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 0),
    ),
  ];

  static List<BoxShadow> glowMD(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.4),
      blurRadius: 16,
      offset: const Offset(0, 0),
    ),
  ];

  static List<BoxShadow> glowLG(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.5),
      blurRadius: 24,
      offset: const Offset(0, 0),
    ),
  ];

  // NEUMORPHISM SHADOWS
  static List<BoxShadow> neumorphismLight(Color backgroundColor) => [
    BoxShadow(
      color: Colors.white.withOpacity(0.7),
      blurRadius: 8,
      offset: const Offset(-4, -4),
    ),
    BoxShadow(
      color: backgroundColor.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(4, 4),
    ),
  ];

  static List<BoxShadow> neumorphismDark(Color backgroundColor) => [
    BoxShadow(
      color: backgroundColor.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(-4, -4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 8,
      offset: const Offset(4, 4),
    ),
  ];

  // BUTTON STYLES
  static BoxDecoration primaryButtonDecoration(ThemeData theme, {bool isPressed = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.primary,
          theme.colorScheme.primary.withOpacity(0.8),
        ],
      ),
      borderRadius: BorderRadius.circular(radiusSM),
      boxShadow: isPressed 
        ? shadowSM(theme.colorScheme.primary)
        : shadowMD(theme.colorScheme.primary),
    );
  }

  static BoxDecoration secondaryButtonDecoration(ThemeData theme, {bool isPressed = false}) {
    return BoxDecoration(
      color: theme.colorScheme.surface,
      border: Border.all(
        color: theme.colorScheme.outline.withOpacity(0.3),
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(radiusSM),
      boxShadow: isPressed 
        ? shadowSM(theme.colorScheme.shadow)
        : shadowMD(theme.colorScheme.shadow),
    );
  }

  static BoxDecoration floatingButtonDecoration(ThemeData theme) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.primary,
          theme.colorScheme.secondary,
        ],
      ),
      borderRadius: BorderRadius.circular(radiusFull),
      boxShadow: [
        ...shadowLG(theme.colorScheme.primary),
        ...glowMD(theme.colorScheme.primary),
      ],
    );
  }

  // CARD STYLES
  static BoxDecoration cardDecoration(ThemeData theme, {bool isElevated = true}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.surface,
          theme.colorScheme.surfaceContainer.withOpacity(0.8),
        ],
      ),
      borderRadius: BorderRadius.circular(radiusLG),
      border: Border.all(
        color: theme.colorScheme.outline.withOpacity(0.1),
        width: 1,
      ),
      boxShadow: isElevated 
        ? shadowLG(theme.colorScheme.shadow)
        : shadowMD(theme.colorScheme.shadow),
    );
  }

  static BoxDecoration heroCardDecoration(ThemeData theme) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.surface,
          theme.colorScheme.surfaceContainer,
        ],
      ),
      borderRadius: BorderRadius.circular(radiusXL),
      border: Border.all(
        color: theme.colorScheme.outline.withOpacity(0.15),
        width: 1.5,
      ),
      boxShadow: [
        ...shadow2XL(theme.colorScheme.shadow),
        ...glowSM(theme.colorScheme.primary),
      ],
    );
  }

  static BoxDecoration glassCardDecoration(ThemeData theme) {
    return BoxDecoration(
      color: theme.colorScheme.surface.withOpacity(0.7),
      borderRadius: BorderRadius.circular(radiusLG),
      border: Border.all(
        color: theme.colorScheme.outline.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: shadowXL(theme.colorScheme.shadow),
    );
  }

  // CONTAINER STYLES
  static BoxDecoration containerDecoration(ThemeData theme, {bool isInteractive = false}) {
    return BoxDecoration(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(radiusMD),
      border: Border.all(
        color: theme.colorScheme.outline.withOpacity(0.1),
        width: 1,
      ),
      boxShadow: isInteractive 
        ? shadowMD(theme.colorScheme.shadow)
        : shadowSM(theme.colorScheme.shadow),
    );
  }

  // CHIP STYLES
  static BoxDecoration chipDecoration(ThemeData theme, {bool isSelected = false}) {
    return BoxDecoration(
      gradient: isSelected 
        ? LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          )
        : null,
      color: isSelected ? null : theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(radiusFull),
      border: Border.all(
        color: isSelected 
          ? Colors.transparent
          : theme.colorScheme.outline.withOpacity(0.3),
        width: 1,
      ),
      boxShadow: isSelected 
        ? glowSM(theme.colorScheme.primary)
        : shadowSM(theme.colorScheme.shadow),
    );
  }

  // PADDING HELPERS
  static EdgeInsets paddingXS = const EdgeInsets.all(spaceXS);
  static EdgeInsets paddingSM = const EdgeInsets.all(spaceSM);
  static EdgeInsets paddingMD = const EdgeInsets.all(spaceMD);
  static EdgeInsets paddingLG = const EdgeInsets.all(spaceLG);
  static EdgeInsets paddingXL = const EdgeInsets.all(spaceXL);

  static EdgeInsets paddingHorizontalSM = const EdgeInsets.symmetric(horizontal: spaceSM);
  static EdgeInsets paddingHorizontalMD = const EdgeInsets.symmetric(horizontal: spaceMD);
  static EdgeInsets paddingHorizontalLG = const EdgeInsets.symmetric(horizontal: spaceLG);

  static EdgeInsets paddingVerticalSM = const EdgeInsets.symmetric(vertical: spaceSM);
  static EdgeInsets paddingVerticalMD = const EdgeInsets.symmetric(vertical: spaceMD);
  static EdgeInsets paddingVerticalLG = const EdgeInsets.symmetric(vertical: spaceLG);

  // MARGIN HELPERS
  static EdgeInsets marginXS = const EdgeInsets.all(spaceXS);
  static EdgeInsets marginSM = const EdgeInsets.all(spaceSM);
  static EdgeInsets marginMD = const EdgeInsets.all(spaceMD);
  static EdgeInsets marginLG = const EdgeInsets.all(spaceLG);
  static EdgeInsets marginXL = const EdgeInsets.all(spaceXL);

  // SIZED BOX HELPERS
  static Widget get gapXS => const SizedBox(height: spaceXS, width: spaceXS);
  static Widget get gapSM => const SizedBox(height: spaceSM, width: spaceSM);
  static Widget get gapMD => const SizedBox(height: spaceMD, width: spaceMD);
  static Widget get gapLG => const SizedBox(height: spaceLG, width: spaceLG);
  static Widget get gapXL => const SizedBox(height: spaceXL, width: spaceXL);

  static Widget get gapVerticalXS => const SizedBox(height: spaceXS);
  static Widget get gapVerticalSM => const SizedBox(height: spaceSM);
  static Widget get gapVerticalMD => const SizedBox(height: spaceMD);
  static Widget get gapVerticalLG => const SizedBox(height: spaceLG);
  static Widget get gapVerticalXL => const SizedBox(height: spaceXL);

  static Widget get gapHorizontalXS => const SizedBox(width: spaceXS);
  static Widget get gapHorizontalSM => const SizedBox(width: spaceSM);
  static Widget get gapHorizontalMD => const SizedBox(width: spaceMD);
  static Widget get gapHorizontalLG => const SizedBox(width: spaceLG);
  static Widget get gapHorizontalXL => const SizedBox(width: spaceXL);
}
