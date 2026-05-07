import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/hero_card.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../models/build_project.dart';
import '../providers/studio_provider.dart';
import '../widgets/tech_stack_pills.dart';

class BuildDetailScreen extends ConsumerWidget {
  const BuildDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(studioProvider).projectById(projectId);
    if (project == null) {
      return const Center(child: Text('Build project not found.'));
    }
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroCard(
            eyebrow: project.status.name,
            title: '${project.startupName} MVP tracker',
            highlight: 'MVP',
            description: project.description,
            accent: AppColors.studio,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TagPill(
                    label: project.dealType.name,
                    color: AppColors.studio,
                  ),
                  TagPill(
                    label: '${project.builderCount} builders',
                    color: AppColors.nexus,
                  ),
                  TagPill(
                    label: '${project.weeklyProgress}/10 weeks',
                    color: AppColors.academy,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 210,
                child: MetricCard(
                  label: 'Cash',
                  value: Formatters.inr(project.cashAmount),
                  sub: 'build component',
                  color: AppColors.nexus,
                ),
              ),
              SizedBox(
                width: 210,
                child: MetricCard(
                  label: 'Equity',
                  value: '${project.equityPercent.toStringAsFixed(1)}%',
                  sub: 'upside stake',
                  color: AppColors.studio,
                ),
              ),
              SizedBox(
                width: 210,
                child: MetricCard(
                  label: 'Retainer',
                  value: Formatters.inr(project.retainerMonthly),
                  sub: 'monthly recurring',
                  color: AppColors.academy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'Build timeline',
            child: _BuildTimeline(project: project),
          ),
          if (project.dealType != DealType.equity) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => _showInvoiceSheet(context, project),
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Generate Invoice'),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _Panel(
            title: 'Weekly sprint log',
            child: Column(
              children: [
                for (var week = 1; week <= 10; week++)
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(
                      'Week $week',
                      style: AppText.body(weight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      week <= project.weeklyProgress
                          ? 'Shipped sprint evidence and founder review notes.'
                          : 'Planned sprint scope awaiting execution.',
                      style: AppText.body(size: 12, color: AppColors.textMuted),
                    ),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Builder allocation, QA notes, founder demo, and launch risk are tracked in the Studio delivery ledger.',
                          style: AppText.body(
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'Tech stack',
            child: TechStackPills(stack: project.techStack),
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'Timeline',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${Formatters.shortDate(project.startDate)} -> ${Formatters.shortDate(project.expectedLaunchDate)}',
                  style: AppText.mono(size: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: project.weeklyProgress / 10,
                  color: AppColors.studio,
                  backgroundColor: AppColors.studioL,
                ),
              ],
            ),
          ),
          if (project.retainerMonthly > 0) ...[
            const SizedBox(height: 16),
            _Panel(
              title: 'Retainer invoices',
              child: Column(
                children: [
                  for (final month in ['Jan 2026', 'Feb 2026', 'Mar 2026'])
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(month),
                      trailing: Text(
                        Formatters.inr(project.retainerMonthly),
                        style: AppText.mono(color: AppColors.academy),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ).animate().fadeIn(duration: 200.ms).slideY(begin: .02, end: 0, duration: 200.ms),
    );
  }
}

void _showInvoiceSheet(BuildContext context, BuildProject project) {
  final due = TextEditingController(
    text: Formatters.shortDate(DateTime.now().add(const Duration(days: 14))),
  );
  final notes = TextEditingController(
    text: 'Milestone payment for ${project.startupName} MVP delivery.',
  );
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        8,
        18,
        MediaQuery.viewInsetsOf(context).bottom + 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Invoice preview', style: AppText.heading(size: 20)),
          const SizedBox(height: 10),
          Text('Founder: ${project.founderName}', style: AppText.body()),
          Text('Startup: ${project.startupName}', style: AppText.body()),
          Text(
            'Amount: ${Formatters.inr(project.cashAmount)}',
            style: AppText.mono(color: AppColors.studio),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: due,
            decoration: const InputDecoration(labelText: 'Due date'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: notes,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Milestone description',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              final invoice =
                  'AlgoForce Studio Invoice\nFounder: ${project.founderName}\nStartup: ${project.startupName}\nAmount: ${Formatters.inr(project.cashAmount)}\nDue: ${due.text}\nTerms: Net 14\nNotes: ${notes.text}';
              await Clipboard.setData(ClipboardData(text: invoice));
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invoice text copied.')),
                );
              }
            },
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Copy Invoice Text'),
          ),
        ],
      ),
    ),
  );
}

class _BuildTimeline extends StatelessWidget {
  const _BuildTimeline({required this.project});

  final BuildProject project;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var week = 1; week <= 10; week++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: week <= project.weeklyProgress
                    ? AppColors.academy
                    : (week == project.weeklyProgress + 1
                          ? AppColors.purple4
                          : AppColors.bg2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: week <= project.weeklyProgress
                      ? AppColors.academy
                      : AppColors.border2,
                ),
              ),
              child: Icon(
                week <= project.weeklyProgress
                    ? Icons.check_rounded
                    : Icons.more_horiz_rounded,
                size: 16,
                color: week <= project.weeklyProgress
                    ? AppColors.white
                    : AppColors.textHint,
              ),
            ),
            title: Text(
              'Week $week - ${_sprintName(week)}',
              style: AppText.body(weight: FontWeight.w800),
            ),
            subtitle: Text(
              'Builders ${project.builderCount} - ${week <= project.weeklyProgress ? 'completed deliverables' : 'planned sprint scope'}',
              style: AppText.body(size: 12, color: AppColors.textMuted),
            ),
            onTap: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (context) => Padding(
                padding: const EdgeInsets.all(18),
                child: TextField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Week $week notes',
                    hintText:
                        'Founder demo notes, QA risks, deliverables shipped',
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _sprintName(int week) {
    if (week <= 2) {
      return 'Discovery and architecture';
    }
    if (week <= 5) {
      return 'Core product build';
    }
    if (week <= 8) {
      return 'QA and founder review';
    }
    return 'Launch and handoff';
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.heading(size: 16)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
