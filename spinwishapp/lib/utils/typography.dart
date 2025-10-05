import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SpinWish Typography System
/// Provides consistent Inter font usage across the entire application
/// with predefined text styles for different use cases.
class SpinWishTypography {
  // Private constructor to prevent instantiation
  SpinWishTypography._();

  /// Base Inter font family
  static const String fontFamily = 'Inter';

  // DISPLAY STYLES - For large, prominent text
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 57.0,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.25,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 45.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      );

  static TextStyle get displaySmall => GoogleFonts.inter(
        fontSize: 36.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  // HEADLINE STYLES - For section headers and important text
  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 32.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 28.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  static TextStyle get headlineSmall => GoogleFonts.inter(
        fontSize: 24.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  // TITLE STYLES - For card titles, dialog headers, etc.
  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 22.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      );

  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  // LABEL STYLES - For buttons, tabs, form labels
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  // BODY STYLES - For main content, descriptions, etc.
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      );

  // CUSTOM STYLES - SpinWish specific text styles
  
  /// For app branding and logo text
  static TextStyle get brandTitle => GoogleFonts.inter(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  /// For DJ names and artist names
  static TextStyle get artistName => GoogleFonts.inter(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  /// For song titles
  static TextStyle get songTitle => GoogleFonts.inter(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  /// For song metadata (duration, genre, etc.)
  static TextStyle get songMetadata => GoogleFonts.inter(
        fontSize: 13.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: Colors.grey[600],
      );

  /// For button text
  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  /// For navigation labels
  static TextStyle get navigationLabel => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  /// For form field labels
  static TextStyle get fieldLabel => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  /// For error messages
  static TextStyle get errorText => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: Colors.red[600],
      );

  /// For success messages
  static TextStyle get successText => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: Colors.green[600],
      );

  /// For captions and small descriptive text
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      );

  /// For overline text (small labels above content)
  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 10.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
      );

  // UTILITY METHODS

  /// Apply color to any text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply opacity to any text style
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withOpacity(opacity));
  }

  /// Apply custom font weight to any text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Apply custom font size to any text style
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Apply custom letter spacing to any text style
  static TextStyle withLetterSpacing(TextStyle style, double letterSpacing) {
    return style.copyWith(letterSpacing: letterSpacing);
  }

  /// Apply text decoration (underline, strikethrough, etc.)
  static TextStyle withDecoration(TextStyle style, TextDecoration decoration) {
    return style.copyWith(decoration: decoration);
  }

  /// Create a responsive text style based on screen size
  static TextStyle responsive(BuildContext context, TextStyle baseStyle, {
    double? mobileScale,
    double? tabletScale,
    double? desktopScale,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    double scale = 1.0;

    if (screenWidth < 600) {
      // Mobile
      scale = mobileScale ?? 0.9;
    } else if (screenWidth < 1200) {
      // Tablet
      scale = tabletScale ?? 1.0;
    } else {
      // Desktop
      scale = desktopScale ?? 1.1;
    }

    return baseStyle.copyWith(fontSize: (baseStyle.fontSize ?? 14.0) * scale);
  }
}
