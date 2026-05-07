import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum NotificationType {
  cohortEnrollment,
  studioUpdate,
  verifiedApplication,
  nexusGeneration,
  roadmapReminder,
  revenueAlert,
  dealRoomInterest,
  systemUpdate,
  advisorResponse,
}

enum NotificationPriority { low, medium, high }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.actionRoute,
    required this.priority,
    this.actionParams = const {},
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String actionRoute;
  final Map<String, dynamic> actionParams;
  final NotificationPriority priority;

  IconData get icon {
    return switch (type) {
      NotificationType.cohortEnrollment => Icons.school_rounded,
      NotificationType.studioUpdate => Icons.rocket_launch_rounded,
      NotificationType.verifiedApplication => Icons.verified_rounded,
      NotificationType.nexusGeneration => Icons.auto_awesome_rounded,
      NotificationType.roadmapReminder => Icons.map_rounded,
      NotificationType.revenueAlert => Icons.bar_chart_rounded,
      NotificationType.dealRoomInterest => Icons.handshake_rounded,
      NotificationType.systemUpdate => Icons.info_rounded,
      NotificationType.advisorResponse => Icons.lightbulb_rounded,
    };
  }

  Color get color {
    return switch (type) {
      NotificationType.cohortEnrollment => AppColors.academy,
      NotificationType.studioUpdate => AppColors.studio,
      NotificationType.verifiedApplication => AppColors.verified,
      NotificationType.nexusGeneration => AppColors.nexus,
      NotificationType.roadmapReminder => AppColors.navy,
      NotificationType.revenueAlert => AppColors.purple,
      NotificationType.dealRoomInterest => AppColors.verified,
      NotificationType.systemUpdate => AppColors.textMuted,
      NotificationType.advisorResponse => AppColors.purple,
    };
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      type: type,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute,
      actionParams: actionParams,
      priority: priority,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'actionRoute': actionRoute,
      'actionParams': actionParams,
      'priority': priority.name,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      type: NotificationType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => NotificationType.systemUpdate,
      ),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      actionRoute: json['actionRoute'] as String? ?? '/',
      actionParams: Map<String, dynamic>.from(
        json['actionParams'] as Map? ?? const {},
      ),
      priority: NotificationPriority.values.firstWhere(
        (priority) => priority.name == json['priority'],
        orElse: () => NotificationPriority.low,
      ),
    );
  }

  static String encodeList(List<NotificationItem> items) {
    return jsonEncode(items.map((item) => item.toJson()).toList());
  }

  static List<NotificationItem> decodeList(String raw) {
    return (jsonDecode(raw) as List)
        .map(
          (item) =>
              NotificationItem.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
