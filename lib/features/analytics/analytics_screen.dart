import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../shared/widgets/metric_card.dart';
import '../academy/providers/academy_provider.dart';
import '../advisor/advisor_sheet.dart';
import '../advisor/advisor_service.dart';
import '../nexus/providers/nexus_provider.dart';
import '../studio/models/build_project.dart';
import '../studio/providers/studio_provider.dart';

final analyticsRangeProvider = StateProvider<String>((ref) => 'Last 30 days');

final analyticsInsightsProvider = FutureProvider.autoDispose<String>((ref) {
  final data = _analyticsJson(ref);
  return ref.watch(advisorServiceProvider).generateInsights(data);
});

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(analyticsRangeProvider);
    final academy = ref.watch(academyProvider);
    final studio = ref.watch(studioProvider);
    final insights = ref.watch(analyticsInsightsProvider);
    final activeStudents = academy.cohorts.fold<int>(
      0,
      (sum, cohort) => sum + cohort.students.length,
    );
    final totalRevenue = studio.projects.fold<int>(
      0,
      (sum, project) => sum + project.cashAmount,
    );
    final progressBuilds = studio.projects
        .where((project) => project.status != BuildStatus.live)
        .length;
    final pipeline = studio.deals.fold<double>(
      0,
      (sum, deal) => sum + deal.cashAmount,
    );
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Business Intelligence',
                  style: AppText.display(size: 28),
                ),
              ),
              _RangePicker(value: range),
              const SizedBox(width: AppDimensions.space10),
              ElevatedButton.icon(
                onPressed: () => _export(context, ref),
                icon: const Icon(Icons.content_copy_rounded),
                label: const Text('Export Report'),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space18),
          Wrap(
            spacing: AppDimensions.space12,
            runSpacing: AppDimensions.space12,
            children: [
              SizedBox(
                width: 230,
                child: MetricCard(
                  label: 'Total Revenue Generated',
                  value: '₹${(totalRevenue / 100000).toStringAsFixed(1)}L',
                  sub: range,
                  color: AppColors.purple,
                ),
              ),
              SizedBox(
                width: 230,
                child: MetricCard(
                  label: 'Active Students',
                  value: '$activeStudents',
                  sub: 'academy learners',
                  color: AppColors.academy,
                ),
              ),
              SizedBox(
                width: 230,
                child: MetricCard(
                  label: 'Builds in Progress',
                  value: '$progressBuilds',
                  sub: 'non-live projects',
                  color: AppColors.studio,
                ),
              ),
              SizedBox(
                width: 230,
                child: MetricCard(
                  label: 'Pipeline Value',
                  value: '₹${(pipeline / 100000).toStringAsFixed(1)}L',
                  sub: 'open cash components',
                  color: AppColors.nexus,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space18),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumn = constraints.maxWidth > 980;
              final chartWidth = twoColumn
                  ? (constraints.maxWidth - 18) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: AppDimensions.space18,
                runSpacing: AppDimensions.space18,
                children: [
                  SizedBox(
                    width: chartWidth,
                    child: _ChartCard(
                      title: 'Revenue by Stream',
                      child: _RevenueBars(),
                    ),
                  ),
                  SizedBox(
                    width: chartWidth,
                    child: _ChartCard(
                      title: 'Studio Build Status',
                      child: _BuildPie(),
                    ),
                  ),
                  SizedBox(
                    width: chartWidth,
                    child: const _ChartCard(
                      title: 'Academy Funnel',
                      child: _AcademyFunnel(),
                    ),
                  ),
                  SizedBox(
                    width: chartWidth,
                    child: _ChartCard(
                      title: 'Nexus AI Usage',
                      child: _NexusLine(),
                    ),
                  ),
                  SizedBox(
                    width: chartWidth,
                    child: _ChartCard(
                      title: 'Deal Value Distribution',
                      child: _DealScatter(),
                    ),
                  ),
                  SizedBox(
                    width: chartWidth,
                    child: _InsightsPanel(insights: insights),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppDimensions.space32),
        ],
      ),
    );
  }

  void _export(BuildContext context, WidgetRef ref) {
    final report = const JsonEncoder.withIndent(
      '  ',
    ).convert(jsonDecode(_analyticsJson(ref)));
    Clipboard.setData(ClipboardData(text: report));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Report copied to clipboard')));
  }
}

class _RangePicker extends ConsumerWidget {
  const _RangePicker({required this.value});

  final String value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButton<String>(
      value: value,
      items: const [
        DropdownMenuItem(value: 'Last 7 days', child: Text('Last 7 days')),
        DropdownMenuItem(value: 'Last 30 days', child: Text('Last 30 days')),
        DropdownMenuItem(value: 'This Quarter', child: Text('This Quarter')),
        DropdownMenuItem(value: 'Custom', child: Text('Custom')),
      ],
      onChanged: (next) async {
        if (next == 'Custom') {
          await showDateRangePicker(
            context: context,
            firstDate: DateTime(2025),
            lastDate: DateTime(2027),
          );
        }
        ref.read(analyticsRangeProvider.notifier).state =
            next ?? 'Last 30 days';
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.heading(size: 16)),
          const SizedBox(height: AppDimensions.space12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _RevenueBars extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: [
          for (var i = 0; i < 6; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: 3 + i.toDouble(),
                  color: AppColors.academy,
                  width: 8,
                ),
                BarChartRodData(
                  toY: 4 + i * 1.2,
                  color: AppColors.studio,
                  width: 8,
                ),
                BarChartRodData(
                  toY: 1 + i * .7,
                  color: AppColors.verified,
                  width: 8,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _BuildPie extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(studioProvider).projects;
    final counts = {
      for (final status in BuildStatus.values)
        status: projects.where((project) => project.status == status).length,
    };
    return PieChart(
      PieChartData(
        centerSpaceRadius: 42,
        sections: [
          for (final entry in counts.entries)
            PieChartSectionData(
              value: entry.value.toDouble().clamp(.1, 99),
              title: entry.value.toString(),
              color: _statusColor(entry.key),
              radius: 68,
            ),
        ],
      ),
    );
  }
}

class _AcademyFunnel extends StatelessWidget {
  const _AcademyFunnel();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FunnelPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _NexusLine extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(nexusProvider).buildHistory.length;
    return LineChart(
      LineChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < 14; i++)
                FlSpot(i.toDouble(), ((i * 2 + history) % 9 + 1).toDouble()),
            ],
            color: AppColors.purple,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.purple.withValues(alpha: .12),
            ),
          ),
        ],
      ),
    );
  }
}

class _DealScatter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(studioProvider).projects;
    return ScatterChart(
      ScatterChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        scatterSpots: [
          for (final project in projects)
            ScatterSpot(
              project.equityPercent,
              project.cashAmount / 100000,
              dotPainter: FlDotCirclePainter(
                color: project.dealType == DealType.cash
                    ? AppColors.academy
                    : project.dealType == DealType.equity
                    ? AppColors.purple
                    : AppColors.nexus,
                radius: 7 + project.equityPercent / 4,
              ),
            ),
        ],
      ),
    );
  }
}

class _InsightsPanel extends ConsumerWidget {
  const _InsightsPanel({required this.insights});

  final AsyncValue<String> insights;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ChartCard(
      title: 'AI Insights',
      child: insights.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Text('Advisor insights are unavailable.'),
        data: (text) {
          final lines = text.split('. ').take(3).toList();
          return ListView(
            children: [
              for (final line in lines)
                ListTile(
                  leading: const Icon(
                    Icons.lightbulb_rounded,
                    color: AppColors.purple,
                  ),
                  title: Text(line, style: AppText.body(size: 12)),
                  trailing: TextButton(
                    onPressed: () =>
                        showAdvisorSheet(context, ref, prefill: line),
                    child: const Text('Ask'),
                  ),
                ),
              TextButton.icon(
                onPressed: () => ref.invalidate(analyticsInsightsProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh insights'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FunnelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const labels = [
      'Applied',
      'Assessed',
      'Enrolled',
      'Week4+',
      'Studio',
      'Placed',
    ];
    const counts = [160, 118, 92, 76, 31, 18];
    final paint = Paint()..color = AppColors.academy;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < labels.length; i++) {
      final width = size.width * (counts[i] / counts.first);
      final top = i * (size.height / labels.length) + 6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, top, width, 24),
          const Radius.circular(8),
        ),
        paint..color = AppColors.academy.withValues(alpha: .3 + i * .08),
      );
      textPainter.text = TextSpan(
        text: '${labels[i]}  ${counts[i]}',
        style: AppText.body(size: 11, color: AppColors.navy),
      );
      textPainter.layout(maxWidth: size.width);
      textPainter.paint(canvas, Offset(8, top + 3));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Color _statusColor(BuildStatus status) {
  return switch (status) {
    BuildStatus.discovery => AppColors.textHint,
    BuildStatus.sprint => AppColors.purple,
    BuildStatus.qa => AppColors.nexus,
    BuildStatus.live => AppColors.academy,
    BuildStatus.retainer => AppColors.navy,
  };
}

String _analyticsJson(dynamic ref) {
  final academy = ref.watch(academyProvider);
  final studio = ref.watch(studioProvider);
  final nexus = ref.watch(nexusProvider);
  return jsonEncode({
    'activeStudents': academy.cohorts.fold<int>(
      0,
      (sum, cohort) => sum + cohort.students.length,
    ),
    'buildsInProgress': studio.projects.length,
    'pipelineCash': studio.deals.fold<int>(
      0,
      (sum, deal) => sum + deal.cashAmount,
    ),
    'nexusBuilds': nexus.buildHistory.length,
  });
}
