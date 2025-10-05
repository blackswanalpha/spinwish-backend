class ProfileSettings {
  final String userId;
  final bool darkMode;
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool soundEffects;
  final bool hapticFeedback;
  final String language;
  final String currency;
  final bool autoPlayNext;
  final bool showOnlineStatus;
  final bool allowDirectMessages;
  final bool shareListeningActivity;
  final double musicVolume;
  final double effectsVolume;
  final String preferredAudioQuality;
  final bool downloadOverWifiOnly;
  final bool showExplicitContent;
  final DateTime? lastUpdated;

  ProfileSettings({
    required this.userId,
    this.darkMode = false,
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.soundEffects = true,
    this.hapticFeedback = true,
    this.language = 'en',
    this.currency = 'KSH',
    this.autoPlayNext = true,
    this.showOnlineStatus = true,
    this.allowDirectMessages = true,
    this.shareListeningActivity = true,
    this.musicVolume = 0.8,
    this.effectsVolume = 0.6,
    this.preferredAudioQuality = 'high',
    this.downloadOverWifiOnly = true,
    this.showExplicitContent = false,
    this.lastUpdated,
  });

  factory ProfileSettings.fromJson(Map<String, dynamic> json) =>
      ProfileSettings(
        userId: json['userId'],
        darkMode: json['darkMode'] ?? false,
        pushNotifications: json['pushNotifications'] ?? true,
        emailNotifications: json['emailNotifications'] ?? true,
        smsNotifications: json['smsNotifications'] ?? false,
        soundEffects: json['soundEffects'] ?? true,
        hapticFeedback: json['hapticFeedback'] ?? true,
        language: json['language'] ?? 'en',
        currency: json['currency'] ?? 'KSH',
        autoPlayNext: json['autoPlayNext'] ?? true,
        showOnlineStatus: json['showOnlineStatus'] ?? true,
        allowDirectMessages: json['allowDirectMessages'] ?? true,
        shareListeningActivity: json['shareListeningActivity'] ?? true,
        musicVolume: (json['musicVolume'] ?? 0.8).toDouble(),
        effectsVolume: (json['effectsVolume'] ?? 0.6).toDouble(),
        preferredAudioQuality: json['preferredAudioQuality'] ?? 'high',
        downloadOverWifiOnly: json['downloadOverWifiOnly'] ?? true,
        showExplicitContent: json['showExplicitContent'] ?? false,
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.parse(json['lastUpdated'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'darkMode': darkMode,
        'pushNotifications': pushNotifications,
        'emailNotifications': emailNotifications,
        'smsNotifications': smsNotifications,
        'soundEffects': soundEffects,
        'hapticFeedback': hapticFeedback,
        'language': language,
        'currency': currency,
        'autoPlayNext': autoPlayNext,
        'showOnlineStatus': showOnlineStatus,
        'allowDirectMessages': allowDirectMessages,
        'shareListeningActivity': shareListeningActivity,
        'musicVolume': musicVolume,
        'effectsVolume': effectsVolume,
        'preferredAudioQuality': preferredAudioQuality,
        'downloadOverWifiOnly': downloadOverWifiOnly,
        'showExplicitContent': showExplicitContent,
        'lastUpdated': lastUpdated?.toIso8601String(),
      };

  ProfileSettings copyWith({
    String? userId,
    bool? darkMode,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? soundEffects,
    bool? hapticFeedback,
    String? language,
    String? currency,
    bool? autoPlayNext,
    bool? showOnlineStatus,
    bool? allowDirectMessages,
    bool? shareListeningActivity,
    double? musicVolume,
    double? effectsVolume,
    String? preferredAudioQuality,
    bool? downloadOverWifiOnly,
    bool? showExplicitContent,
    DateTime? lastUpdated,
  }) {
    return ProfileSettings(
      userId: userId ?? this.userId,
      darkMode: darkMode ?? this.darkMode,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      soundEffects: soundEffects ?? this.soundEffects,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      autoPlayNext: autoPlayNext ?? this.autoPlayNext,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      allowDirectMessages: allowDirectMessages ?? this.allowDirectMessages,
      shareListeningActivity:
          shareListeningActivity ?? this.shareListeningActivity,
      musicVolume: musicVolume ?? this.musicVolume,
      effectsVolume: effectsVolume ?? this.effectsVolume,
      preferredAudioQuality:
          preferredAudioQuality ?? this.preferredAudioQuality,
      downloadOverWifiOnly: downloadOverWifiOnly ?? this.downloadOverWifiOnly,
      showExplicitContent: showExplicitContent ?? this.showExplicitContent,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

enum NotificationType {
  songRequest,
  djLive,
  tipReceived,
  followedDjOnline,
  newFeature,
  systemUpdate,
  paymentConfirmation,
  accountSecurity,
}

class NotificationPreference {
  final NotificationType type;
  final String title;
  final String description;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;

  NotificationPreference({
    required this.type,
    required this.title,
    required this.description,
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.smsEnabled = false,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) =>
      NotificationPreference(
        type: NotificationType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'],
          orElse: () => NotificationType.songRequest,
        ),
        title: json['title'],
        description: json['description'],
        pushEnabled: json['pushEnabled'] ?? true,
        emailEnabled: json['emailEnabled'] ?? true,
        smsEnabled: json['smsEnabled'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'type': type.toString().split('.').last,
        'title': title,
        'description': description,
        'pushEnabled': pushEnabled,
        'emailEnabled': emailEnabled,
        'smsEnabled': smsEnabled,
      };

  NotificationPreference copyWith({
    NotificationType? type,
    String? title,
    String? description,
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
  }) {
    return NotificationPreference(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
    );
  }
}
