import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../models/cohort.dart';
import '../providers/academy_provider.dart';

class CohortTable extends ConsumerWidget {
  const CohortTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(academyProvider);
    if (MediaQuery.sizeOf(context).width < 600) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.cohorts.length,
        itemBuilder: (context, index) {
          final cohort = state.cohorts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text(
                cohort.name,
                style: AppText.body(weight: FontWeight.w800),
              ),
              subtitle: Text(
                '${cohort.studentsEnrolled}/${cohort.capacity} seats - ${cohort.feeRange}',
                style: AppText.body(size: 12, color: AppColors.textMuted),
              ),
              trailing: _status(cohort.status),
              onTap: () => context.push('/academy/cohort/${cohort.id}'),
            ),
          );
        },
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: state.sortColumn,
        sortAscending: state.sortAscending,
        headingTextStyle: AppText.body(
          size: 12,
          color: AppColors.navy,
          weight: FontWeight.w800,
        ),
        dataTextStyle: AppText.body(size: 12),
        columns: [
          DataColumn(
            label: const Text('Cohort Name'),
            onSort: (i, _) => ref.read(academyProvider.notifier).sortCohorts(i),
          ),
          DataColumn(
            label: const Text('Students'),
            numeric: true,
            onSort: (i, _) => ref.read(academyProvider.notifier).sortCohorts(i),
          ),
          DataColumn(
            label: const Text('Capacity'),
            numeric: true,
            onSort: (i, _) => ref.read(academyProvider.notifier).sortCohorts(i),
          ),
          DataColumn(
            label: const Text('Status'),
            onSort: (i, _) => ref.read(academyProvider.notifier).sortCohorts(i),
          ),
          DataColumn(
            label: const Text('Margin'),
            numeric: true,
            onSort: (i, _) => ref.read(academyProvider.notifier).sortCohorts(i),
          ),
          const DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final cohort in state.cohorts)
            DataRow(
              cells: [
                DataCell(
                  Text(
                    cohort.name,
                    style: AppText.body(size: 12, weight: FontWeight.w700),
                  ),
                ),
                DataCell(Text('${cohort.studentsEnrolled}')),
                DataCell(Text('${cohort.capacity}')),
                DataCell(_status(cohort.status)),
                DataCell(
                  Text(
                    cohort.grossMarginPercent == 0
                        ? 'Pending'
                        : '${cohort.grossMarginPercent}%',
                  ),
                ),
                DataCell(
                  TextButton(
                    onPressed: () =>
                        context.push('/academy/cohort/${cohort.id}'),
                    child: const Text('View'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _status(CohortStatus status) {
    return switch (status) {
      CohortStatus.active => const TagPill(
        label: 'Active',
        color: AppColors.academy,
      ),
      CohortStatus.upcoming => const TagPill(
        label: 'Upcoming',
        color: AppColors.nexus,
      ),
      CohortStatus.completed => const TagPill(
        label: 'Completed',
        color: AppColors.textMuted,
      ),
    };
  }
}
