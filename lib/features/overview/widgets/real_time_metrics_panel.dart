import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/responsive_grid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../academy/providers/academy_provider.dart';
import '../../nexus/providers/nexus_provider.dart';
import '../../studio/providers/studio_provider.dart';
import '../../verified/providers/verified_provider.dart';
import '../providers/overview_provider.dart';

class RealTimeMetricsPanel extends ConsumerWidget {
  const RealTimeMetricsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(liveMetricsProvider);
    final activeBuilds = ref.watch(studioProvider).projects.length;
    final applicationsToday = ref
        .watch(verifiedProvider)
        .pendingApplications
        .where((app) => DateUtils.isSameDay(app.submittedDate, DateTime.now()))
        .length;
    final nexusBuilds = ref.watch(nexusProvider).buildHistory.length;
    final academyPending = ref
        .watch(academyProvider)
        .pendingApplications
        .length;
    final tiles = [
      MetricCard(
        label: 'Revenue this month',
        value: Formatters.compactInr(live.revenueThisMonth),
        sub: 'auto-refresh simulation',
        color: AppColors.academy,
      ),
      MetricCard(
        label: 'Active builds',
        value: '$activeBuilds',
        sub: 'Studio provider state',
        color: AppColors.studio,
      ),
      MetricCard(
        label: 'Applications today',
        value: '${applicationsToday + academyPending}',
        sub: 'Verified + Academy',
        color: AppColors.verified,
      ),
      MetricCard(
        label: 'Nexus builds generated',
        value: '$nexusBuilds',
        sub: 'stored build history',
        color: AppColors.nexus,
      ),
    ];
    final count = ResponsiveGridDelegate.crossAxisCount(
      context,
      mobileCount: 2,
      tabletCount: 2,
      desktopCount: 4,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - (count - 1) * 12) / count;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var i = 0; i < tiles.length; i++)
              SizedBox(
                width: width,
                child: tiles[i]
                    .animate(delay: Duration(milliseconds: i * 70))
                    .fadeIn(duration: 250.ms)
                    .slideY(begin: .04, end: 0),
              ),
          ],
        );
      },
    );
  }
}
