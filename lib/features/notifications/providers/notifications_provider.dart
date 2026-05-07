import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/preferences_service.dart';
import '../models/notification_item.dart';

final notificationsProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
      return NotificationsController(ref.watch(preferencesServiceProvider));
    });

class NotificationsState {
  const NotificationsState({
    required this.items,
    this.filter = NotificationFilter.all,
  });

  final List<NotificationItem> items;
  final NotificationFilter filter;

  int get unreadCount => items.where((item) => !item.isRead).length;

  List<NotificationItem> get visibleItems {
    return switch (filter) {
      NotificationFilter.all => items,
      NotificationFilter.unread => items.where((item) => !item.isRead).toList(),
      NotificationFilter.highPriority =>
        items
            .where((item) => item.priority == NotificationPriority.high)
            .toList(),
    };
  }

  NotificationsState copyWith({
    List<NotificationItem>? items,
    NotificationFilter? filter,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
    );
  }
}

enum NotificationFilter { all, unread, highPriority }

class NotificationsController extends StateNotifier<NotificationsState> {
  NotificationsController(this._prefs)
    : super(NotificationsState(items: _load(_prefs))) {
    _clearOld();
    if (state.items.isEmpty) {
      _seed();
    }
    _timer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _generateSmart(),
    );
  }

  final PreferencesService _prefs;
  Timer? _timer;
  final Map<NotificationType, int> _sessionCounts = {};
  static const key = 'notifications_list';

  void setFilter(NotificationFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void add(NotificationItem item) {
    final count = _sessionCounts[item.type] ?? 0;
    if (count >= 3) {
      return;
    }
    _sessionCounts[item.type] = count + 1;
    state = state.copyWith(items: [item, ...state.items].take(50).toList());
    unawaited(_persist());
  }

  void markRead(String id) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == id) item.copyWith(isRead: true) else item,
      ],
    );
    unawaited(_persist());
  }

  void markAllRead() {
    state = state.copyWith(
      items: [for (final item in state.items) item.copyWith(isRead: true)],
    );
    unawaited(_persist());
  }

  void dismiss(String id) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
    );
    unawaited(_persist());
  }

  void _seed() {
    final now = DateTime.now();
    state = state.copyWith(
      items: [
        NotificationItem(
          id: 'seed-academy',
          type: NotificationType.cohortEnrollment,
          title: 'Cohort 2 is 76% enrolled',
          body: '12 spots remaining before capacity planning kicks in.',
          timestamp: now.subtract(const Duration(minutes: 12)),
          isRead: false,
          actionRoute: '/academy',
          priority: NotificationPriority.medium,
        ),
        NotificationItem(
          id: 'seed-studio',
          type: NotificationType.studioUpdate,
          title: 'FarmConnect entering Week 8',
          body: 'QA prep is needed before sprint close.',
          timestamp: now.subtract(const Duration(hours: 2)),
          isRead: false,
          actionRoute: '/studio/project/p1',
          priority: NotificationPriority.high,
        ),
        NotificationItem(
          id: 'seed-revenue',
          type: NotificationType.revenueAlert,
          title: 'Year 1 target 68% achieved',
          body: 'Revenue is on track if Studio retainers convert this month.',
          timestamp: now.subtract(const Duration(hours: 5)),
          isRead: true,
          actionRoute: '/revenue',
          priority: NotificationPriority.low,
        ),
      ],
    );
    unawaited(_persist());
  }

  void _generateSmart() {
    add(
      NotificationItem(
        id: 'smart-${DateTime.now().microsecondsSinceEpoch}',
        type: NotificationType.verifiedApplication,
        title: 'New founder application received',
        body: 'TechStartup from Pune is ready for layer-one review.',
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: '/verified/apply',
        priority: NotificationPriority.medium,
      ),
    );
  }

  void _clearOld() {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final fresh = state.items
        .where((item) => item.timestamp.isAfter(cutoff))
        .toList();
    if (fresh.length != state.items.length) {
      state = state.copyWith(items: fresh);
      unawaited(_persist());
    }
  }

  Future<void> _persist() {
    return _prefs.setString(key, NotificationItem.encodeList(state.items));
  }

  static List<NotificationItem> _load(PreferencesService prefs) {
    final raw = prefs.getString(key);
    if (raw == null) {
      return const [];
    }
    try {
      return NotificationItem.decodeList(raw);
    } catch (_) {
      return const [];
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
