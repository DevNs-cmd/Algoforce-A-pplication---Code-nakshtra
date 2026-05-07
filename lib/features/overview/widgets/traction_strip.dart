import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/metric_card.dart';

class TractionStrip extends StatelessWidget {
  const TractionStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        const cards = [
          MetricCard(
            label: '300+',
            value: '300+',
            sub: 'Students trained across 4+ cohorts',
            color: AppColors.academy,
          ),
          MetricCard(
            label: "Jan '26",
            value: "Jan '26",
            sub: 'Operations live with 3 revenue pillars',
            color: AppColors.purple,
          ),
          MetricCard(
            label: '3',
            value: '3',
            sub: 'Academy, Studio, Verified engines',
            color: AppColors.verified,
          ),
        ];
        if (compact) {
          return Column(
            children: [
              for (final card in cards)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: card,
                ),
            ],
          );
        }
        return Row(
          children: [
            for (final card in cards)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: card,
                ),
              ),
          ],
        );
      },
    );
  }
}
