import 'package:flutter/material.dart';
import 'package:spinwishapp/services/theme_service.dart';
import 'package:spinwishapp/theme.dart';

class ThemePresetsManager {
  static const Map<ArtisticThemePreset, ThemePresetData> _presets = {
    ArtisticThemePreset.classic: ThemePresetData(
      name: 'Classic SpinWish',
      description: 'The original SpinWish experience with purple gradients',
      icon: Icons.star,
      primaryColor: SpinWishColors.primary500,
      secondaryColor: SpinWishColors.secondary500,
      category: ThemeCategory.elegant,
      tags: ['original', 'purple', 'elegant'],
    ),
    
    ArtisticThemePreset.neon: ThemePresetData(
      name: 'Neon Nights',
      description: 'Electric colors perfect for nightclub vibes',
      icon: Icons.flash_on,
      primaryColor: ArtisticThemePalettes.neonPink,
      secondaryColor: ArtisticThemePalettes.neonBlue,
      category: ThemeCategory.vibrant,
      tags: ['neon', 'electric', 'nightclub', 'vibrant'],
    ),
    
    ArtisticThemePreset.cyberpunk: ThemePresetData(
      name: 'Cyberpunk',
      description: 'Futuristic red and blue for the digital age',
      icon: Icons.computer,
      primaryColor: ArtisticThemePalettes.cyberpunkRed,
      secondaryColor: ArtisticThemePalettes.cyberpunkBlue,
      category: ThemeCategory.futuristic,
      tags: ['cyberpunk', 'futuristic', 'red', 'blue'],
    ),
    
    ArtisticThemePreset.sunset: ThemePresetData(
      name: 'Sunset Vibes',
      description: 'Warm oranges and pinks like a beautiful sunset',
      icon: Icons.wb_sunny,
      primaryColor: ArtisticThemePalettes.sunsetOrange,
      secondaryColor: ArtisticThemePalettes.sunsetPink,
      category: ThemeCategory.warm,
      tags: ['sunset', 'warm', 'orange', 'pink'],
    ),
    
    ArtisticThemePreset.ocean: ThemePresetData(
      name: 'Ocean Depths',
      description: 'Cool blues and teals inspired by the deep sea',
      icon: Icons.waves,
      primaryColor: ArtisticThemePalettes.oceanBlue,
      secondaryColor: ArtisticThemePalettes.oceanTeal,
      category: ThemeCategory.cool,
      tags: ['ocean', 'blue', 'teal', 'cool'],
    ),
    
    ArtisticThemePreset.forest: ThemePresetData(
      name: 'Forest Green',
      description: 'Natural greens that bring peace and tranquility',
      icon: Icons.forest,
      primaryColor: ArtisticThemePalettes.forestGreen,
      secondaryColor: ArtisticThemePalettes.forestEmerald,
      category: ThemeCategory.natural,
      tags: ['forest', 'green', 'natural', 'peaceful'],
    ),
    
    ArtisticThemePreset.cosmic: ThemePresetData(
      name: 'Cosmic Purple',
      description: 'Deep purples and blues from outer space',
      icon: Icons.star_border,
      primaryColor: ArtisticThemePalettes.cosmicPurple,
      secondaryColor: ArtisticThemePalettes.cosmicBlue,
      category: ThemeCategory.mystical,
      tags: ['cosmic', 'purple', 'space', 'mystical'],
    ),
    
    ArtisticThemePreset.minimalist: ThemePresetData(
      name: 'Minimalist',
      description: 'Clean and simple with subtle grays and beiges',
      icon: Icons.minimize,
      primaryColor: ArtisticThemePalettes.minimalGray,
      secondaryColor: ArtisticThemePalettes.minimalBeige,
      category: ThemeCategory.minimal,
      tags: ['minimal', 'clean', 'simple', 'gray'],
    ),
  };

  // Get preset data for a specific theme
  static ThemePresetData getPresetData(ArtisticThemePreset preset) {
    return _presets[preset]!;
  }

  // Get all presets
  static Map<ArtisticThemePreset, ThemePresetData> getAllPresets() {
    return Map.from(_presets);
  }

  // Get presets by category
  static Map<ArtisticThemePreset, ThemePresetData> getPresetsByCategory(
      ThemeCategory category) {
    return Map.fromEntries(
      _presets.entries.where((entry) => entry.value.category == category),
    );
  }

  // Search presets by tag
  static Map<ArtisticThemePreset, ThemePresetData> searchPresetsByTag(
      String tag) {
    return Map.fromEntries(
      _presets.entries.where(
        (entry) => entry.value.tags.any(
          (presetTag) => presetTag.toLowerCase().contains(tag.toLowerCase()),
        ),
      ),
    );
  }

  // Get recommended presets based on time of day
  static List<ArtisticThemePreset> getRecommendedPresets() {
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 12) {
      // Morning: bright and energetic
      return [
        ArtisticThemePreset.sunset,
        ArtisticThemePreset.ocean,
        ArtisticThemePreset.minimalist,
      ];
    } else if (hour >= 12 && hour < 18) {
      // Afternoon: balanced and productive
      return [
        ArtisticThemePreset.classic,
        ArtisticThemePreset.forest,
        ArtisticThemePreset.ocean,
      ];
    } else if (hour >= 18 && hour < 22) {
      // Evening: warm and relaxing
      return [
        ArtisticThemePreset.sunset,
        ArtisticThemePreset.cosmic,
        ArtisticThemePreset.forest,
      ];
    } else {
      // Night: dark and vibrant
      return [
        ArtisticThemePreset.neon,
        ArtisticThemePreset.cyberpunk,
        ArtisticThemePreset.cosmic,
      ];
    }
  }

  // Get preset preview colors for UI display
  static List<Color> getPresetPreviewColors(ArtisticThemePreset preset) {
    final data = _presets[preset]!;
    return [data.primaryColor, data.secondaryColor];
  }

  // Check if preset is suitable for dark mode
  static bool isPresetSuitableForDarkMode(ArtisticThemePreset preset) {
    switch (preset) {
      case ArtisticThemePreset.neon:
      case ArtisticThemePreset.cyberpunk:
      case ArtisticThemePreset.cosmic:
        return true;
      case ArtisticThemePreset.minimalist:
      case ArtisticThemePreset.sunset:
      case ArtisticThemePreset.ocean:
      case ArtisticThemePreset.forest:
      case ArtisticThemePreset.classic:
        return false;
    }
  }

  // Get complementary preset for current one
  static ArtisticThemePreset? getComplementaryPreset(ArtisticThemePreset current) {
    switch (current) {
      case ArtisticThemePreset.classic:
        return ArtisticThemePreset.neon;
      case ArtisticThemePreset.neon:
        return ArtisticThemePreset.minimalist;
      case ArtisticThemePreset.cyberpunk:
        return ArtisticThemePreset.forest;
      case ArtisticThemePreset.sunset:
        return ArtisticThemePreset.ocean;
      case ArtisticThemePreset.ocean:
        return ArtisticThemePreset.sunset;
      case ArtisticThemePreset.forest:
        return ArtisticThemePreset.cyberpunk;
      case ArtisticThemePreset.cosmic:
        return ArtisticThemePreset.minimalist;
      case ArtisticThemePreset.minimalist:
        return ArtisticThemePreset.cosmic;
    }
  }
}

enum ThemeCategory {
  elegant,
  vibrant,
  futuristic,
  warm,
  cool,
  natural,
  mystical,
  minimal,
}

class ThemePresetData {
  final String name;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final ThemeCategory category;
  final List<String> tags;

  const ThemePresetData({
    required this.name,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.category,
    required this.tags,
  });
}

extension ThemeCategoryExtension on ThemeCategory {
  String get displayName {
    switch (this) {
      case ThemeCategory.elegant:
        return 'Elegant';
      case ThemeCategory.vibrant:
        return 'Vibrant';
      case ThemeCategory.futuristic:
        return 'Futuristic';
      case ThemeCategory.warm:
        return 'Warm';
      case ThemeCategory.cool:
        return 'Cool';
      case ThemeCategory.natural:
        return 'Natural';
      case ThemeCategory.mystical:
        return 'Mystical';
      case ThemeCategory.minimal:
        return 'Minimal';
    }
  }

  IconData get icon {
    switch (this) {
      case ThemeCategory.elegant:
        return Icons.diamond;
      case ThemeCategory.vibrant:
        return Icons.colorize;
      case ThemeCategory.futuristic:
        return Icons.rocket_launch;
      case ThemeCategory.warm:
        return Icons.wb_sunny;
      case ThemeCategory.cool:
        return Icons.ac_unit;
      case ThemeCategory.natural:
        return Icons.eco;
      case ThemeCategory.mystical:
        return Icons.auto_awesome;
      case ThemeCategory.minimal:
        return Icons.minimize;
    }
  }
}
