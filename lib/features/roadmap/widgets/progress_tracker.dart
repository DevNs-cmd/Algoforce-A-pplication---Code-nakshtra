import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/pulse_dot.dart';
import '../providers/roadmap_models.dart';
import '../providers/roadmap_provider.dart';

class ProgressTracker extends ConsumerWidget {
  const ProgressTracker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(roadmapProvider);
    final activeIndex = state.phases.indexWhere(
      (phase) => phase.state == PhaseState.active,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phase ${activeIndex + 1} of ${state.phases.length} active • ${(state.overallCompletion * 100).round()}% overall',
            style: AppText.mono(size: 13, color: AppColors.navy),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (var i = 0; i < state.phases.length; i++) ...[
                InkWell(
                  onTap: () =>
                      ref.read(roadmapProvider.notifier).expandPhase(i),
                  customBorder: const CircleBorder(),
                  child: _dot(state.phases[i]),
                ),
                if (i != state.phases.length - 1)
                  Expanded(
                    child: Container(height: 1, color: AppColors.border2),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(Phase phase) {
    return switch (phase.state) {
      PhaseState.done => Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColors.academy,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 14,
          color: AppColors.white,
        ),
      ),
      PhaseState.active => const SizedBox(
        width: 26,
        height: 26,
        child: Center(child: PulseDot(color: AppColors.purple, size: 16)),
      ),
      PhaseState.upcoming => Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          color: AppColors.border2,
          shape: BoxShape.circle,
        ),
      ),
    };
  }
}
