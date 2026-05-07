import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/hero_card.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../models/student.dart';
import '../providers/academy_provider.dart';

class CohortDetailScreen extends ConsumerWidget {
  const CohortDetailScreen({super.key, required this.cohortId});

  final String cohortId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(academyProvider);
    final cohort = state.cohortById(cohortId);
    if (cohort == null) {
      return const Center(child: Text('Cohort not found.'));
    }
    final students = ref
        .watch(academyProvider.notifier)
        .filteredStudents(cohortId);
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroCard(
            eyebrow: cohort.status.name,
            title: '${cohort.name} builder records',
            highlight: 'builder',
            description:
                'Track week-by-week progress, Studio deployment, certification, and placement outcomes for every Academy student.',
            accent: AppColors.academy,
            children: [
              LinearProgressIndicator(
                value: cohort.fillRate,
                color: AppColors.academy,
                backgroundColor: AppColors.academyL,
              ),
              const SizedBox(height: 8),
              Text(
                '${cohort.studentsEnrolled}/${cohort.capacity} seats filled • ${cohort.feeRange}',
                style: AppText.body(size: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final filter in StudentFilter.values)
                ChoiceChip(
                  label: Text(_filterLabel(filter)),
                  selected: state.studentFilter == filter,
                  onSelected: (_) => ref
                      .read(academyProvider.notifier)
                      .setStudentFilter(filter),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Search by name or college',
            ),
            onChanged: (value) =>
                ref.read(academyProvider.notifier).setStudentSearch(value),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: MediaQuery.sizeOf(context).width < 600
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: students.length,
                    itemBuilder: (context, index) => _StudentProgressCard(
                      cohortId: cohortId,
                      student: students[index],
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Student')),
                        DataColumn(label: Text('College')),
                        DataColumn(label: Text('Week')),
                        DataColumn(label: Text('Studio')),
                        DataColumn(label: Text('Certified')),
                        DataColumn(label: Text('Placed')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: [
                        for (final student in students)
                          DataRow(
                            cells: [
                              DataCell(
                                TextButton(
                                  onPressed: () => context.push(
                                    '/academy/cohort/$cohortId/student/${student.id}',
                                  ),
                                  child: Text(student.name),
                                ),
                              ),
                              DataCell(Text(student.college)),
                              DataCell(
                                SizedBox(
                                  width: 120,
                                  child: LinearProgressIndicator(
                                    value: student.weekProgress / 12,
                                    color: AppColors.academy,
                                  ),
                                ),
                              ),
                              DataCell(_bool(student.studioDeployed)),
                              DataCell(_bool(student.certified)),
                              DataCell(_bool(student.placed)),
                              DataCell(
                                _StudentActions(
                                  cohortId: cohortId,
                                  studentId: student.id,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 32),
        ],
      ).animate().fadeIn(duration: 200.ms).slideY(begin: .02, end: 0, duration: 200.ms),
    );
  }

  String _filterLabel(StudentFilter filter) {
    return switch (filter) {
      StudentFilter.all => 'All',
      StudentFilter.studioDeployed => 'Studio Deployed',
      StudentFilter.certified => 'Certified',
      StudentFilter.placed => 'Placed',
    };
  }

  Widget _bool(bool value) {
    return TagPill(
      label: value ? 'Yes' : 'No',
      color: value ? AppColors.academy : AppColors.textMuted,
    );
  }
}

class _StudentProgressCard extends ConsumerWidget {
  const _StudentProgressCard({required this.cohortId, required this.student});

  final String cohortId;
  final Student student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    student.name,
                    style: AppText.body(weight: FontWeight.w800),
                  ),
                ),
                TagPill(
                  label: student.feeType == FeeType.isa
                      ? 'ISA'
                      : 'Paid ${Formatters.inr(student.feeAmount)}',
                  color: AppColors.purple,
                ),
              ],
            ),
            Text(
              student.college,
              style: AppText.body(size: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: student.weekProgress / 12,
              color: AppColors.academy,
              backgroundColor: AppColors.academyL,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final week in const ['W1', 'W4', 'W8', 'W12'])
                  Text(
                    week,
                    style: AppText.mono(size: 10, color: AppColors.textHint),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                TagPill(
                  label: student.studioDeployed ? 'Studio Deployed' : 'Active',
                  color: student.studioDeployed
                      ? AppColors.studio
                      : AppColors.academy,
                ),
                if (student.certified)
                  const TagPill(label: 'Certified', color: AppColors.purple),
                if (student.placed)
                  const TagPill(label: 'Placed', color: AppColors.nexus),
              ],
            ),
            const SizedBox(height: 10),
            _StudentActions(cohortId: cohortId, studentId: student.id),
          ],
        ),
      ),
    );
  }
}

class _StudentActions extends ConsumerWidget {
  const _StudentActions({required this.cohortId, required this.studentId});

  final String cohortId;
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> confirm(String message, VoidCallback action) async {
      action();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(label: 'Undo', onPressed: () {}),
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        TextButton(
          onPressed: () => confirm(
            'Student marked Studio ready.',
            () => ref
                .read(academyProvider.notifier)
                .markStudioReady(cohortId, studentId),
          ),
          child: const Text('Mark Studio Ready'),
        ),
        TextButton(
          onPressed: () => confirm(
            'Badge issued.',
            () => ref
                .read(academyProvider.notifier)
                .issueBadge(cohortId, studentId),
          ),
          child: const Text('Issue Badge'),
        ),
        TextButton(
          onPressed: () => confirm(
            'Placement recorded.',
            () => ref
                .read(academyProvider.notifier)
                .markPlaced(cohortId, studentId),
          ),
          child: const Text('Mark Placed'),
        ),
      ],
    );
  }
}
