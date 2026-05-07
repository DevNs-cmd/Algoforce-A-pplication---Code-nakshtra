import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../providers/roadmap_models.dart';

class MilestoneTracker extends StatefulWidget {
  const MilestoneTracker({super.key, required this.phases});

  final List<Phase> phases;

  @override
  State<MilestoneTracker> createState() => _MilestoneTrackerState();
}

class _MilestoneTrackerState extends State<MilestoneTracker> {
  final statuses = <String, String>{};

  @override
  Widget build(BuildContext context) {
    final milestones =
        [
          for (final phase in widget.phases)
            for (final item in phase.items) (phase: phase, item: item),
        ]..sort(
          (a, b) => (statuses[a.item.id] == 'Blocked' ? -1 : 1).compareTo(
            statuses[b.item.id] == 'Blocked' ? -1 : 1,
          ),
        );
    final onTrack =
        milestones
            .where(
              (m) =>
                  (statuses[m.item.id] ??
                      (m.item.completed ? 'Done' : 'In Progress')) !=
                  'Blocked',
            )
            .length /
        milestones.length;
    final health = onTrack > .7
        ? AppColors.academy
        : (onTrack > .45 ? const Color(0xFFF59E0B) : AppColors.verified);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text('Milestone tracker', style: AppText.heading(size: 16)),
            trailing: TagPill(
              label: onTrack > .7 ? 'Green' : (onTrack > .45 ? 'Amber' : 'Red'),
              color: health,
            ),
          ),
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: milestones.length,
            itemBuilder: (context, index) {
              final milestone = milestones[index];
              final status =
                  statuses[milestone.item.id] ??
                  (milestone.item.completed ? 'Done' : 'In Progress');
              return ListTile(
                title: Text(
                  milestone.item.description,
                  style: AppText.body(weight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Target ${milestone.phase.monthRange} - Owner: AlgoForce team',
                  style: AppText.body(size: 12, color: AppColors.textMuted),
                ),
                trailing: DropdownButton<String>(
                  value: status,
                  items: const ['Not Started', 'In Progress', 'Blocked', 'Done']
                      .map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => statuses[milestone.item.id] = value ?? status,
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
