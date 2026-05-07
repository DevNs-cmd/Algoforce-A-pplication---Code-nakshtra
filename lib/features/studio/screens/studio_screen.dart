import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/hero_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_label.dart';
import '../providers/studio_provider.dart';
import '../widgets/build_pipeline_board.dart';
import '../widgets/deal_card.dart';
import '../widgets/equity_calculator.dart';

class StudioScreen extends ConsumerWidget {
  const StudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deals = ref.watch(studioProvider).deals;
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroCard(
            eyebrow: 'Studio Engine',
            title: 'Build MVPs with cash and equity upside',
            highlight: 'MVPs',
            description:
                'Drag projects across the Studio delivery board, calculate hybrid deal structures, and convert live launches into retainers.',
            accent: AppColors.studio,
            children: [
              PrimaryButton(
                label: 'Open deal calculator',
                icon: Icons.calculate_rounded,
                onPressed: () => context.push('/studio/calculator'),
              ),
              PrimaryButton(
                label: 'Open portfolio',
                icon: Icons.pie_chart_rounded,
                onPressed: () => context.push('/studio/portfolio'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const SectionLabel('Build Pipeline'),
          const SizedBox(height: 10),
          const BuildPipelineBoard(),
          const SizedBox(height: 18),
          const SectionLabel('Deal Calculator'),
          const SizedBox(height: 10),
          const EquityCalculator(),
          const SizedBox(height: 18),
          const SectionLabel('Saved Deals'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final deal in deals)
                SizedBox(width: 260, child: DealCard(deal: deal)),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ).animate().fadeIn(duration: 200.ms).slideY(begin: .02, end: 0, duration: 200.ms),
    );
  }
}
