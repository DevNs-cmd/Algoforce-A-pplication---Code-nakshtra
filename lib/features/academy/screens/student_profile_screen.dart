import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/hero_card.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../models/student.dart';
import '../providers/academy_provider.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({
    super.key,
    required this.cohortId,
    required this.studentId,
  });

  final String cohortId;
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(academyProvider);
    final student = state.studentById(cohortId, studentId);
    final cohort = state.cohortById(cohortId);
    if (student == null || cohort == null) {
      return const Center(child: Text('Student record not found.'));
    }
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroCard(
            eyebrow: cohort.name,
            title: '${student.name} Academy profile',
            highlight: 'Academy',
            description:
                '${student.college} • ${student.city} • ${student.tier == CityTier.tier2 ? 'Tier 2' : 'Tier 3'} builder candidate.',
            accent: AppColors.academy,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  TagPill(
                    label: student.studioDeployed
                        ? 'Studio deployed'
                        : 'Awaiting Studio',
                    color: student.studioDeployed
                        ? AppColors.academy
                        : AppColors.textMuted,
                  ),
                  TagPill(
                    label: student.certified
                        ? 'Certified'
                        : 'Certification pending',
                    color: student.certified
                        ? AppColors.purple
                        : AppColors.textMuted,
                  ),
                  TagPill(
                    label: student.placed ? 'Placed' : 'Placement open',
                    color: student.placed
                        ? AppColors.nexus
                        : AppColors.textMuted,
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
                  label: 'Week progress',
                  value: '${student.weekProgress}/12',
                  sub: 'training sprint',
                  color: AppColors.academy,
                ),
              ),
              SizedBox(
                width: 210,
                child: MetricCard(
                  label: 'Fee model',
                  value: student.feeType == FeeType.isa
                      ? 'ISA'
                      : Formatters.inr(student.feeAmount),
                  sub: 'commercial track',
                  color: AppColors.purple,
                ),
              ),
              SizedBox(
                width: 210,
                child: MetricCard(
                  label: 'Readiness',
                  value: '${(student.weekProgress / 12 * 100).round()}%',
                  sub: 'portfolio signal',
                  color: AppColors.nexus,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Operating notes', style: AppText.heading(size: 16)),
                const SizedBox(height: 10),
                Text(
                  'This student has a tracked pathway through Academy training, Studio deployment, Verified readiness, and hiring partner review. Mentors can use this profile as the single record of builder progress.',
                  style: AppText.body(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 200.ms).slideY(begin: .02, end: 0, duration: 200.ms),
    );
  }
}
