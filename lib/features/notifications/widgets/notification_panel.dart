import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/astronaut_widget.dart';
import '../models/notification_item.dart';
import '../providers/notifications_provider.dart';
import 'notification_card.dart';

void showSmartNotificationsPanel(BuildContext context, WidgetRef ref) {
  final overlay = Overlay.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => NotificationPanel(onDismiss: () => entry.remove()),
  );
  overlay.insert(entry);
}

class NotificationPanel extends ConsumerWidget {
  const NotificationPanel({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final items = state.visibleItems;
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(color: Colors.black.withValues(alpha: .24)),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            right: 0,
            top: 0,
            bottom: 0,
            width: AppDimensions.notificationPanelWidth,
            child: SafeArea(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(left: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.space16),
                      child: Row(
                        children: [
                          Text(
                            'Notifications',
                            style: AppText.heading(size: 18),
                          ),
                          const SizedBox(width: AppDimensions.space8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.purple4,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              '${state.unreadCount}',
                              style: AppText.body(
                                size: 11,
                                color: AppColors.purple,
                                weight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => ref
                                .read(notificationsProvider.notifier)
                                .markAllRead(),
                            child: const Text('Mark all read'),
                          ),
                          IconButton(
                            onPressed: onDismiss,
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    _FilterTabs(filter: state.filter),
                    const Divider(height: 1),
                    Expanded(
                      child: items.isEmpty
                          ? const _EmptyNotifications()
                          : ListView(children: _grouped(context, ref, items)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _grouped(
    BuildContext context,
    WidgetRef ref,
    List<NotificationItem> items,
  ) {
    final today = <NotificationItem>[];
    final yesterday = <NotificationItem>[];
    final earlier = <NotificationItem>[];
    final now = DateTime.now();
    for (final item in items) {
      final age = now.difference(item.timestamp);
      if (age.inDays == 0) {
        today.add(item);
      } else if (age.inDays == 1) {
        yesterday.add(item);
      } else {
        earlier.add(item);
      }
    }
    return [
      if (today.isNotEmpty) ..._section(context, ref, 'Today', today),
      if (yesterday.isNotEmpty)
        ..._section(context, ref, 'Yesterday', yesterday),
      if (earlier.isNotEmpty) ..._section(context, ref, 'Earlier', earlier),
    ];
  }

  List<Widget> _section(
    BuildContext context,
    WidgetRef ref,
    String label,
    List<NotificationItem> items,
  ) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Text(
          label.toUpperCase(),
          style: AppText.body(
            size: 10,
            color: AppColors.textHint,
            weight: FontWeight.w900,
          ),
        ),
      ),
      for (final item in items)
        NotificationCard(
          item: item,
          onTap: () {
            ref.read(notificationsProvider.notifier).markRead(item.id);
            onDismiss();
            context.go(item.actionRoute);
          },
          onDismiss: () =>
              ref.read(notificationsProvider.notifier).dismiss(item.id),
          onMarkRead: () =>
              ref.read(notificationsProvider.notifier).markRead(item.id),
        ),
    ];
  }
}

class _FilterTabs extends ConsumerWidget {
  const _FilterTabs({required this.filter});

  final NotificationFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space12),
      child: SegmentedButton<NotificationFilter>(
        showSelectedIcon: false,
        selected: {filter},
        onSelectionChanged: (selection) =>
            ref.read(notificationsProvider.notifier).setFilter(selection.first),
        segments: const [
          ButtonSegment(value: NotificationFilter.all, label: Text('All')),
          ButtonSegment(
            value: NotificationFilter.unread,
            label: Text('Unread'),
          ),
          ButtonSegment(
            value: NotificationFilter.highPriority,
            label: Text('High'),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AstronautWidget(size: 64),
            const SizedBox(height: AppDimensions.space14),
            Text('All caught up!', style: AppText.heading(size: 18)),
            Text(
              'Important AlgoForce events will appear here.',
              textAlign: TextAlign.center,
              style: AppText.body(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
