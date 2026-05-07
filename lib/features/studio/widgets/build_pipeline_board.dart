import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../models/build_project.dart';
import '../providers/studio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuildPipelineBoard extends ConsumerWidget {
  const BuildPipelineBoard({super.key});

  static const statuses = [
    BuildStatus.discovery,
    BuildStatus.sprint,
    BuildStatus.qa,
    BuildStatus.live,
    BuildStatus.retainer,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(studioProvider).projects;
    if (projects.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'No active builds',
          style: AppText.body(color: AppColors.textMuted),
        ),
      );
    }
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              collapsedBackgroundColor: AppColors.white,
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              title: _ColumnHeader(
                status: status,
                projects: projects
                    .where((project) => project.status == status)
                    .toList(),
              ),
              children: [
                for (final project in projects.where(
                  (project) => project.status == status,
                ))
                  _ProjectCard(project: project),
                _AddCardButton(status: status),
              ],
            ),
          );
        },
      );
    }
    final columnWidth = width < 900 ? 300.0 : 250.0;
    return SizedBox(
      height: 430,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final status in statuses)
              SizedBox(
                width: columnWidth,
                child: _PipelineColumn(
                  status: status,
                  projects: projects
                      .where((project) => project.status == status)
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PipelineColumn extends ConsumerWidget {
  const _PipelineColumn({required this.status, required this.projects});

  final BuildStatus status;
  final List<BuildProject> projects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<BuildProject>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) {
        HapticFeedback.mediumImpact();
        ref.read(studioProvider.notifier).moveProject(details.data.id, status);
      },
      builder: (context, candidateData, rejectedData) {
        final hot = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hot ? AppColors.purple4 : AppColors.bg2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hot ? AppColors.purple : AppColors.border,
              width: hot ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ColumnHeader(status: status, projects: projects),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: projects.length + 1,
                  itemBuilder: (context, index) {
                    if (index == projects.length) {
                      return _AddCardButton(status: status);
                    }
                    return _ProjectCard(project: projects[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader({required this.status, required this.projects});

  final BuildStatus status;
  final List<BuildProject> projects;

  @override
  Widget build(BuildContext context) {
    final value = projects.fold<int>(
      0,
      (sum, project) => sum + project.cashAmount,
    );
    return Row(
      children: [
        Expanded(child: Text(_label(status), style: AppText.heading(size: 14))),
        TagPill(label: '${projects.length}', color: AppColors.studio),
        const SizedBox(width: 6),
        Text(
          Formatters.compactInr(value),
          style: AppText.mono(size: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  String _label(BuildStatus status) {
    return switch (status) {
      BuildStatus.discovery => 'Discovery',
      BuildStatus.sprint => 'Sprint',
      BuildStatus.qa => 'QA',
      BuildStatus.live => 'Live',
      BuildStatus.retainer => 'Retainer',
    };
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final BuildProject project;

  @override
  Widget build(BuildContext context) {
    final days = project.expectedLaunchDate.difference(DateTime.now()).inDays;
    final overdue = days < 0;
    final color = switch (project.dealType) {
      DealType.cash => AppColors.nexus,
      DealType.equity => AppColors.studio,
      DealType.hybrid => AppColors.academy,
    };
    final card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color, AppColors.purple],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.startupName,
                      style: AppText.body(weight: FontWeight.w800),
                    ),
                    Text(
                      project.founderName,
                      style: AppText.body(size: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: project.weeklyProgress / 10,
                      color: color,
                      backgroundColor: color.withValues(alpha: .12),
                      minHeight: 5,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (
                          var i = 0;
                          i < project.builderCount.clamp(1, 4);
                          i++
                        )
                          Align(
                            widthFactor: .72,
                            child: InitialsAvatar(
                              name: 'Builder ${i + 1}',
                              size: 24,
                              color: color,
                            ),
                          ),
                        const Spacer(),
                        TagPill(label: _deal(project), color: color),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TagPill(
                      label: overdue
                          ? '${days.abs()}d overdue'
                          : '$days days left',
                      color: overdue ? AppColors.verified : AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return LongPressDraggable<BuildProject>(
      data: project,
      onDragStarted: () => HapticFeedback.mediumImpact(),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.rotate(
          angle: -.04,
          child: Transform.scale(
            scale: 1.05,
            child: Opacity(
              opacity: .95,
              child: SizedBox(width: 252, child: card),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: .35, child: card),
      child: InkWell(
        onTap: () => context.push('/studio/project/${project.id}'),
        child: card,
      ),
    );
  }

  String _deal(BuildProject project) {
    return switch (project.dealType) {
      DealType.cash => 'Cash ${Formatters.compactInr(project.cashAmount)}',
      DealType.equity => 'Equity ${project.equityPercent.toStringAsFixed(0)}%',
      DealType.hybrid => 'Hybrid ${project.equityPercent.toStringAsFixed(0)}%',
    };
  }
}

class _AddCardButton extends ConsumerWidget {
  const _AddCardButton({required this.status});

  final BuildStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () {
        final controller = TextEditingController();
        showModalBottomSheet<void>(
          context: context,
          useSafeArea: true,
          isScrollControlled: true,
          builder: (context) => Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              18,
              18,
              MediaQuery.viewInsetsOf(context).bottom + 18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Startup name'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    ref
                        .read(studioProvider.notifier)
                        .addQuickProject(status, controller.text);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add card'),
                ),
              ],
            ),
          ),
        );
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add card'),
    );
  }
}
