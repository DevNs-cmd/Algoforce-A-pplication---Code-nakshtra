import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/hero_card.dart';
import '../../../shared/widgets/section_label.dart';
import '../widgets/activity_feed.dart';
import '../widgets/engine_card_grid.dart';
import '../widgets/flywheel_diagram.dart';
import '../widgets/hero_rotator.dart';
import '../widgets/moat_table.dart';
import '../widgets/real_time_metrics_panel.dart';
import '../widgets/traction_strip.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child:
          const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeroCard(
                    eyebrow: 'Business OS',
                    title: 'The AlgoForce flywheel owns the upside',
                    highlight: 'owns',
                    description:
                        'A single operating layer connects students, builders, founders, investors, and AI-assisted product delivery.',
                    accent: AppColors.purple,
                    children: [HeroRotator(), TractionStrip()],
                  ),
                  SizedBox(height: 18),
                  SectionLabel('Flywheel'),
                  SizedBox(height: 10),
                  FlywheelDiagram(),
                  SizedBox(height: 18),
                  SectionLabel('Engine Grid'),
                  SizedBox(height: 10),
                  EngineCardGrid(),
                  SizedBox(height: 18),
                  SectionLabel('Live Metrics'),
                  SizedBox(height: 10),
                  RealTimeMetricsPanel(),
                  SizedBox(height: 18),
                  SectionLabel('Competitive Moat'),
                  SizedBox(height: 10),
                  MoatTable(),
                  SizedBox(height: 18),
                  SectionLabel('Activity Feed'),
                  SizedBox(height: 10),
                  ActivityFeed(),
                  SizedBox(height: 32),
                ],
              )
              .animate()
              .fadeIn(duration: 200.ms, curve: Curves.easeOut)
              .slideY(begin: .02, end: 0, duration: 200.ms),
    );
  }
}
