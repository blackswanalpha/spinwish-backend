import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spinwishapp/services/theme_service.dart';

// SpinWish Brand Colors - Enhanced Artistic Design System
class SpinWishColors {
  // Primary Purple - Spinwish Purple (#6366f1)
  static const primary50 = Color(0xFFF0F0FF);
  static const primary100 = Color(0xFFE5E5FF);
  static const primary200 = Color(0xFFD1D1FF);
  static const primary300 = Color(0xFFB3B3FF);
  static const primary400 = Color(0xFF8A8AFF);
  static const primary500 = Color(0xFF6366F1); // Primary Spinwish Purple
  static const primary600 = Color(0xFF5A5AD6);
  static const primary700 = Color(0xFF4F4FB8);
  static const primary800 = Color(0xFF424294);
  static const primary900 = Color(0xFF383876);

  // Secondary Blue - Electric Blue (#3b82f6)
  static const secondary50 = Color(0xFFEFF6FF);
  static const secondary100 = Color(0xFFDBEAFE);
  static const secondary200 = Color(0xFFBFDBFE);
  static const secondary300 = Color(0xFF93C5FD);
  static const secondary400 = Color(0xFF60A5FA);
  static const secondary500 = Color(0xFF3B82F6); // Electric Blue
  static const secondary600 = Color(0xFF2563EB);
  static const secondary700 = Color(0xFF1D4ED8);
  static const secondary800 = Color(0xFF1E40AF);
  static const secondary900 = Color(0xFF1E3A8A);

  // Status Colors
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // Dark Theme Colors - Nightclub Optimized
  static const darkPrimary = Color(0xFF1F2937);
  static const darkSecondary = Color(0xFF374151);
  static const darkAccent = Color(0xFF4B5563);
  static const darkSurface = Color(0xFF111827);
  static const darkBackground = Color(0xFF0F0F23);

  // Light Theme Colors
  static const lightSurface = Color(0xFFFAFBFC);
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightOnSurface = Color(0xFF1A1B23);

  // Common Colors
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const transparent = Color(0x00000000);

  // Glass Morphism Colors
  static const glassBackground = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x33FFFFFF);

  // Gradient Colors for Effects
  static const gradientStart = primary500;
  static const gradientEnd = secondary500;
}

// Artistic Theme Palettes for Different Presets
class ArtisticThemePalettes {
  // Neon Theme Colors
  static const neonPink = Color(0xFFFF0080);
  static const neonBlue = Color(0xFF00FFFF);
  static const neonGreen = Color(0xFF00FF41);
  static const neonPurple = Color(0xFF8000FF);
  static const neonYellow = Color(0xFFFFFF00);

  // Cyberpunk Theme Colors
  static const cyberpunkRed = Color(0xFFFF073A);
  static const cyberpunkBlue = Color(0xFF0ABDC6);
  static const cyberpunkPurple = Color(0xFF711C91);
  static const cyberpunkGold = Color(0xFFEA00D9);

  // Sunset Theme Colors
  static const sunsetOrange = Color(0xFFFF6B35);
  static const sunsetPink = Color(0xFFFF8E53);
  static const sunsetPurple = Color(0xFF7209B7);
  static const sunsetYellow = Color(0xFFFFC93C);

  // Ocean Theme Colors
  static const oceanBlue = Color(0xFF006A6B);
  static const oceanTeal = Color(0xFF0D7377);
  static const oceanAqua = Color(0xFF14A085);
  static const oceanMint = Color(0xFF7FCDCD);

  // Forest Theme Colors
  static const forestGreen = Color(0xFF2D5016);
  static const forestEmerald = Color(0xFF61A5C2);
  static const forestSage = Color(0xFF8FBC8F);
  static const forestMoss = Color(0xFF355E3B);

  // Cosmic Theme Colors
  static const cosmicPurple = Color(0xFF4A0E4E);
  static const cosmicBlue = Color(0xFF0F3460);
  static const cosmicPink = Color(0xFFE94560);
  static const cosmicGold = Color(0xFFF5F5DC);

  // Minimalist Theme Colors
  static const minimalGray = Color(0xFF6C7B7F);
  static const minimalBeige = Color(0xFFF5F5DC);
  static const minimalBlack = Color(0xFF2C2C2C);
  static const minimalWhite = Color(0xFFFAFAFA);
}

// Custom Theme Extensions for SpinWish Design System
class SpinWishThemeExtension extends ThemeExtension<SpinWishThemeExtension> {
  final LinearGradient primaryGradient;
  final LinearGradient backgroundGradient;
  final BoxDecoration glassDecoration;
  final TextStyle gradientTextStyle;

  const SpinWishThemeExtension({
    required this.primaryGradient,
    required this.backgroundGradient,
    required this.glassDecoration,
    required this.gradientTextStyle,
  });

  @override
  SpinWishThemeExtension copyWith({
    LinearGradient? primaryGradient,
    LinearGradient? backgroundGradient,
    BoxDecoration? glassDecoration,
    TextStyle? gradientTextStyle,
  }) {
    return SpinWishThemeExtension(
      primaryGradient: primaryGradient ?? this.primaryGradient,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      glassDecoration: glassDecoration ?? this.glassDecoration,
      gradientTextStyle: gradientTextStyle ?? this.gradientTextStyle,
    );
  }

  @override
  SpinWishThemeExtension lerp(
    ThemeExtension<SpinWishThemeExtension>? other,
    double t,
  ) {
    if (other is! SpinWishThemeExtension) {
      return this;
    }
    return SpinWishThemeExtension(
      primaryGradient:
          LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      backgroundGradient:
          LinearGradient.lerp(backgroundGradient, other.backgroundGradient, t)!,
      glassDecoration:
          BoxDecoration.lerp(glassDecoration, other.glassDecoration, t)!,
      gradientTextStyle:
          TextStyle.lerp(gradientTextStyle, other.gradientTextStyle, t)!,
    );
  }
}

class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 24.0;
  static const double headlineSmall = 22.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 18.0;
  static const double titleSmall = 16.0;
  static const double labelLarge = 16.0;
  static const double labelMedium = 14.0;
  static const double labelSmall = 12.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: SpinWishColors.primary500,
        onPrimary: SpinWishColors.white,
        primaryContainer: SpinWishColors.primary100,
        onPrimaryContainer: SpinWishColors.primary900,
        secondary: SpinWishColors.secondary500,
        onSecondary: SpinWishColors.white,
        tertiary: SpinWishColors.secondary600,
        onTertiary: SpinWishColors.white,
        error: SpinWishColors.error,
        onError: SpinWishColors.white,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        inversePrimary: SpinWishColors.primary300,
        shadow: SpinWishColors.black,
        surface: SpinWishColors.lightSurface,
        onSurface: SpinWishColors.lightOnSurface,
        surfaceContainer: SpinWishColors.primary50,
      ),
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
        backgroundColor: SpinWishColors.lightSurface,
        foregroundColor: SpinWishColors.primary900,
        elevation: 0,
        surfaceTintColor: SpinWishColors.transparent,
      ),
      extensions: <ThemeExtension<dynamic>>[
        SpinWishThemeExtension(
          primaryGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [SpinWishColors.primary500, SpinWishColors.secondary500],
          ),
          backgroundGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              SpinWishColors.primary500.withOpacity(0.1),
              SpinWishColors.secondary500.withOpacity(0.05),
              SpinWishColors.lightSurface,
            ],
          ),
          glassDecoration: BoxDecoration(
            color: SpinWishColors.glassBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SpinWishColors.glassBorder),
          ),
          gradientTextStyle: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [
                  SpinWishColors.primary500,
                  SpinWishColors.secondary500,
                ],
              ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
          ),
        ),
      ],
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: FontSizes.displayLarge,
          fontWeight: FontWeight.w800,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: FontSizes.displayMedium,
          fontWeight: FontWeight.w700,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: FontSizes.displaySmall,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: FontSizes.headlineLarge,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: FontSizes.headlineMedium,
          fontWeight: FontWeight.w500,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: FontSizes.headlineSmall,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: FontSizes.titleLarge,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: FontSizes.titleMedium,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: FontSizes.titleSmall,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: FontSizes.labelLarge,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: FontSizes.labelMedium,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: FontSizes.labelSmall,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: FontSizes.bodyLarge,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: FontSizes.bodyMedium,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: FontSizes.bodySmall,
          fontWeight: FontWeight.normal,
        ),
      ),
    );

ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: SpinWishColors.primary400,
        onPrimary: SpinWishColors.primary900,
        primaryContainer: SpinWishColors.primary800,
        onPrimaryContainer: SpinWishColors.primary100,
        secondary: SpinWishColors.secondary400,
        onSecondary: SpinWishColors.secondary900,
        tertiary: SpinWishColors.secondary300,
        onTertiary: SpinWishColors.secondary900,
        error: SpinWishColors.error,
        onError: SpinWishColors.white,
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        inversePrimary: SpinWishColors.primary500,
        shadow: SpinWishColors.black,
        surface: SpinWishColors.darkBackground,
        onSurface: Color(0xFFE2E8F0),
        surfaceContainer: SpinWishColors.darkSecondary,
        // Nightclub-optimized surface variants
        surfaceContainerHighest: SpinWishColors.darkPrimary,
      ),
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
        backgroundColor: SpinWishColors.darkSecondary,
        foregroundColor: SpinWishColors.primary100,
        elevation: 0,
        surfaceTintColor: SpinWishColors.transparent,
      ),
      extensions: <ThemeExtension<dynamic>>[
        SpinWishThemeExtension(
          primaryGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [SpinWishColors.primary400, SpinWishColors.secondary400],
          ),
          backgroundGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [SpinWishColors.darkPrimary, SpinWishColors.darkBackground],
          ),
          glassDecoration: BoxDecoration(
            color: SpinWishColors.glassBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SpinWishColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: SpinWishColors.primary500.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          gradientTextStyle: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [
                  SpinWishColors.primary400,
                  SpinWishColors.secondary400,
                ],
              ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
          ),
        ),
      ],
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: FontSizes.displayLarge,
          fontWeight: FontWeight.w800,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: FontSizes.displayMedium,
          fontWeight: FontWeight.w700,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: FontSizes.displaySmall,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: FontSizes.headlineLarge,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: FontSizes.headlineMedium,
          fontWeight: FontWeight.w500,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: FontSizes.headlineSmall,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: FontSizes.titleLarge,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: FontSizes.titleMedium,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: FontSizes.titleSmall,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: FontSizes.labelLarge,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: FontSizes.labelMedium,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: FontSizes.labelSmall,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: FontSizes.bodyLarge,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: FontSizes.bodyMedium,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: FontSizes.bodySmall,
          fontWeight: FontWeight.normal,
        ),
      ),
    );

// Helper extension to easily access SpinWish theme extensions
extension SpinWishThemeData on ThemeData {
  SpinWishThemeExtension get spinwish => extension<SpinWishThemeExtension>()!;
}

// Helper extension for accessing theme colors more easily
extension SpinWishColorScheme on ColorScheme {
  Color get primaryGradientStart => SpinWishColors.primary500;
  Color get primaryGradientEnd => SpinWishColors.secondary500;
  Color get glassBackground => SpinWishColors.glassBackground;
  Color get glassBorder => SpinWishColors.glassBorder;
  Color get success => SpinWishColors.success;
  Color get warning => SpinWishColors.warning;
}

// Artistic Theme Generator
class ArtisticThemeGenerator {
  static ThemeData generateTheme({
    required ArtisticThemePreset preset,
    required bool isDark,
  }) {
    final baseTheme = isDark ? darkTheme : lightTheme;
    final colors = _getPresetColors(preset, isDark);

    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: colors.primary,
        secondary: colors.secondary,
        tertiary: colors.tertiary,
        surface: colors.surface,
        background: colors.background,
      ),
      extensions: [
        SpinWishThemeExtension(
          primaryGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors.gradientColors,
          ),
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors.backgroundGradient,
          ),
          glassDecoration: BoxDecoration(
            color: colors.glassColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          gradientTextStyle: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: colors.gradientColors,
              ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
          ),
        ),
      ],
    );
  }

  static _PresetColors _getPresetColors(
      ArtisticThemePreset preset, bool isDark) {
    switch (preset) {
      case ArtisticThemePreset.classic:
        return _PresetColors(
          primary: SpinWishColors.primary500,
          secondary: SpinWishColors.secondary500,
          tertiary: SpinWishColors.secondary600,
          surface: isDark
              ? SpinWishColors.darkBackground
              : SpinWishColors.lightSurface,
          background: isDark
              ? SpinWishColors.darkBackground
              : SpinWishColors.lightBackground,
          gradientColors: [
            SpinWishColors.primary500,
            SpinWishColors.secondary500
          ],
          backgroundGradient: isDark
              ? [SpinWishColors.darkPrimary, SpinWishColors.darkBackground]
              : [
                  SpinWishColors.primary500.withOpacity(0.1),
                  SpinWishColors.lightSurface
                ],
          glassColor: SpinWishColors.glassBackground,
          glassBorder: SpinWishColors.glassBorder,
        );

      case ArtisticThemePreset.neon:
        return _PresetColors(
          primary: ArtisticThemePalettes.neonPink,
          secondary: ArtisticThemePalettes.neonBlue,
          tertiary: ArtisticThemePalettes.neonGreen,
          surface: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F8F8),
          background:
              isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
          gradientColors: [
            ArtisticThemePalettes.neonPink,
            ArtisticThemePalettes.neonBlue,
            ArtisticThemePalettes.neonGreen
          ],
          backgroundGradient: isDark
              ? [const Color(0xFF0A0A0A), const Color(0xFF000000)]
              : [const Color(0xFFF8F8F8), const Color(0xFFFFFFFF)],
          glassColor:
              isDark ? const Color(0x1AFF0080) : const Color(0x1A00FFFF),
          glassBorder: isDark
              ? ArtisticThemePalettes.neonPink.withOpacity(0.3)
              : ArtisticThemePalettes.neonBlue.withOpacity(0.3),
        );

      case ArtisticThemePreset.cyberpunk:
        return _PresetColors(
          primary: ArtisticThemePalettes.cyberpunkRed,
          secondary: ArtisticThemePalettes.cyberpunkBlue,
          tertiary: ArtisticThemePalettes.cyberpunkPurple,
          surface: isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
          background:
              isDark ? const Color(0xFF010409) : const Color(0xFFFFFFFF),
          gradientColors: [
            ArtisticThemePalettes.cyberpunkRed,
            ArtisticThemePalettes.cyberpunkBlue
          ],
          backgroundGradient: isDark
              ? [const Color(0xFF0D1117), const Color(0xFF010409)]
              : [const Color(0xFFF6F8FA), const Color(0xFFFFFFFF)],
          glassColor:
              isDark ? const Color(0x1AFF073A) : const Color(0x1A0ABDC6),
          glassBorder: ArtisticThemePalettes.cyberpunkRed.withOpacity(0.3),
        );

      case ArtisticThemePreset.sunset:
        return _PresetColors(
          primary: ArtisticThemePalettes.sunsetOrange,
          secondary: ArtisticThemePalettes.sunsetPink,
          tertiary: ArtisticThemePalettes.sunsetPurple,
          surface: isDark ? const Color(0xFF1A0E0A) : const Color(0xFFFFF8F0),
          background:
              isDark ? const Color(0xFF0F0705) : const Color(0xFFFFFFFF),
          gradientColors: [
            ArtisticThemePalettes.sunsetOrange,
            ArtisticThemePalettes.sunsetPink,
            ArtisticThemePalettes.sunsetPurple
          ],
          backgroundGradient: isDark
              ? [const Color(0xFF1A0E0A), const Color(0xFF0F0705)]
              : [const Color(0xFFFFF8F0), const Color(0xFFFFFFFF)],
          glassColor:
              isDark ? const Color(0x1AFF6B35) : const Color(0x1AFF8E53),
          glassBorder: ArtisticThemePalettes.sunsetOrange.withOpacity(0.3),
        );

      case ArtisticThemePreset.ocean:
        return _PresetColors(
          primary: ArtisticThemePalettes.oceanBlue,
          secondary: ArtisticThemePalettes.oceanTeal,
          tertiary: ArtisticThemePalettes.oceanAqua,
          surface: isDark ? const Color(0xFF0A1214) : const Color(0xFFF0F9FF),
          background:
              isDark ? const Color(0xFF050B0D) : const Color(0xFFFFFFFF),
          gradientColors: [
            ArtisticThemePalettes.oceanBlue,
            ArtisticThemePalettes.oceanTeal,
            ArtisticThemePalettes.oceanAqua
          ],
          backgroundGradient: isDark
              ? [const Color(0xFF0A1214), const Color(0xFF050B0D)]
              : [const Color(0xFFF0F9FF), const Color(0xFFFFFFFF)],
          glassColor:
              isDark ? const Color(0x1A006A6B) : const Color(0x1A14A085),
          glassBorder: ArtisticThemePalettes.oceanBlue.withOpacity(0.3),
        );

      case ArtisticThemePreset.forest:
        return _PresetColors(
          primary: ArtisticThemePalettes.forestGreen,
          secondary: ArtisticThemePalettes.forestEmerald,
          tertiary: ArtisticThemePalettes.forestSage,
          surface: isDark ? const Color(0xFF0A0F0A) : const Color(0xFFF0FFF0),
          background:
              isDark ? const Color(0xFF050805) : const Color(0xFFFFFFFF),
          gradientColors: [
            ArtisticThemePalettes.forestGreen,
            ArtisticThemePalettes.forestEmerald
          ],
          backgroundGradient: isDark
              ? [const Color(0xFF0A0F0A), const Color(0xFF050805)]
              : [const Color(0xFFF0FFF0), const Color(0xFFFFFFFF)],
          glassColor:
              isDark ? const Color(0x1A2D5016) : const Color(0x1A8FBC8F),
          glassBorder: ArtisticThemePalettes.forestGreen.withOpacity(0.3),
        );

      case ArtisticThemePreset.cosmic:
        return _PresetColors(
          primary: ArtisticThemePalettes.cosmicPurple,
          secondary: ArtisticThemePalettes.cosmicBlue,
          tertiary: ArtisticThemePalettes.cosmicPink,
          surface: isDark ? const Color(0xFF0F0A14) : const Color(0xFFF8F0FF),
          background:
              isDark ? const Color(0xFF08050A) : const Color(0xFFFFFFFF),
          gradientColors: [
            ArtisticThemePalettes.cosmicPurple,
            ArtisticThemePalettes.cosmicBlue,
            ArtisticThemePalettes.cosmicPink
          ],
          backgroundGradient: isDark
              ? [const Color(0xFF0F0A14), const Color(0xFF08050A)]
              : [const Color(0xFFF8F0FF), const Color(0xFFFFFFFF)],
          glassColor:
              isDark ? const Color(0x1A4A0E4E) : const Color(0x1AE94560),
          glassBorder: ArtisticThemePalettes.cosmicPurple.withOpacity(0.3),
        );

      case ArtisticThemePreset.minimalist:
        return _PresetColors(
          primary: ArtisticThemePalettes.minimalGray,
          secondary: ArtisticThemePalettes.minimalBeige,
          tertiary: ArtisticThemePalettes.minimalBlack,
          surface: isDark
              ? const Color(0xFF1A1A1A)
              : ArtisticThemePalettes.minimalWhite,
          background:
              isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFFFFFF),
          gradientColors: [
            ArtisticThemePalettes.minimalGray,
            ArtisticThemePalettes.minimalBeige
          ],
          backgroundGradient: isDark
              ? [const Color(0xFF1A1A1A), const Color(0xFF0F0F0F)]
              : [ArtisticThemePalettes.minimalWhite, const Color(0xFFFFFFFF)],
          glassColor:
              isDark ? const Color(0x1A6C7B7F) : const Color(0x1AF5F5DC),
          glassBorder: ArtisticThemePalettes.minimalGray.withOpacity(0.2),
        );
    }
  }
}

class _PresetColors {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color surface;
  final Color background;
  final List<Color> gradientColors;
  final List<Color> backgroundGradient;
  final Color glassColor;
  final Color glassBorder;

  const _PresetColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.surface,
    required this.background,
    required this.gradientColors,
    required this.backgroundGradient,
    required this.glassColor,
    required this.glassBorder,
  });
}
