import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeMode { light, dark, system }

enum ArtisticThemePreset {
  classic,
  neon,
  cyberpunk,
  sunset,
  ocean,
  forest,
  cosmic,
  minimalist,
}

class ThemeService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _artisticPresetKey = 'artistic_preset';
  static const String _customColorsKey = 'custom_colors';

  ThemeMode _themeMode = ThemeMode.dark;
  ArtisticThemePreset _artisticPreset = ArtisticThemePreset.classic;
  bool _isTransitioning = false;

  // Animation controllers for smooth transitions
  late AnimationController _transitionController;
  late Animation<double> _transitionAnimation;

  ThemeMode get themeMode => _themeMode;
  ArtisticThemePreset get artisticPreset => _artisticPreset;
  bool get isTransitioning => _isTransitioning;
  Animation<double> get transitionAnimation => _transitionAnimation;

  // Initialize theme service
  Future<void> initialize() async {
    await _loadThemePreferences();
    notifyListeners();
  }

  // Load saved theme preferences
  Future<void> _loadThemePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme mode
      final themeModeIndex =
          prefs.getInt(_themeModeKey) ?? 1; // Default to dark
      _themeMode = ThemeMode.values[themeModeIndex];

      // Load artistic preset
      final presetIndex =
          prefs.getInt(_artisticPresetKey) ?? 0; // Default to classic
      _artisticPreset = ArtisticThemePreset.values[presetIndex];
    } catch (e) {
      debugPrint('Error loading theme preferences: $e');
      // Use defaults if loading fails
      _themeMode = ThemeMode.dark;
      _artisticPreset = ArtisticThemePreset.classic;
    }
  }

  // Save theme preferences
  Future<void> _saveThemePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, _themeMode.index);
      await prefs.setInt(_artisticPresetKey, _artisticPreset.index);
    } catch (e) {
      debugPrint('Error saving theme preferences: $e');
    }
  }

  // Set theme mode with smooth transition
  Future<void> setThemeMode(ThemeMode mode, {bool animate = true}) async {
    if (_themeMode == mode) return;

    if (animate) {
      await _animateThemeTransition(() {
        _themeMode = mode;
      });
    } else {
      _themeMode = mode;
      notifyListeners();
    }

    await _saveThemePreferences();
  }

  // Set artistic preset with smooth transition
  Future<void> setArtisticPreset(ArtisticThemePreset preset,
      {bool animate = true}) async {
    if (_artisticPreset == preset) return;

    if (animate) {
      await _animateThemeTransition(() {
        _artisticPreset = preset;
      });
    } else {
      _artisticPreset = preset;
      notifyListeners();
    }

    await _saveThemePreferences();
  }

  // Animate theme transition
  Future<void> _animateThemeTransition(VoidCallback changeCallback) async {
    _isTransitioning = true;
    notifyListeners();

    // Wait a brief moment for UI to prepare
    await Future.delayed(const Duration(milliseconds: 50));

    // Apply the theme change
    changeCallback();
    notifyListeners();

    // Wait for transition to complete
    await Future.delayed(const Duration(milliseconds: 300));

    _isTransitioning = false;
    notifyListeners();
  }

  // Toggle between light and dark themes
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.system:
        // If system, toggle to opposite of current system theme
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        await setThemeMode(
            brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
        break;
    }
  }

  // Get current effective brightness
  Brightness getCurrentBrightness(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness;
    }
  }

  // Check if current theme is dark
  bool isDarkMode(BuildContext context) {
    return getCurrentBrightness(context) == Brightness.dark;
  }

  // Get theme mode display name
  String getThemeModeDisplayName() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // Get artistic preset display name
  String getArtisticPresetDisplayName() {
    switch (_artisticPreset) {
      case ArtisticThemePreset.classic:
        return 'Classic';
      case ArtisticThemePreset.neon:
        return 'Neon';
      case ArtisticThemePreset.cyberpunk:
        return 'Cyberpunk';
      case ArtisticThemePreset.sunset:
        return 'Sunset';
      case ArtisticThemePreset.ocean:
        return 'Ocean';
      case ArtisticThemePreset.forest:
        return 'Forest';
      case ArtisticThemePreset.cosmic:
        return 'Cosmic';
      case ArtisticThemePreset.minimalist:
        return 'Minimalist';
    }
  }

  // Get all available theme presets
  List<ArtisticThemePreset> getAllPresets() {
    return ArtisticThemePreset.values;
  }

  // Reset to default theme
  Future<void> resetToDefault() async {
    await setThemeMode(ThemeMode.system);
    await setArtisticPreset(ArtisticThemePreset.classic);
  }
}
