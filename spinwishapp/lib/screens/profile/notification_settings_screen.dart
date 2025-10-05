import 'package:flutter/material.dart';
import 'package:spinwishapp/models/profile_settings.dart';
import 'package:spinwishapp/services/profile_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  List<NotificationPreference> _preferences = [];
  bool _isLoading = true;
  bool _isUpdating = false;

  final List<NotificationPreference> _defaultPreferences = [
    NotificationPreference(
      type: NotificationType.songRequest,
      title: 'Song Requests',
      description: 'When your song request is accepted or played',
      pushEnabled: true,
      emailEnabled: true,
      smsEnabled: false,
    ),
    NotificationPreference(
      type: NotificationType.djLive,
      title: 'DJ Live Sessions',
      description: 'When your favorite DJs go live',
      pushEnabled: true,
      emailEnabled: false,
      smsEnabled: false,
    ),
    NotificationPreference(
      type: NotificationType.tipReceived,
      title: 'Tips Received',
      description: 'When you receive tips (DJ only)',
      pushEnabled: true,
      emailEnabled: true,
      smsEnabled: false,
    ),
    NotificationPreference(
      type: NotificationType.followedDjOnline,
      title: 'Followed DJ Online',
      description: 'When DJs you follow come online',
      pushEnabled: true,
      emailEnabled: false,
      smsEnabled: false,
    ),
    NotificationPreference(
      type: NotificationType.newFeature,
      title: 'New Features',
      description: 'Updates about new app features',
      pushEnabled: true,
      emailEnabled: true,
      smsEnabled: false,
    ),
    NotificationPreference(
      type: NotificationType.systemUpdate,
      title: 'System Updates',
      description: 'Important system maintenance notifications',
      pushEnabled: true,
      emailEnabled: true,
      smsEnabled: true,
    ),
    NotificationPreference(
      type: NotificationType.paymentConfirmation,
      title: 'Payment Confirmations',
      description: 'Payment receipts and confirmations',
      pushEnabled: true,
      emailEnabled: true,
      smsEnabled: false,
    ),
    NotificationPreference(
      type: NotificationType.accountSecurity,
      title: 'Account Security',
      description: 'Security alerts and login notifications',
      pushEnabled: true,
      emailEnabled: true,
      smsEnabled: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final preferences = await ProfileService.getNotificationPreferences();
      if (mounted) {
        setState(() {
          _preferences = preferences.isNotEmpty ? preferences : _defaultPreferences;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _preferences = _defaultPreferences;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load preferences: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _updatePreference(NotificationPreference preference) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final updatedPreference = await ProfileService.updateNotificationPreference(preference);
      
      if (mounted) {
        setState(() {
          final index = _preferences.indexWhere((p) => p.type == preference.type);
          if (index != -1) {
            _preferences[index] = updatedPreference;
          }
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
            content: Text('Failed to update preference: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildPreferenceCard(NotificationPreference preference) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getNotificationIcon(preference.type),
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preference.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        preference.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Notification Type Toggles
            Column(
              children: [
                _buildToggleRow(
                  'Push Notifications',
                  Icons.notifications,
                  preference.pushEnabled,
                  (value) {
                    final updated = preference.copyWith(pushEnabled: value);
                    _updatePreference(updated);
                  },
                ),
                const SizedBox(height: 8),
                _buildToggleRow(
                  'Email Notifications',
                  Icons.email,
                  preference.emailEnabled,
                  (value) {
                    final updated = preference.copyWith(emailEnabled: value);
                    _updatePreference(updated);
                  },
                ),
                const SizedBox(height: 8),
                _buildToggleRow(
                  'SMS Notifications',
                  Icons.sms,
                  preference.smsEnabled,
                  (value) {
                    final updated = preference.copyWith(smsEnabled: value);
                    _updatePreference(updated);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: _isUpdating ? null : onChanged,
          activeColor: theme.colorScheme.primary,
        ),
      ],
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.songRequest:
        return Icons.music_note;
      case NotificationType.djLive:
        return Icons.radio;
      case NotificationType.tipReceived:
        return Icons.favorite;
      case NotificationType.followedDjOnline:
        return Icons.person_add;
      case NotificationType.newFeature:
        return Icons.new_releases;
      case NotificationType.systemUpdate:
        return Icons.system_update;
      case NotificationType.paymentConfirmation:
        return Icons.payment;
      case NotificationType.accountSecurity:
        return Icons.security;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification Settings',
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Customize how you receive notifications for different types of activities.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Preferences List
                  ..._preferences.map(_buildPreferenceCard),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
