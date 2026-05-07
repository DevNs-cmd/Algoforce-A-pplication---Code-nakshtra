import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../features/roadmap/providers/roadmap_models.dart';
import 'tag_pill.dart';

class PhaseBlockWidget extends StatelessWidget {
  const PhaseBlockWidget({
    super.key,
    required this.phase,
    required this.children,
  });

  final Phase phase;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final color = switch (phase.state) {
      PhaseState.done => AppColors.academy,
      PhaseState.active => AppColors.purple,
      PhaseState.upcoming => AppColors.border2,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: phase.state == PhaseState.active
                    ? [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: .35),
                          blurRadius: 12,
                          spreadRadius: 3,
                        ),
                      ]
                    : const [],
              ),
            ),
            Container(width: 1, height: 110, color: AppColors.border2),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                phase.monthRange.toUpperCase(),
                style: AppText.body(
                  size: 10,
                  color: AppColors.textHint,
                  weight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(phase.title, style: AppText.heading(size: 13)),
                  ),
                  TagPill(
                    label: phase.target,
                    color: color == AppColors.border2
                        ? AppColors.textMuted
                        : color,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      ],
    );
  }
}
