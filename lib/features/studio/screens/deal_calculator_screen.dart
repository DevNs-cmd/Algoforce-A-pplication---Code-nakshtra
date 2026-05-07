import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/hero_card.dart';
import '../widgets/equity_calculator.dart';

class DealCalculatorScreen extends StatelessWidget {
  const DealCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child: const Column(
        children: [
          HeroCard(
            eyebrow: 'Studio Finance',
            title: 'Model upside before signing the build',
            highlight: 'upside',
            description:
                'Use the same calculator from the Studio desk as a focused screen for founder deal review.',
            accent: AppColors.studio,
            children: [EquityCalculator()],
          ),
        ],
      ).animate().fadeIn(duration: 200.ms).slideY(begin: .02, end: 0, duration: 200.ms),
    );
  }
}
