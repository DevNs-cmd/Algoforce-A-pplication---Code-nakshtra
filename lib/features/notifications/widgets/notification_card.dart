import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../models/notification_item.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDismiss,
    required this.onMarkRead,
  });

  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimensions.space16),
        color: AppColors.verified,
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.white),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onMarkRead,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space14,
            vertical: AppDimensions.space10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    backgroundColor: item.color.withValues(alpha: .1),
                    child: Icon(item.icon, color: item.color, size: 18),
                  ),
                  if (item.priority == NotificationPriority.high)
                    Positioned(
                      right: -1,
                      top: -1,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.verified,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppText.body(
                        size: 13,
                        weight: item.isRead ? FontWeight.w500 : FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space2),
                    Text(
                      item.body,
                      style: AppText.body(size: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: AppDimensions.space4),
                    Text(
                      timeago.format(item.timestamp),
                      style: AppText.body(size: 11, color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              if (!item.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.purple,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
