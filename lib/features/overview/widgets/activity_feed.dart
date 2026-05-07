import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../activity/providers/activity_feed_provider.dart';

class ActivityFeed extends ConsumerWidget {
  const ActivityFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(activityFeedProvider).items;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: items.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Cross-feature events will appear here as enrollments, builds, Nexus generations, and roadmap completions happen.',
                style: AppText.body(color: AppColors.textMuted),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.purple4,
                    child: Icon(item.icon, color: AppColors.purple),
                  ),
                  title: Text(
                    item.description,
                    style: AppText.body(weight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    Formatters.timeAgo(item.timestamp),
                    style: AppText.body(size: 11, color: AppColors.textMuted),
                  ),
                  onTap: () => context.go(item.route),
                );
              },
            ),
    );
  }
}
