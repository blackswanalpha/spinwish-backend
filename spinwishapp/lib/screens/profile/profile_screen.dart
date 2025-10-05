import 'package:flutter/material.dart';

import 'package:spinwishapp/services/profile_service.dart';
import 'package:spinwishapp/services/auth_service.dart';

import 'package:spinwishapp/models/user.dart';
import 'package:spinwishapp/screens/auth/login_screen.dart';
import 'package:spinwishapp/screens/profile/edit_profile_screen.dart';
import 'package:spinwishapp/screens/profile/payment_methods_screen.dart';

import 'package:spinwishapp/screens/profile/request_history_screen.dart';
import 'package:spinwishapp/screens/profile/notification_settings_screen.dart';
import 'package:spinwishapp/screens/profile/help_support_screen.dart';
import 'package:spinwishapp/screens/profile/about_spinwish_screen.dart';
import 'package:spinwishapp/screens/theme/theme_settings_screen.dart';

import 'package:spinwishapp/screens/profile/send_feedback_screen.dart';
import 'package:spinwishapp/screens/profile/profile_settings_screen.dart';
import 'package:spinwishapp/widgets/enhanced_image_viewer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final user = await ProfileService.getProfile();

      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load profile',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadUserProfile,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
        ),
        body: const Center(child: Text('No user data available')),
      );
    }

    final user = _user!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showSettingsBottomSheet(context),
            icon: Icon(Icons.settings, color: theme.colorScheme.onSurface),
          ),
          IconButton(
            onPressed: _loadUserProfile,
            icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ClipOval(
                      child: EnhancedImageViewer(
                        imageUrl: user.profileImage.isNotEmpty
                            ? user.profileImage
                            : null,
                        heroTag: 'profile_image_${user.id}',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: CircleAvatar(
                          radius: 40,
                          backgroundColor:
                              theme.colorScheme.onPrimary.withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            size: 16,
                            color: theme.colorScheme.onPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '\$${user.credits.toStringAsFixed(2)} Credits',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats Grid
              Row(
                children: [
                  Expanded(
                      child: _buildStatCard(
                          context, 'Requests', '12', Icons.queue_music)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildStatCard(context, 'Following',
                          '${user.favoriteDJs.length}', Icons.favorite)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildStatCard(context, 'Genres',
                          '${user.favoriteGenres.length}', Icons.music_note)),
                ],
              ),
              const SizedBox(height: 24),

              // Favorite Genres
              if (user.favoriteGenres.isNotEmpty)
                _buildSection(
                  context,
                  'Favorite Genres',
                  Icons.music_note,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.favoriteGenres
                        .map((genre) => Chip(
                              label: Text(
                                genre,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              side: BorderSide.none,
                            ))
                        .toList(),
                  ),
                ),
              if (user.favoriteGenres.isNotEmpty) const SizedBox(height: 24),
              // Menu Items
              _buildMenuItem(context, 'Edit Profile', Icons.edit, () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfileScreen()),
                );
                // Refresh profile if changes were made
                if (result == true) {
                  _loadUserProfile();
                }
              }),
              _buildMenuItem(context, 'Payment Methods', Icons.payment, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PaymentMethodsScreen()),
                );
              }),
              _buildMenuItem(context, 'Request History', Icons.history, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RequestHistoryScreen()),
                );
              }),
              _buildMenuItem(
                  context, 'Notification Settings', Icons.notifications, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationSettingsScreen()),
                );
              }),
              _buildMenuItem(context, 'Theme Settings', Icons.palette, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ThemeSettingsScreen()),
                );
              }),
              _buildMenuItem(context, 'Help & Support', Icons.help, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen()),
                );
              }),
              _buildMenuItem(context, 'Send Feedback', Icons.feedback, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SendFeedbackScreen()),
                );
              }),
              _buildMenuItem(context, 'About SpinWish', Icons.info, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AboutSpinWishScreen()),
                );
              }),
              const SizedBox(height: 16),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: Icon(Icons.logout, color: theme.colorScheme.error),
                  label: Text(
                    'Sign Out',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, IconData icon, Widget content) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child:
              Icon(icon, color: theme.colorScheme.onPrimaryContainer, size: 20),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        trailing: Icon(Icons.chevron_right,
            color: theme.colorScheme.onSurface.withOpacity(0.4)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: theme.colorScheme.surfaceContainer,
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Settings',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.settings, color: theme.colorScheme.primary),
              title: const Text('App Settings'),
              subtitle: const Text('Preferences and configurations'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileSettingsScreen()),
                );
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.notifications, color: theme.colorScheme.primary),
              title: const Text('Notifications'),
              subtitle: const Text('Manage notification preferences'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationSettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: theme.colorScheme.primary),
              title: const Text('Edit Profile'),
              subtitle: const Text('Update your profile information'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfileScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
