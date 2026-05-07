import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/callout_card.dart';
import '../../../shared/widgets/hero_card.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_label.dart';
import '../../../shared/widgets/tab_bar_widget.dart';
import '../providers/academy_provider.dart';
import '../widgets/ambassador_map.dart';
import '../widgets/cohort_dashboard.dart';
import '../widgets/cohort_table.dart';
import '../widgets/enroll_form_sheet.dart';
import '../widgets/step_flow.dart';

class AcademyScreen extends ConsumerWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(academyProvider);
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child:
          Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeroCard(
                    eyebrow: 'Academy Engine',
                    title: 'Train builders who ship real MVPs',
                    highlight: 'builders',
                    description:
                        'Every cohort moves through a seven-step operating journey from raw signal to deployed work, certification, placement, and Studio upside.',
                    accent: AppColors.academy,
                    children: [
                      const AcademyStepFlow(),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          SizedBox(
                            width: 180,
                            child: MetricCard(
                              label: 'Active cohort',
                              value: '${state.cohorts[1].studentsEnrolled}',
                              sub: 'builders in motion',
                              color: AppColors.academy,
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: MetricCard(
                              label: 'Capacity',
                              value:
                                  '${state.cohorts.fold<int>(0, (sum, item) => sum + item.capacity)}',
                              sub: 'total seats planned',
                              color: AppColors.purple,
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: MetricCard(
                              label: 'Pending',
                              value: '${state.pendingApplications.length}',
                              sub: 'new applications',
                              color: AppColors.nexus,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      PrimaryButton(
                        label: 'Enroll student',
                        icon: Icons.person_add_alt_1_rounded,
                        onPressed: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (context) => const EnrollFormSheet(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        label: 'Open ISA calculator',
                        icon: Icons.calculate_rounded,
                        onPressed: () =>
                            context.push('/academy/isa-calculator'),
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        label: 'View leaderboard',
                        icon: Icons.leaderboard_rounded,
                        onPressed: () => context.push('/academy/leaderboard'),
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        label: 'Progress board',
                        icon: Icons.grid_view_rounded,
                        onPressed: () =>
                            context.push('/academy/progress-board'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const SectionLabel('Live Cohort Dashboard'),
                  const SizedBox(height: 10),
                  const CohortDashboard(),
                  const SizedBox(height: 18),
                  TabBarWidget(
                    tabs: const [
                      'Cohorts',
                      'Pending',
                      'Economics',
                      'Ambassadors',
                    ],
                    initialIndex: state.activeTabIndex,
                    onChange: (index) =>
                        ref.read(academyProvider.notifier).setActiveTab(index),
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: switch (state.activeTabIndex) {
                      0 => const _Panel(
                        key: ValueKey('cohorts'),
                        child: CohortTable(),
                      ),
                      1 => _Panel(
                        key: const ValueKey('pending'),
                        child: _PendingApplications(
                          applications: state.pendingApplications,
                        ),
                      ),
                      2 => const _Panel(
                        key: ValueKey('economics'),
                        child: CalloutCard(
                          text:
                              'Academy monetizes through upfront fees, income-share upside, and Studio placement into MVP builds. Gross margin stabilizes near 80% once mentors, tooling, and cohort ops are standardized.',
                          background: AppColors.academyL,
                          foreground: AppColors.academyD,
                        ),
                      ),
                      _ => const _Panel(
                        key: ValueKey('ambassadors'),
                        child: AmbassadorMap(),
                      ),
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              )
              .animate()
              .fadeIn(duration: 200.ms, curve: Curves.easeOut)
              .slideY(begin: .02, end: 0, duration: 200.ms),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _PendingApplications extends StatelessWidget {
  const _PendingApplications({required this.applications});

  final List<EnrollmentApplication> applications;

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return Text(
        'Submitted Academy applications will appear here after the enrollment sheet is completed.',
        style: AppText.body(color: AppColors.textMuted),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Pending Applications'),
        const SizedBox(height: 10),
        for (final app in applications)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: AppColors.purple3,
              child: Icon(Icons.school_rounded, color: AppColors.purple),
            ),
            title: Text(
              app.fullName,
              style: AppText.body(weight: FontWeight.w800),
            ),
            subtitle: Text(
              '${app.college} • ${app.cityTier} • ${app.paymentType}',
              style: AppText.body(size: 12, color: AppColors.textMuted),
            ),
            trailing: Text(
              app.phone,
              style: AppText.mono(size: 12, color: AppColors.textMuted),
            ),
          ),
      ],
    );
  }
}
