import 'package:flutter/material.dart';
import 'package:spinwishapp/models/profile_settings.dart';
import 'package:spinwishapp/services/profile_service.dart';
import 'package:spinwishapp/services/auth_service.dart';
import 'package:spinwishapp/screens/auth/login_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  ProfileSettings? _settings;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await ProfileService.getSettings();
      if (mounted) {
        setState(() {
          _settings = settings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load settings: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _updateSetting<T>(
      T value, ProfileSettings Function(ProfileSettings, T) updater) async {
    if (_settings == null) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final updatedSettings = updater(_settings!, value);
      final result = await ProfileService.updateSettings(updatedSettings);

      if (mounted) {
        setState(() {
          _settings = result;
          _isUpdating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update setting: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
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
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: _isUpdating ? null : onChanged,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required double value,
    required Function(double) onChanged,
    double min = 0.0,
    double max = 1.0,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
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
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null)
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: _isUpdating ? null : onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              iconColor?.withOpacity(0.1) ?? theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? theme.colorScheme.onPrimaryContainer,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: textColor ?? theme.colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withOpacity(0.4),
      ),
      onTap: onTap,
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Current Password'),
                obscureText: true,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (value!.length < 6) return 'Must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await ProfileService.changePassword(
                    currentPassword: currentPasswordController.text,
                    newPassword: newPasswordController.text,
                  );
                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to change password: $e')),
                  );
                }
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ProfileService.deleteAccount();
        await AuthService.logout();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete account: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _settings == null
              ? const Center(child: Text('Failed to load settings'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // App Preferences
                      _buildSection('App Preferences', [
                        _buildSwitchTile(
                          title: 'Dark Mode',
                          subtitle: 'Use dark theme',
                          icon: Icons.dark_mode,
                          value: _settings!.darkMode,
                          onChanged: (value) => _updateSetting(
                            value,
                            (settings, val) => settings.copyWith(darkMode: val),
                          ),
                        ),
                        _buildSwitchTile(
                          title: 'Sound Effects',
                          subtitle: 'Play app sound effects',
                          icon: Icons.volume_up,
                          value: _settings!.soundEffects,
                          onChanged: (value) => _updateSetting(
                            value,
                            (settings, val) =>
                                settings.copyWith(soundEffects: val),
                          ),
                        ),
                        _buildSwitchTile(
                          title: 'Haptic Feedback',
                          subtitle: 'Vibrate on interactions',
                          icon: Icons.vibration,
                          value: _settings!.hapticFeedback,
                          onChanged: (value) => _updateSetting(
                            value,
                            (settings, val) =>
                                settings.copyWith(hapticFeedback: val),
                          ),
                        ),
                      ]),

                      const SizedBox(height: 24),

                      // Audio Settings
                      _buildSection('Audio Settings', [
                        _buildSliderTile(
                          title: 'Music Volume',
                          subtitle:
                              '${(_settings!.musicVolume * 100).round()}%',
                          icon: Icons.music_note,
                          value: _settings!.musicVolume,
                          onChanged: (value) => _updateSetting(
                            value,
                            (settings, val) =>
                                settings.copyWith(musicVolume: val),
                          ),
                        ),
                        _buildSliderTile(
                          title: 'Effects Volume',
                          subtitle:
                              '${(_settings!.effectsVolume * 100).round()}%',
                          icon: Icons.graphic_eq,
                          value: _settings!.effectsVolume,
                          onChanged: (value) => _updateSetting(
                            value,
                            (settings, val) =>
                                settings.copyWith(effectsVolume: val),
                          ),
                        ),
                      ]),

                      const SizedBox(height: 24),

                      // Privacy Settings
                      _buildSection('Privacy', [
                        _buildSwitchTile(
                          title: 'Show Online Status',
                          subtitle: 'Let others see when you\'re online',
                          icon: Icons.visibility,
                          value: _settings!.showOnlineStatus,
                          onChanged: (value) => _updateSetting(
                            value,
                            (settings, val) =>
                                settings.copyWith(showOnlineStatus: val),
                          ),
                        ),
                        _buildSwitchTile(
                          title: 'Allow Direct Messages',
                          subtitle: 'Receive messages from other users',
                          icon: Icons.message,
                          value: _settings!.allowDirectMessages,
                          onChanged: (value) => _updateSetting(
                            value,
                            (settings, val) =>
                                settings.copyWith(allowDirectMessages: val),
                          ),
                        ),
                        _buildSwitchTile(
                          title: 'Share Listening Activity',
                          subtitle: 'Show what you\'re listening to',
                          icon: Icons.share,
                          value: _settings!.shareListeningActivity,
                          onChanged: (value) => _updateSetting(
                            value,
                            (settings, val) =>
                                settings.copyWith(shareListeningActivity: val),
                          ),
                        ),
                      ]),

                      const SizedBox(height: 24),

                      // Account Settings
                      _buildSection('Account', [
                        _buildActionTile(
                          title: 'Change Password',
                          subtitle: 'Update your account password',
                          icon: Icons.lock,
                          onTap: _showChangePasswordDialog,
                        ),
                        _buildActionTile(
                          title: 'Delete Account',
                          subtitle: 'Permanently delete your account',
                          icon: Icons.delete_forever,
                          iconColor: theme.colorScheme.error,
                          textColor: theme.colorScheme.error,
                          onTap: _showDeleteAccountDialog,
                        ),
                      ]),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}
