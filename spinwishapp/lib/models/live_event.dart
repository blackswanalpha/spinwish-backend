import 'package:flutter/material.dart';

class LiveEvent {
  final String id;
  final String djName;
  final String profileImage;
  final int viewerCount;
  final List<Color> backgroundColors;
  final bool isLive;

  LiveEvent({
    required this.id,
    required this.djName,
    required this.profileImage,
    required this.viewerCount,
    required this.backgroundColors,
    this.isLive = true,
  });

  String get formattedViewerCount {
    if (viewerCount >= 1000000) {
      return '${(viewerCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewerCount >= 1000) {
      return '${(viewerCount / 1000).toStringAsFixed(0)}k';
    } else {
      return viewerCount.toString();
    }
  }

  factory LiveEvent.fromJson(Map<String, dynamic> json) => LiveEvent(
        id: json['id'],
        djName: json['djName'],
        profileImage: json['profileImage'],
        viewerCount: json['viewerCount'],
        backgroundColors: (json['backgroundColors'] as List<dynamic>)
            .map((color) => Color(color))
            .toList(),
        isLive: json['isLive'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'djName': djName,
        'profileImage': profileImage,
        'viewerCount': viewerCount,
        'backgroundColors': backgroundColors.map((color) => color.value).toList(),
        'isLive': isLive,
      };
}
