import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spinwishapp/theme.dart';
import 'package:spinwishapp/services/auth_service.dart';
import 'package:spinwishapp/services/session_service.dart';
import 'package:spinwishapp/services/session_history_service.dart';
import 'package:spinwishapp/services/listener_service.dart';
import 'package:spinwishapp/services/live_session_service.dart';
import 'package:spinwishapp/services/location_service.dart';
import 'package:spinwishapp/services/dj_discovery_service.dart';
import 'package:spinwishapp/services/theme_service.dart' as theme_service;

import 'package:spinwishapp/screens/auth/dj_auth_screen.dart';
import 'package:spinwishapp/screens/auth/forgot_password_screen.dart';
import 'package:spinwishapp/screens/home/main_screen.dart';
import 'package:spinwishapp/screens/dj/dj_main_screen.dart';
import 'package:spinwishapp/screens/splash/splash_screen.dart';
import 'package:spinwishapp/screens/connect/connect_dj_screen.dart';
import 'package:spinwishapp/screens/onboarding/onboarding_screen.dart';
import 'package:spinwishapp/screens/welcome/welcome_screen.dart';
import 'package:spinwishapp/screens/dj/session_history_screen.dart';
import 'package:spinwishapp/screens/settings/network_settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize location service
  final locationService = LocationService();
  await locationService.initialize();

  // Initialize theme service
  final themeService = theme_service.ThemeService();
  await themeService.initialize();

  runApp(MyApp(themeService: themeService));
}

class MyApp extends StatelessWidget {
  final theme_service.ThemeService themeService;

  const MyApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionService()),
        ChangeNotifierProvider(create: (_) => SessionHistoryService()),
        ChangeNotifierProvider(create: (_) => ListenerService()),
        ChangeNotifierProvider(create: (_) => LiveSessionService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => DJDiscoveryService()),
        ChangeNotifierProvider.value(value: themeService),
      ],
      child: Consumer<theme_service.ThemeService>(
        builder: (context, themeService, child) {
          // Generate theme based on current settings
          final isDark = themeService.isDarkMode(context);
          final currentTheme = ArtisticThemeGenerator.generateTheme(
            preset: themeService.artisticPreset,
            isDark: isDark,
          );

          return MaterialApp(
            title: 'SpinWish',
            debugShowCheckedModeBanner: false,
            theme: currentTheme,
            darkTheme: ArtisticThemeGenerator.generateTheme(
              preset: themeService.artisticPreset,
              isDark: true,
            ),
            themeMode: _convertThemeMode(themeService.themeMode),
            routes: {
              '/connect-dj': (context) => const ConnectDJScreen(),
              '/dj-auth': (context) => const DJAuthScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/session-history': (context) => const SessionHistoryScreen(),
              '/network-settings': (context) => const NetworkSettingsScreen(),
            },
            home: const AppInitializer(),
          );
        },
      ),
    );
  }

  // Convert theme service ThemeMode to Flutter ThemeMode
  ThemeMode _convertThemeMode(theme_service.ThemeMode mode) {
    switch (mode) {
      case theme_service.ThemeMode.light:
        return ThemeMode.light;
      case theme_service.ThemeMode.dark:
        return ThemeMode.dark;
      case theme_service.ThemeMode.system:
        return ThemeMode.system;
    }
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash screen for minimum duration to allow animations to complete
    // Logo (1500ms) + Text (1000ms + 200ms delay) + Progress (800ms + 500ms delay) = ~2500ms
    // Adding buffer time for smooth experience
    final splashDuration = Future.delayed(const Duration(milliseconds: 8000));

    // Check authentication status and onboarding status
    final authCheck = AuthService.isLoggedIn();
    final userTypeCheck = AuthService.getUserType();
    final onboardingCheck = _checkOnboardingStatus();

    // Wait for all checks to complete
    final results = await Future.wait([
      splashDuration,
      authCheck,
      userTypeCheck,
      onboardingCheck,
    ]);
    final isLoggedIn = results[1] as bool;
    final userType = results[2] as String?;
    final hasCompletedOnboarding = results[3] as bool;

    if (mounted) {
      Widget targetScreen;

      if (!hasCompletedOnboarding) {
        // Show onboarding for first-time users
        targetScreen = const OnboardingScreen();
      } else if (isLoggedIn) {
        // Navigate to appropriate main screen based on user type
        if (userType == 'dj') {
          targetScreen = const DJMainScreen();
        } else {
          targetScreen = const MainScreen();
        }
      } else {
        // Show welcome screen for returning users who aren't logged in
        targetScreen = const WelcomeScreen();
      }

      // Navigate to appropriate screen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return targetScreen;
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Smooth fade transition
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  Future<bool> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('onboarding_completed') ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
