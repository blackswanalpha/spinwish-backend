import 'package:flutter/material.dart';
import 'package:spinwishapp/screens/dj/dashboard_tab.dart';
import 'package:spinwishapp/screens/dj/session_tab.dart';
import 'package:spinwishapp/screens/dj/earnings_tab.dart';
import 'package:spinwishapp/screens/dj/playlist_tab.dart';
import 'package:spinwishapp/screens/dj/profile_tab.dart';
import 'package:spinwishapp/widgets/glassmorphic_bottom_nav_bar.dart';

class DJMainScreen extends StatefulWidget {
  const DJMainScreen({super.key});

  @override
  State<DJMainScreen> createState() => _DJMainScreenState();
}

class _DJMainScreenState extends State<DJMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const SessionTab(),
    const EarningsTab(),
    const PlaylistTab(),
    const ProfileTab(),
  ];

  final List<NavItem> _navItems = [
    const NavItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    const NavItem(
      icon: Icons.radio_outlined,
      selectedIcon: Icons.radio,
      label: 'Session',
    ),
    const NavItem(
      icon: Icons.monetization_on_outlined,
      selectedIcon: Icons.monetization_on,
      label: 'Earnings',
    ),
    const NavItem(
      icon: Icons.queue_music_outlined,
      selectedIcon: Icons.queue_music,
      label: 'Playlist',
    ),
    const NavItem(
      icon: Icons.person_outlined,
      selectedIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: GlassmorphicBottomNavBar(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
