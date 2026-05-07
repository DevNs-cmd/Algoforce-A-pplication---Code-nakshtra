import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/responsive_grid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/metric_card.dart';
import '../providers/academy_provider.dart';

class CohortDashboard extends ConsumerWidget {
  const CohortDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cohorts = ref.watch(academyProvider).cohorts;
    final students = cohorts.expand((cohort) => cohort.students).toList();
    final total = students.length;
    final deployed = students.where((student) => student.studioDeployed).length;
    final placed = students.where((student) => student.placed).length;
    final stages = [
      (
        'Applied',
        total + ref.watch(academyProvider).pendingApplications.length,
      ),
      ('Assessed', total),
      ('Enrolled', total),
      ('Active', students.where((student) => student.weekProgress < 12).length),
      ('Deployed', deployed),
      ('Placed', placed),
    ];
    final count = ResponsiveGridDelegate.crossAxisCount(
      context,
      mobileCount: 1,
      tabletCount: 3,
      desktopCount: 3,
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
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - (count - 1) * 10) / count;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: width,
                    child: MetricCard(
                      label: 'Total enrolled',
                      value: '$total',
                      sub: 'tracked builders',
                      color: AppColors.academy,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: MetricCard(
                      label: 'Studio deployed',
                      value:
                          '${total == 0 ? 0 : (deployed / total * 100).round()}%',
                      sub: '$deployed builders',
                      color: AppColors.studio,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: MetricCard(
                      label: 'Placed',
                      value:
                          '${total == 0 ? 0 : (placed / total * 100).round()}%',
                      sub: '$placed outcomes',
                      color: AppColors.nexus,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 60,
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: AppColors.academy,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    spots: const [
                      FlSpot(1, 18),
                      FlSpot(2, 24),
                      FlSpot(3, 31),
                      FlSpot(4, 38),
                      FlSpot(5, 47),
                      FlSpot(6, 55),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Enrollment funnel', style: AppText.heading(size: 15)),
          const SizedBox(height: 10),
          for (var i = 0; i < stages.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FunnelRow(
                label: stages[i].$1,
                count: stages[i].$2,
                max: stages.first.$2 == 0 ? 1 : stages.first.$2,
                previous: i == 0 ? stages[i].$2 : stages[i - 1].$2,
              ),
            ),
        ],
      ),
    );
  }
}

class _FunnelRow extends StatelessWidget {
  const _FunnelRow({
    required this.label,
    required this.count,
    required this.max,
    required this.previous,
  });

  final String label;
  final int count;
  final int max;
  final int previous;

  @override
  Widget build(BuildContext context) {
    final conversion = previous == 0 ? 0 : (count / previous * 100).round();
    return Row(
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: AppText.body(size: 12, weight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: FractionallySizedBox(
            widthFactor: (count / max).clamp(.06, 1).toDouble(),
            alignment: Alignment.centerLeft,
            child: Container(
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.academy.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 84,
          child: Text(
            '$count - $conversion%',
            textAlign: TextAlign.right,
            style: AppText.mono(size: 11, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
