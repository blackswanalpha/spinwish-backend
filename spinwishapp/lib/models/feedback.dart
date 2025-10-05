enum FeedbackType {
  bugReport,
  featureRequest,
  generalFeedback,
  complaint,
  compliment,
  suggestion,
  technicalIssue,
  uiUxFeedback,
}

enum FeedbackPriority {
  low,
  medium,
  high,
  critical,
}

enum FeedbackStatus {
  submitted,
  inReview,
  inProgress,
  resolved,
  closed,
  rejected,
}

class FeedbackModel {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final FeedbackType type;
  final FeedbackPriority priority;
  final FeedbackStatus status;
  final String title;
  final String description;
  final List<String> attachments;
  final String? deviceInfo;
  final String? appVersion;
  final String? osVersion;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminResponse;
  final DateTime? responseDate;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.type,
    this.priority = FeedbackPriority.medium,
    this.status = FeedbackStatus.submitted,
    required this.title,
    required this.description,
    this.attachments = const [],
    this.deviceInfo,
    this.appVersion,
    this.osVersion,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
    this.adminResponse,
    this.responseDate,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) => FeedbackModel(
        id: json['id'],
        userId: json['userId'],
        userEmail: json['userEmail'],
        userName: json['userName'],
        type: FeedbackType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'],
          orElse: () => FeedbackType.generalFeedback,
        ),
        priority: FeedbackPriority.values.firstWhere(
          (e) => e.toString().split('.').last == json['priority'],
          orElse: () => FeedbackPriority.medium,
        ),
        status: FeedbackStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
          orElse: () => FeedbackStatus.submitted,
        ),
        title: json['title'],
        description: json['description'],
        attachments: List<String>.from(json['attachments'] ?? []),
        deviceInfo: json['deviceInfo'],
        appVersion: json['appVersion'],
        osVersion: json['osVersion'],
        metadata: json['metadata'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        adminResponse: json['adminResponse'],
        responseDate: json['responseDate'] != null ? DateTime.parse(json['responseDate']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userEmail': userEmail,
        'userName': userName,
        'type': type.toString().split('.').last,
        'priority': priority.toString().split('.').last,
        'status': status.toString().split('.').last,
        'title': title,
        'description': description,
        'attachments': attachments,
        'deviceInfo': deviceInfo,
        'appVersion': appVersion,
        'osVersion': osVersion,
        'metadata': metadata,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'adminResponse': adminResponse,
        'responseDate': responseDate?.toIso8601String(),
      };

  FeedbackModel copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? userName,
    FeedbackType? type,
    FeedbackPriority? priority,
    FeedbackStatus? status,
    String? title,
    String? description,
    List<String>? attachments,
    String? deviceInfo,
    String? appVersion,
    String? osVersion,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminResponse,
    DateTime? responseDate,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      attachments: attachments ?? this.attachments,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      appVersion: appVersion ?? this.appVersion,
      osVersion: osVersion ?? this.osVersion,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminResponse: adminResponse ?? this.adminResponse,
      responseDate: responseDate ?? this.responseDate,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case FeedbackType.bugReport:
        return 'Bug Report';
      case FeedbackType.featureRequest:
        return 'Feature Request';
      case FeedbackType.generalFeedback:
        return 'General Feedback';
      case FeedbackType.complaint:
        return 'Complaint';
      case FeedbackType.compliment:
        return 'Compliment';
      case FeedbackType.suggestion:
        return 'Suggestion';
      case FeedbackType.technicalIssue:
        return 'Technical Issue';
      case FeedbackType.uiUxFeedback:
        return 'UI/UX Feedback';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case FeedbackPriority.low:
        return 'Low';
      case FeedbackPriority.medium:
        return 'Medium';
      case FeedbackPriority.high:
        return 'High';
      case FeedbackPriority.critical:
        return 'Critical';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case FeedbackStatus.submitted:
        return 'Submitted';
      case FeedbackStatus.inReview:
        return 'In Review';
      case FeedbackStatus.inProgress:
        return 'In Progress';
      case FeedbackStatus.resolved:
        return 'Resolved';
      case FeedbackStatus.closed:
        return 'Closed';
      case FeedbackStatus.rejected:
        return 'Rejected';
    }
  }
}

class CreateFeedbackRequest {
  final FeedbackType type;
  final String title;
  final String description;
  final FeedbackPriority priority;
  final List<String> attachments;
  final Map<String, dynamic>? metadata;

  CreateFeedbackRequest({
    required this.type,
    required this.title,
    required this.description,
    this.priority = FeedbackPriority.medium,
    this.attachments = const [],
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'type': type.toString().split('.').last,
        'title': title,
        'description': description,
        'priority': priority.toString().split('.').last,
        'attachments': attachments,
        'metadata': metadata,
      };
}

class FeedbackCategory {
  final FeedbackType type;
  final String title;
  final String description;
  final String icon;

  const FeedbackCategory({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
  });

  static const List<FeedbackCategory> categories = [
    FeedbackCategory(
      type: FeedbackType.bugReport,
      title: 'Bug Report',
      description: 'Report a bug or technical issue',
      icon: '🐛',
    ),
    FeedbackCategory(
      type: FeedbackType.featureRequest,
      title: 'Feature Request',
      description: 'Suggest a new feature or improvement',
      icon: '💡',
    ),
    FeedbackCategory(
      type: FeedbackType.generalFeedback,
      title: 'General Feedback',
      description: 'Share your thoughts about the app',
      icon: '💬',
    ),
    FeedbackCategory(
      type: FeedbackType.complaint,
      title: 'Complaint',
      description: 'Report an issue or concern',
      icon: '😞',
    ),
    FeedbackCategory(
      type: FeedbackType.compliment,
      title: 'Compliment',
      description: 'Share what you love about the app',
      icon: '😍',
    ),
    FeedbackCategory(
      type: FeedbackType.suggestion,
      title: 'Suggestion',
      description: 'Suggest improvements or changes',
      icon: '🚀',
    ),
    FeedbackCategory(
      type: FeedbackType.technicalIssue,
      title: 'Technical Issue',
      description: 'Report performance or connectivity issues',
      icon: '⚙️',
    ),
    FeedbackCategory(
      type: FeedbackType.uiUxFeedback,
      title: 'UI/UX Feedback',
      description: 'Feedback about design and user experience',
      icon: '🎨',
    ),
  ];
}
