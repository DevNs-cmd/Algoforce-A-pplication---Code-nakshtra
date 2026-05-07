import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/inline_editable_text.dart';
import '../../../shared/widgets/hero_card.dart';
import '../../../shared/widgets/metric_card.dart';
import '../models/build_project.dart';
import '../providers/studio_provider.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studioProvider);
    final equityProjects = state.projects
        .where((project) => project.equityPercent > 0)
        .toList();
    final values = {
      for (final project in equityProjects)
        project.id:
            (project.equityPercent / 100) *
            (state.valuations[project.id] ?? 25000000),
    };
    final totalValue = values.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    final best = equityProjects.isEmpty
        ? null
        : equityProjects.reduce(
            (a, b) => (values[a.id] ?? 0) >= (values[b.id] ?? 0) ? a : b,
          );
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeroCard(
            eyebrow: 'Studio Portfolio',
            title: 'Track equity upside as paper value',
            highlight: 'equity',
            description:
                'Edit last valuation, move venture stage, and export the portfolio summary from one Studio ledger.',
            accent: AppColors.studio,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 230,
                child: MetricCard(
                  label: 'Portfolio companies',
                  value: '${equityProjects.length}',
                  sub: 'equity or hybrid deals',
                  color: AppColors.studio,
                ),
              ),
              SizedBox(
                width: 230,
                child: MetricCard(
                  label: 'Total paper value',
                  value: Formatters.compactInr(totalValue),
                  sub: 'calculated live',
                  color: AppColors.academy,
                ),
              ),
              SizedBox(
                width: 230,
                child: MetricCard(
                  label: 'Best performer',
                  value: best?.startupName ?? 'Pending',
                  sub: best == null
                      ? 'no equity deals'
                      : Formatters.compactInr(values[best.id] ?? 0),
                  color: AppColors.nexus,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 880;
              final list = _PortfolioList(projects: equityProjects);
              final chart = _SectorPie(projects: equityProjects);
              if (!wide) {
                return Column(
                  children: [chart, const SizedBox(height: 12), list],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 320, child: chart),
                  const SizedBox(width: 14),
                  Expanded(child: list),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () async {
              final summary = equityProjects
                  .map((project) {
                    final valuation = state.valuations[project.id] ?? 25000000;
                    final paper = (project.equityPercent / 100) * valuation;
                    return '${project.startupName}: ${project.equityPercent}% of ${Formatters.inr(valuation)} = ${Formatters.inr(paper)}';
                  })
                  .join('\n');
              await Clipboard.setData(
                ClipboardData(text: 'AlgoForce Studio Portfolio\n$summary'),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Portfolio summary copied.')),
                );
              }
            },
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Export Portfolio Summary'),
          ),
        ],
      ),
    );
  }
}

class _PortfolioList extends ConsumerWidget {
  const _PortfolioList({required this.projects});

  final List<BuildProject> projects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studioProvider);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          final valuation = state.valuations[project.id] ?? 25000000;
          final stage = state.stages[project.id] ?? 'Seed';
          return ListTile(
            title: Text(
              project.startupName,
              style: AppText.body(weight: FontWeight.w800),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${project.description.split(' ').take(3).join(' ')} - ${project.equityPercent.toStringAsFixed(1)}% acquired ${Formatters.shortDate(project.startDate)}',
                  style: AppText.body(size: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                InlineEditableText(
                  value: Formatters.inr(valuation),
                  style: AppText.mono(size: 12, color: AppColors.navy),
                  keyboardType: TextInputType.number,
                  onSubmitted: (value) {
                    final parsed = double.tryParse(
                      value.replaceAll(RegExp(r'[^0-9.]'), ''),
                    );
                    if (parsed != null) {
                      ref
                          .read(studioProvider.notifier)
                          .updateValuation(project.id, parsed);
                    }
                  },
                ),
              ],
            ),
            trailing: SizedBox(
              width: 150,
              child: DropdownButton<String>(
                value: stage,
                isExpanded: true,
                items:
                    const [
                          'Pre-seed',
                          'Seed',
                          'Series A',
                          'Series B',
                          'Acquired',
                          'Dead',
                        ]
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                onChanged: (value) => ref
                    .read(studioProvider.notifier)
                    .updateStage(project.id, value ?? stage),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectorPie extends StatelessWidget {
  const _SectorPie({required this.projects});

  final List<BuildProject> projects;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: PieChart(
        PieChartData(
          sections: [
            for (var i = 0; i < projects.length; i++)
              PieChartSectionData(
                value: projects[i].equityPercent,
                title: projects[i].techStack.first,
                color: [
                  AppColors.studio,
                  AppColors.academy,
                  AppColors.nexus,
                  AppColors.verified,
                ][i % 4],
                radius: 72,
                titleStyle: AppText.body(
                  size: 10,
                  color: AppColors.white,
                  weight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
