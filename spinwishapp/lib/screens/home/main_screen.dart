import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spinwishapp/screens/sessions/sessions_screen.dart';
import 'package:spinwishapp/screens/djs/djs_screen.dart';
import 'package:spinwishapp/screens/requests/request_screen.dart';
import 'package:spinwishapp/screens/catalogue/catalogue_screen.dart';
import 'package:spinwishapp/screens/profile/profile_screen.dart';

import 'package:spinwishapp/services/theme_service.dart';
import 'package:spinwishapp/widgets/particle_animation_widget.dart';
import 'package:spinwishapp/widgets/glassmorphic_bottom_nav_bar.dart';
import 'package:spinwishapp/utils/design_system.dart';
import 'package:spinwishapp/utils/icon_manager.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SessionsScreen(),
    const DJsScreen(),
    const CatalogueScreen(),
    const RequestScreen(),
    const ProfileScreen(),
  ];

  final List<NavItem> _navItems = [
    NavItem(
      icon: SpinWishIcons.sessions,
      selectedIcon: SpinWishIcons.sessions,
      label: 'Sessions',
    ),
    NavItem(
      icon: SpinWishIcons.djs,
      selectedIcon: SpinWishIcons.djs,
      label: 'DJs',
    ),
    NavItem(
      icon: SpinWishIcons.music,
      selectedIcon: SpinWishIcons.music,
      label: 'Music',
    ),
    NavItem(
      icon: SpinWishIcons.requests,
      selectedIcon: SpinWishIcons.requests,
      label: 'Requests',
    ),
    NavItem(
      icon: SpinWishIcons.profile,
      selectedIcon: SpinWishIcons.profile,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final theme = Theme.of(context);

        return Scaffold(
          body: ParticleAnimationWidget(
            enabled: true,
            particleColor: theme.colorScheme.primary.withOpacity(0.2),
            particleCount: 20,
            child: MorphingBackgroundWidget(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
                theme.colorScheme.tertiary,
              ],
              child: IndexedStack(index: _currentIndex, children: _screens),
            ),
          ),
          floatingActionButton: _buildConnectButton(theme),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: GlassmorphicBottomNavBar(
            items: _navItems,
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        );
      },
    );
  }

  Widget _buildConnectButton(ThemeData theme) {
    return Container(
      decoration: SpinWishDesignSystem.floatingButtonDecoration(theme),
      child: FloatingActionButton.extended(
        heroTag: "main_connect_fab",
        onPressed: () {
          Navigator.pushNamed(context, '/connect-dj');
        },
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        icon: Icon(Icons.wifi_find, color: theme.colorScheme.onPrimary),
        label: Text(
          'Connect',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
