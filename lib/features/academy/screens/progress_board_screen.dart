import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../models/student.dart';
import '../providers/academy_provider.dart';

final progressWeekFilterProvider = StateProvider<String>((ref) => 'All');
final progressStatusFilterProvider = StateProvider<Set<String>>((ref) => {});
final progressSortProvider = StateProvider<String>((ref) => 'By week progress');
final progressSelectionProvider = StateProvider<Set<String>>((ref) => {});

class ProgressBoardScreen extends ConsumerWidget {
  const ProgressBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = _students(ref);
    final selected = ref.watch(progressSelectionProvider);
    return Stack(
      children: [
        SingleChildScrollView(
          padding: responsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cohort Live Progress Board',
                style: AppText.display(size: 28),
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                'A real-time view of every student across the 12-week curriculum.',
                style: AppText.body(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppDimensions.space18),
              _Filters(),
              const SizedBox(height: AppDimensions.space18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final showSidebar = constraints.maxWidth > 1040;
                  final columns = constraints.maxWidth > 1100
                      ? 4
                      : constraints.maxWidth > 760
                      ? 3
                      : 2;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: rows.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: .82,
                              ),
                          itemBuilder: (context, index) {
                            final row = rows[index];
                            return StudentProgressCard(
                              row: row,
                              selected: selected.contains(row.key),
                            );
                          },
                        ),
                      ),
                      if (showSidebar) ...[
                        const SizedBox(width: AppDimensions.space18),
                        SizedBox(width: 220, child: _WeekSummary(rows: rows)),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        if (selected.isNotEmpty)
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: _BulkBar(count: selected.length),
          ),
      ],
    );
  }

  List<StudentProgressRow> _students(WidgetRef ref) {
    final academy = ref.watch(academyProvider);
    final weekFilter = ref.watch(progressWeekFilterProvider);
    final statusFilters = ref.watch(progressStatusFilterProvider);
    final sort = ref.watch(progressSortProvider);
    final rows =
        [
          for (final cohort in academy.cohorts)
            for (final student in cohort.students)
              StudentProgressRow(
                cohortId: cohort.id,
                cohortName: cohort.name,
                student: student,
              ),
        ].where((row) {
          final week = row.student.weekProgress;
          final weekOk = switch (weekFilter) {
            'Week 1-4' => week <= 4,
            'Week 5-8' => week >= 5 && week <= 8,
            'Week 9-12' => week >= 9,
            _ => true,
          };
          final statusOk =
              statusFilters.isEmpty ||
              (statusFilters.contains('Studio Ready') &&
                  row.student.studioDeployed) ||
              (statusFilters.contains('Certified') && row.student.certified) ||
              (statusFilters.contains('Placed') && row.student.placed);
          return weekOk && statusOk;
        }).toList();
    rows.sort((a, b) {
      return switch (sort) {
        'By name' => a.student.name.compareTo(b.student.name),
        'By fee type' => a.student.feeType.name.compareTo(
          b.student.feeType.name,
        ),
        _ => b.student.weekProgress.compareTo(a.student.weekProgress),
      };
    });
    return rows;
  }
}

class StudentProgressCard extends ConsumerWidget {
  const StudentProgressCard({
    super.key,
    required this.row,
    required this.selected,
  });

  final StudentProgressRow row;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = row.student;
    return InkWell(
      onTap: () {
        if (ref.read(progressSelectionProvider).isNotEmpty) {
          _toggle(ref);
          return;
        }
        context.push('/academy/cohort/${row.cohortId}/student/${student.id}');
      },
      onLongPress: () => _toggle(ref),
      borderRadius: BorderRadius.circular(AppDimensions.radius14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(AppDimensions.space10),
        decoration: BoxDecoration(
          color: selected ? AppColors.purple4 : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius14),
          border: Border.all(
            color: selected ? AppColors.purple : AppColors.border,
          ),
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.academy,
                child: Text(
                  student.name[0],
                  style: AppText.body(color: AppColors.white),
                ),
              ),
              const SizedBox(height: AppDimensions.space6),
              Text(
                student.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppText.body(size: 11, weight: FontWeight.w800),
              ),
              const SizedBox(height: AppDimensions.space8),
              Row(
                children: [
                  for (var i = 1; i <= 12; i++)
                    Expanded(
                      child:
                          Container(
                                height: 10,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: i < student.weekProgress
                                      ? AppColors.academy
                                      : i == student.weekProgress
                                      ? AppColors.purple
                                      : AppColors.bg3,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              )
                              .animate(
                                onPlay: i == student.weekProgress
                                    ? (controller) =>
                                          controller.repeat(reverse: true)
                                    : null,
                              )
                              .fade(
                                begin: i == student.weekProgress ? .4 : 1,
                                end: 1,
                              ),
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.space10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatusDot(
                    icon: Icons.rocket_launch_rounded,
                    active: student.studioDeployed,
                  ),
                  _StatusDot(
                    icon: Icons.workspace_premium_rounded,
                    active: student.certified,
                  ),
                  _StatusDot(icon: Icons.work_rounded, active: student.placed),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggle(WidgetRef ref) {
    final selected = {...ref.read(progressSelectionProvider)};
    selected.contains(row.key)
        ? selected.remove(row.key)
        : selected.add(row.key);
    ref.read(progressSelectionProvider.notifier).state = selected;
  }
}

class _Filters extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statuses = ref.watch(progressStatusFilterProvider);
    return Wrap(
      spacing: AppDimensions.space10,
      runSpacing: AppDimensions.space10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<String>(
          selected: {ref.watch(progressWeekFilterProvider)},
          onSelectionChanged: (value) =>
              ref.read(progressWeekFilterProvider.notifier).state = value.first,
          segments: const [
            ButtonSegment(value: 'All', label: Text('All')),
            ButtonSegment(value: 'Week 1-4', label: Text('Week 1-4')),
            ButtonSegment(value: 'Week 5-8', label: Text('Week 5-8')),
            ButtonSegment(value: 'Week 9-12', label: Text('Week 9-12')),
          ],
        ),
        for (final label in ['Studio Ready', 'Certified', 'Placed'])
          FilterChip(
            label: Text(label),
            selected: statuses.contains(label),
            onSelected: (checked) {
              final next = {...statuses};
              checked ? next.add(label) : next.remove(label);
              ref.read(progressStatusFilterProvider.notifier).state = next;
            },
          ),
        DropdownButton<String>(
          value: ref.watch(progressSortProvider),
          items: const [
            DropdownMenuItem(value: 'By name', child: Text('By name')),
            DropdownMenuItem(
              value: 'By week progress',
              child: Text('By week progress'),
            ),
            DropdownMenuItem(value: 'By fee type', child: Text('By fee type')),
          ],
          onChanged: (value) => ref.read(progressSortProvider.notifier).state =
              value ?? 'By week progress',
        ),
      ],
    );
  }
}

class _BulkBar extends ConsumerWidget {
  const _BulkBar({required this.count});

  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(AppDimensions.radius16),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space12),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.purple,
              child: Text(
                '$count',
                style: AppText.body(color: AppColors.white),
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Text(
                'selected',
                style: AppText.body(color: AppColors.white),
              ),
            ),
            TextButton(
              onPressed: () => _bulk(ref, 'studio'),
              child: const Text('Deploy to Studio'),
            ),
            TextButton(
              onPressed: () => _bulk(ref, 'cert'),
              child: const Text('Issue Certification'),
            ),
            TextButton(
              onPressed: () => _bulk(ref, 'placed'),
              child: const Text('Mark Placed'),
            ),
          ],
        ),
      ),
    );
  }

  void _bulk(WidgetRef ref, String action) {
    final selected = ref.read(progressSelectionProvider);
    final controller = ref.read(academyProvider.notifier);
    for (final key in selected) {
      final parts = key.split(':');
      if (parts.length != 2) {
        continue;
      }
      switch (action) {
        case 'studio':
          controller.markStudioReady(parts[0], parts[1]);
          break;
        case 'cert':
          controller.issueBadge(parts[0], parts[1]);
          break;
        case 'placed':
          controller.markPlaced(parts[0], parts[1]);
          break;
      }
    }
    ref.read(progressSelectionProvider.notifier).state = {};
  }
}

class _WeekSummary extends StatelessWidget {
  const _WeekSummary({required this.rows});

  final List<StudentProgressRow> rows;

  @override
  Widget build(BuildContext context) {
    final checkpoints = [1, 4, 8, 12];
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Week Summary', style: AppText.heading(size: 16)),
          const SizedBox(height: AppDimensions.space12),
          for (final week in checkpoints)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Week $week: ${rows.where((row) => row.student.weekProgress >= week).length} students',
                    style: AppText.body(size: 12, weight: FontWeight.w800),
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  LinearProgressIndicator(
                    value: rows.isEmpty
                        ? 0
                        : rows
                                  .where(
                                    (row) => row.student.weekProgress >= week,
                                  )
                                  .length /
                              rows.length,
                    color: AppColors.academy.withValues(alpha: 1 - week / 18),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.icon, required this.active});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Icon(
        icon,
        size: 16,
        color: active ? AppColors.academy : AppColors.border2,
      ),
    );
  }
}

class StudentProgressRow {
  const StudentProgressRow({
    required this.cohortId,
    required this.cohortName,
    required this.student,
  });

  final String cohortId;
  final String cohortName;
  final Student student;

  String get key => '$cohortId:${student.id}';
}
