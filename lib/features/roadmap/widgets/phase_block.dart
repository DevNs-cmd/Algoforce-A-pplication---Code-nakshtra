import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../features/roadmap/providers/roadmap_models.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../providers/roadmap_provider.dart';

class PhaseBlock extends ConsumerWidget {
  const PhaseBlock({
    super.key,
    required this.phase,
    required this.index,
    required this.expanded,
  });

  final Phase phase;
  final int index;
  final bool expanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = switch (phase.state) {
      PhaseState.done => AppColors.academy,
      PhaseState.active => AppColors.purple,
      PhaseState.upcoming => AppColors.border2,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        key: ValueKey('${phase.id}-$expanded'),
        initiallyExpanded: expanded,
        onExpansionChanged: (value) {
          if (value) {
            ref.read(roadmapProvider.notifier).expandPhase(index);
          }
        },
        leading: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: phase.state == PhaseState.active
                ? [
                    BoxShadow(
                      color: AppColors.purple.withValues(alpha: .35),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : const [],
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(phase.title, style: AppText.heading(size: 14)),
            ),
            Text(
              '${phase.completedCount}/${phase.items.length} complete',
              style: AppText.mono(size: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                phase.monthRange.toUpperCase(),
                style: AppText.body(
                  size: 10,
                  color: AppColors.textHint,
                  weight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              TagPill(
                label: phase.target,
                color: color == AppColors.border2 ? AppColors.textMuted : color,
              ),
            ],
          ),
        ),
        children: [
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: phase.items.length,
            onReorder: (oldIndex, newIndex) => ref
                .read(roadmapProvider.notifier)
                .reorderPhaseItem(phase.id, oldIndex, newIndex),
            itemBuilder: (context, itemIndex) {
              final item = phase.items[itemIndex];
              return CheckboxListTile(
                key: ValueKey(item.id),
                value: item.completed,
                activeColor: AppColors.academy,
                secondary: const Icon(
                  Icons.drag_handle_rounded,
                  color: AppColors.textHint,
                ),
                onChanged: (value) => ref
                    .read(roadmapProvider.notifier)
                    .toggleItemComplete(phase.id, item.id, value ?? false),
                title: Text(
                  item.description,
                  style:
                      AppText.body(
                        color: item.completed
                            ? AppColors.academyD
                            : AppColors.textPrimary,
                      ).copyWith(
                        decoration: item.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
