import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/hero_card.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../providers/verified_provider.dart';
import '../widgets/index_score_meter.dart';

class FounderProfileScreen extends ConsumerWidget {
  const FounderProfileScreen({super.key, required this.founderId});

  final String founderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final founder = ref.watch(verifiedProvider).founderById(founderId);
    if (founder == null) {
      return const Center(child: Text('Founder not found.'));
    }
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroCard(
            eyebrow: founder.sector,
            title: '${founder.founderName} Verified profile',
            highlight: 'Verified',
            description:
                '${founder.startupName} is tracked as a certified founder record with renewal, intro, and capital outcomes.',
            accent: AppColors.verified,
            children: [
              TagPill(
                label: founder.badgeStatus.name,
                color: AppColors.verified,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 18,
            runSpacing: 18,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              IndexScoreMeter(score: founder.indexScore),
              SizedBox(
                width: 220,
                child: MetricCard(
                  label: 'Investor intros',
                  value: '${founder.investorIntroCount}',
                  sub: 'curated connections',
                  color: AppColors.nexus,
                ),
              ),
              SizedBox(
                width: 220,
                child: MetricCard(
                  label: 'Round raised',
                  value: Formatters.inr(founder.roundRaisedAmount),
                  sub: 'post-certification',
                  color: AppColors.academy,
                ),
              ),
              SizedBox(
                width: 220,
                child: MetricCard(
                  label: 'Renewal due',
                  value: Formatters.shortDate(founder.annualRenewalDue),
                  sub: 'annual review',
                  color: AppColors.verified,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Certification notes: verified identity, reviewed business fundamentals, computed index score, council approved, renewal policy active.',
              style: AppText.body(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 16),
          _IndexScoreDetail(score: founder.indexScore),
        ],
      ).animate().fadeIn(duration: 200.ms).slideY(begin: .02, end: 0, duration: 200.ms),
    );
  }
}

class _IndexScoreDetail extends StatelessWidget {
  const _IndexScoreDetail({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
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
          Text('Index score detail', style: AppText.heading(size: 16)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 760;
              final blocks = [
                _ScoreBlock(
                  title: 'Traction Score',
                  child: SizedBox(
                    height: 180,
                    child: RadarChart(
                      RadarChartData(
                        dataSets: [
                          RadarDataSet(
                            fillColor: AppColors.academy.withValues(alpha: .18),
                            borderColor: AppColors.academy,
                            dataEntries: const [
                              RadarEntry(value: 24),
                              RadarEntry(value: 20),
                              RadarEntry(value: 18),
                              RadarEntry(value: 22),
                            ],
                          ),
                        ],
                        radarBackgroundColor: AppColors.bg2,
                        titleTextStyle: AppText.body(size: 10),
                        getTitle: (index, angle) => RadarChartTitle(
                          text: ['MRR', 'Users', 'Proof', 'Velocity'][index],
                        ),
                      ),
                    ),
                  ),
                ),
                const _ScoreBlock(
                  title: 'Market Score',
                  child: _Bars(
                    values: {'Size': 21, 'Urgency': 18, 'Wedge': 16},
                    max: 25,
                    color: AppColors.nexus,
                  ),
                ),
                const _ScoreBlock(
                  title: 'Founder Score',
                  child: _Stars(
                    values: {'Clarity': 4, 'Evidence': 5, 'Execution': 4},
                  ),
                ),
                const _ScoreBlock(
                  title: 'Risk Score',
                  child: _Bars(
                    values: {'Legal': 4, 'Churn': 7, 'Data': 5},
                    max: 15,
                    color: AppColors.verified,
                  ),
                ),
              ];
              if (!wide) {
                return Column(
                  children: [
                    for (final block in blocks)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: block,
                      ),
                  ],
                );
              }
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final block in blocks)
                    SizedBox(
                      width: (constraints.maxWidth - 12) / 2,
                      child: block,
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                gridData: const FlGridData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: AppColors.purple,
                    spots: [
                      FlSpot(1, (score - 10).toDouble()),
                      FlSpot(2, (score - 7).toDouble()),
                      FlSpot(3, (score - 3).toDouble()),
                      FlSpot(4, score.toDouble()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Request Re-evaluation'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBlock extends StatelessWidget {
  const _ScoreBlock({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.bg2,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.body(weight: FontWeight.w800)),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}

class _Bars extends StatelessWidget {
  const _Bars({required this.values, required this.max, required this.color});
  final Map<String, int> values;
  final int max;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final entry in values.entries)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(entry.key, style: AppText.body(size: 11)),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: entry.value / max,
                  color: color,
                  backgroundColor: AppColors.border,
                ),
              ),
              const SizedBox(width: 8),
              Text('${entry.value}', style: AppText.mono(size: 11)),
            ],
          ),
        ),
    ],
  );
}

class _Stars extends StatelessWidget {
  const _Stars({required this.values});
  final Map<String, int> values;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final entry in values.entries)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 76,
                child: Text(entry.key, style: AppText.body(size: 11)),
              ),
              for (var i = 0; i < 5; i++)
                Icon(
                  i < entry.value
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: AppColors.purple,
                  size: 17,
                ),
            ],
          ),
        ),
    ],
  );
}
