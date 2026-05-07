import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/preferences_service.dart';

final activityFeedProvider =
    StateNotifierProvider<ActivityFeedController, ActivityFeedState>(
      (ref) => ActivityFeedController(ref.watch(preferencesServiceProvider)),
    );

class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.iconCodePoint,
    required this.description,
    required this.timestamp,
    required this.route,
    this.important = false,
    this.read = false,
  });

  final String id;
  final int iconCodePoint;
  final String description;
  final DateTime timestamp;
  final String route;
  final bool important;
  final bool read;

  IconData get icon {
    return switch (iconCodePoint) {
      _ when iconCodePoint == Icons.school_rounded.codePoint =>
        Icons.school_rounded,
      _ when iconCodePoint == Icons.rocket_launch_rounded.codePoint =>
        Icons.rocket_launch_rounded,
      _ when iconCodePoint == Icons.workspace_premium_rounded.codePoint =>
        Icons.workspace_premium_rounded,
      _ when iconCodePoint == Icons.handshake_rounded.codePoint =>
        Icons.handshake_rounded,
      _ when iconCodePoint == Icons.view_kanban_rounded.codePoint =>
        Icons.view_kanban_rounded,
      _ when iconCodePoint == Icons.payments_rounded.codePoint =>
        Icons.payments_rounded,
      _ when iconCodePoint == Icons.add_circle_rounded.codePoint =>
        Icons.add_circle_rounded,
      _ when iconCodePoint == Icons.verified_user_rounded.codePoint =>
        Icons.verified_user_rounded,
      _ when iconCodePoint == Icons.timeline_rounded.codePoint =>
        Icons.timeline_rounded,
      _ when iconCodePoint == Icons.notification_important_rounded.codePoint =>
        Icons.notification_important_rounded,
      _ when iconCodePoint == Icons.auto_awesome_rounded.codePoint =>
        Icons.auto_awesome_rounded,
      _ when iconCodePoint == Icons.check_circle_rounded.codePoint =>
        Icons.check_circle_rounded,
      _ => Icons.bolt_rounded,
    };
  }

  ActivityItem copyWith({bool? read}) {
    return ActivityItem(
      id: id,
      iconCodePoint: iconCodePoint,
      description: description,
      timestamp: timestamp,
      route: route,
      important: important,
      read: read ?? this.read,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iconCodePoint': iconCodePoint,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'route': route,
      'important': important,
      'read': read,
    };
  }

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id:
          json['id'] as String? ??
          'activity-${DateTime.now().microsecondsSinceEpoch}',
      iconCodePoint:
          json['iconCodePoint'] as int? ?? Icons.bolt_rounded.codePoint,
      description:
          json['description'] as String? ?? 'AlgoForce activity recorded',
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      route: json['route'] as String? ?? '/',
      important: json['important'] as bool? ?? false,
      read: json['read'] as bool? ?? false,
    );
  }
}

class ActivityFeedState {
  const ActivityFeedState({required this.items});

  final List<ActivityItem> items;

  int get unreadCount =>
      items.where((item) => item.important && !item.read).length;
  List<ActivityItem> get importantItems =>
      items.where((item) => item.important).toList();

  ActivityFeedState copyWith({List<ActivityItem>? items}) {
    return ActivityFeedState(items: items ?? this.items);
  }
}

class ActivityFeedController extends StateNotifier<ActivityFeedState> {
  ActivityFeedController(this._prefs)
    : super(ActivityFeedState(items: _load(_prefs)));

  final PreferencesService _prefs;

  void add({
    required IconData icon,
    required String description,
    required String route,
    bool important = true,
  }) {
    final item = ActivityItem(
      id: 'activity-${DateTime.now().microsecondsSinceEpoch}',
      iconCodePoint: icon.codePoint,
      description: description,
      timestamp: DateTime.now(),
      route: route,
      important: important,
    );
    final items = [item, ...state.items].take(20).toList();
    state = state.copyWith(items: items);
    unawaited(_persist(items));
  }

  void dismiss(String id) {
    final items = state.items.where((item) => item.id != id).toList();
    state = state.copyWith(items: items);
    unawaited(_persist(items));
  }

  void markAllRead() {
    final items = [for (final item in state.items) item.copyWith(read: true)];
    state = state.copyWith(items: items);
    unawaited(_persist(items));
  }

  static List<ActivityItem> _load(PreferencesService prefs) {
    final raw = prefs.getActivityFeed();
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) =>
                ActivityItem.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .take(20)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _persist(List<ActivityItem> items) {
    return _prefs.setActivityFeed(
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }
}
