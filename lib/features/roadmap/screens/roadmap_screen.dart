import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/hero_card.dart';
import '../../../shared/widgets/section_label.dart';
import '../providers/roadmap_provider.dart';
import '../widgets/gantt_chart.dart';
import '../widgets/milestone_tracker.dart';
import '../widgets/phase_block.dart';
import '../widgets/progress_tracker.dart';
import '../widgets/risk_register.dart';
import '../widgets/vision_grid.dart';

class RoadmapScreen extends ConsumerStatefulWidget {
  const RoadmapScreen({super.key});

  @override
  ConsumerState<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends ConsumerState<RoadmapScreen> {
  String _view = 'Timeline';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roadmapProvider);
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeroCard(
            eyebrow: 'Roadmap',
            title: 'A 2030 operating path, not a pitch deck',
            highlight: '2030',
            description:
                'Each phase carries real checklist state, persisted locally, so roadmap progress behaves like an execution surface.',
            accent: AppColors.navy,
          ),
          const SizedBox(height: 18),
          const ProgressTracker(),
          const SizedBox(height: 18),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Timeline', label: Text('Timeline')),
              ButtonSegment(value: 'Gantt', label: Text('Gantt')),
              ButtonSegment(value: 'Risks', label: Text('Risks')),
            ],
            selected: {_view},
            onSelectionChanged: (value) => setState(() => _view = value.first),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: switch (_view) {
              'Gantt' => Column(
                key: const ValueKey('gantt'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GanttChart(phases: state.phases),
                  const SizedBox(height: 12),
                  MilestoneTracker(phases: state.phases),
                ],
              ),
              'Risks' => const RiskRegister(key: ValueKey('risks')),
              _ => Column(
                key: const ValueKey('timeline'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Phases'),
                  const SizedBox(height: 10),
                  for (var i = 0; i < state.phases.length; i++)
                    PhaseBlock(
                      phase: state.phases[i],
                      index: i,
                      expanded: state.expandedPhaseIndex == i,
                    ),
                ],
              ),
            },
          ),
          const SizedBox(height: 18),
          const SectionLabel('2030 Vision'),
          const SizedBox(height: 10),
          const VisionGrid(),
          const SizedBox(height: 32),
        ],
      ).animate().fadeIn(duration: 200.ms).slideY(begin: .02, end: 0, duration: 200.ms),
    );
  }
}
