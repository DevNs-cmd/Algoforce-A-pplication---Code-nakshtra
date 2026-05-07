import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/hero_card.dart';
import '../../../shared/widgets/section_label.dart';
import '../providers/revenue_models.dart';
import '../providers/revenue_provider.dart';
import '../widgets/revenue_chart.dart';
import '../widgets/revenue_projector.dart';
import '../widgets/revenue_streams_table.dart';
import '../widgets/stream_breakdown_card.dart';
import '../widgets/target_bar_animated.dart';
import '../widgets/unit_economics.dart';

class RevenueScreen extends ConsumerWidget {
  const RevenueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(revenueProvider);
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeroCard(
            eyebrow: 'Revenue OS',
            title: 'Scenario planning across every engine',
            highlight: 'Scenario',
            description:
                'Toggle conservative, base, and optimistic projections while live stream switches recalculate the monthly chart.',
            accent: AppColors.academy,
          ),
          const SizedBox(height: 18),
          const RevenueProjector(),
          const SizedBox(height: 18),
          SegmentedButton<ProjectionScenario>(
            segments: const [
              ButtonSegment(
                value: ProjectionScenario.conservative,
                label: Text('Conservative'),
              ),
              ButtonSegment(
                value: ProjectionScenario.base,
                label: Text('Base Case'),
              ),
              ButtonSegment(
                value: ProjectionScenario.optimistic,
                label: Text('Optimistic'),
              ),
            ],
            selected: {state.scenario},
            onSelectionChanged: (value) =>
                ref.read(revenueProvider.notifier).setScenario(value.first),
          ),
          const SizedBox(height: 14),
          const RevenueChart(),
          const SizedBox(height: 18),
          const SectionLabel('Annual Targets'),
          const SizedBox(height: 10),
          const TargetBarsAnimated(),
          const SizedBox(height: 18),
          const SectionLabel('Stream Breakdown'),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth < 680 ? 1 : 2;
              final width = (constraints.maxWidth - (count - 1) * 12) / count;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (var i = 0; i < state.streams.length; i++)
                    SizedBox(
                      width: width,
                      height: 190,
                      child: StreamBreakdownCard(
                        stream: state.streams[i],
                        onChanged: (value) => ref
                            .read(revenueProvider.notifier)
                            .toggleStream(i, value),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const SectionLabel('Stream Table'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: RevenueStreamsTable(streams: state.streams),
          ),
          const SizedBox(height: 18),
          const UnitEconomics(),
          const SizedBox(height: 32),
        ],
      ).animate().fadeIn(duration: 200.ms).slideY(begin: .02, end: 0, duration: 200.ms),
    );
  }
}
