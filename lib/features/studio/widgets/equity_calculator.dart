import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/studio_provider.dart';

class EquityCalculator extends ConsumerWidget {
  const EquityCalculator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calc = ref.watch(studioProvider).calculator;
    final controller = ref.read(studioProvider.notifier);
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
          Text('Equity deal calculator', style: AppText.heading(size: 18)),
          const SizedBox(height: 12),
          _slider(
            'Cash component',
            calc.cashAmount,
            0,
            800000,
            10000,
            (v) => controller.updateCalculator(cashAmount: v),
            Formatters.inr(calc.cashAmount),
          ),
          _slider(
            'Equity percent',
            calc.equityPercent,
            0,
            20,
            .5,
            (v) => controller.updateCalculator(equityPercent: v),
            '${calc.equityPercent.toStringAsFixed(1)}%',
          ),
          _slider(
            'Exit valuation',
            calc.exitValuation,
            5000000,
            500000000,
            5000000,
            (v) => controller.updateCalculator(exitValuation: v),
            Formatters.inr(calc.exitValuation),
          ),
          _slider(
            'Success probability',
            calc.successProbability,
            10,
            90,
            5,
            (v) => controller.updateCalculator(successProbability: v),
            '${calc.successProbability.round()}%',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 200,
                child: MetricCard(
                  label: 'Expected equity value',
                  value: Formatters.inr(calc.expectedEquityValue),
                  sub: 'risk-adjusted upside',
                  color: AppColors.studio,
                ),
              ),
              SizedBox(
                width: 200,
                child: MetricCard(
                  label: 'Total deal value',
                  value: Formatters.inr(calc.totalDealValue),
                  sub: 'cash plus EV',
                  color: AppColors.academy,
                ),
              ),
              SizedBox(
                width: 200,
                child: MetricCard(
                  label: 'Margin',
                  value: '${calc.marginPercent.round()}%',
                  sub: 'cash delivery margin',
                  color: AppColors.nexus,
                ),
              ),
              SizedBox(
                width: 200,
                child: MetricCard(
                  label: 'Cohort equivalents',
                  value: calc.breakEvenCohortEquivalents.toStringAsFixed(1),
                  sub: 'at ₹25K/student',
                  color: AppColors.verified,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: calc.cashAmount / 100000,
                        color: AppColors.nexus,
                        width: 28,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: calc.expectedEquityValue / 100000,
                        color: AppColors.studio,
                        width: 28,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Save This Deal',
            icon: Icons.save_rounded,
            onPressed: () {
              ref.read(studioProvider.notifier).saveDeal();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Studio deal saved to the pipeline ledger.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    double step,
    ValueChanged<double> onChanged,
    String display,
  ) {
    final divisions = ((max - min) / step).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppText.body(size: 12, weight: FontWeight.w700),
              ),
            ),
            Text(
              display,
              style: AppText.mono(size: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max).toDouble(),
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.studio,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
