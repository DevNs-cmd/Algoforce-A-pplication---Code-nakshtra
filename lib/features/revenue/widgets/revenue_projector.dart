import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/metric_card.dart';
import '../providers/revenue_models.dart';
import '../providers/revenue_provider.dart';

class RevenueProjector extends ConsumerWidget {
  const RevenueProjector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputs = ref.watch(revenueProvider).inputs;
    final notifier = ref.read(revenueProvider.notifier);
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Interactive revenue projector',
                  style: AppText.heading(size: 16),
                ),
              ),
              TextButton.icon(
                onPressed: () => _export(context, inputs),
                icon: const Icon(Icons.download_rounded),
                label: const Text('Export Model'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _slider(
            'Academy cohorts per year',
            inputs.academyCohortsPerYear,
            1,
            8,
            (v) => notifier.updateInputs(
              inputs.copyWith(academyCohortsPerYear: v),
            ),
          ),
          _slider(
            'Students per cohort',
            inputs.studentsPerCohort,
            20,
            80,
            (v) => notifier.updateInputs(inputs.copyWith(studentsPerCohort: v)),
          ),
          _slider(
            'Average cohort fee',
            inputs.averageCohortFee,
            15000,
            50000,
            (v) => notifier.updateInputs(inputs.copyWith(averageCohortFee: v)),
            money: true,
          ),
          _slider(
            'Studio builds per month',
            inputs.studioBuildsPerMonth,
            1,
            10,
            (v) =>
                notifier.updateInputs(inputs.copyWith(studioBuildsPerMonth: v)),
          ),
          _slider(
            'Average build value',
            inputs.averageBuildValue,
            100000,
            1000000,
            (v) => notifier.updateInputs(inputs.copyWith(averageBuildValue: v)),
            money: true,
          ),
          _slider(
            'Verified certs per month',
            inputs.verifiedCertsPerMonth,
            0,
            50,
            (v) => notifier.updateInputs(
              inputs.copyWith(verifiedCertsPerMonth: v),
            ),
          ),
          _slider(
            'Cert fee',
            inputs.certFee,
            15000,
            60000,
            (v) => notifier.updateInputs(inputs.copyWith(certFee: v)),
            money: true,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 190,
                child: MetricCard(
                  label: 'Year 1 revenue',
                  value: Formatters.compactInr(inputs.year1Revenue),
                  sub: 'computed live',
                  color: AppColors.academy,
                ),
              ),
              SizedBox(
                width: 190,
                child: MetricCard(
                  label: 'Year 2 revenue',
                  value: Formatters.compactInr(inputs.year2Revenue),
                  sub: '1.8x growth',
                  color: AppColors.studio,
                ),
              ),
              SizedBox(
                width: 190,
                child: MetricCard(
                  label: 'Year 3 revenue',
                  value: Formatters.compactInr(inputs.year3Revenue),
                  sub: '2.0x growth',
                  color: AppColors.verified,
                ),
              ),
              SizedBox(
                width: 190,
                child: MetricCard(
                  label: 'Monthly run rate',
                  value: Formatters.compactInr(inputs.monthlyRunRate),
                  sub: 'current projection',
                  color: AppColors.nexus,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                titlesData: const FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: AppColors.purple,
                    barWidth: 3,
                    spots: [
                      for (var month = 1; month <= 36; month++)
                        FlSpot(
                          month.toDouble(),
                          _monthValue(inputs, month) / 100000,
                        ),
                    ],
                  ),
                ],
              ),
            ),
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
    ValueChanged<double> onChanged, {
    bool money = false,
  }) {
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
              money ? Formatters.inr(value) : value.round().toString(),
              style: AppText.mono(size: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max).toDouble(),
          min: min,
          max: max,
          divisions: 20,
          onChanged: onChanged,
          activeColor: AppColors.purple,
        ),
      ],
    );
  }

  double _monthValue(RevenueProjectionInputs inputs, int month) {
    final year1Monthly = inputs.year1Revenue / 12;
    if (month <= 12) {
      return year1Monthly * month;
    }
    if (month <= 24) {
      return inputs.year1Revenue + (inputs.year2Revenue / 12) * (month - 12);
    }
    return inputs.year1Revenue +
        inputs.year2Revenue +
        (inputs.year3Revenue / 12) * (month - 24);
  }

  Future<void> _export(
    BuildContext context,
    RevenueProjectionInputs inputs,
  ) async {
    final summary =
        'AlgoForce Revenue Model\nYear 1: ${Formatters.inr(inputs.year1Revenue)}\nYear 2: ${Formatters.inr(inputs.year2Revenue)}\nYear 3: ${Formatters.inr(inputs.year3Revenue)}\nMonthly run rate: ${Formatters.inr(inputs.monthlyRunRate)}';
    await Clipboard.setData(ClipboardData(text: summary));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revenue model summary copied.')),
      );
    }
  }
}
