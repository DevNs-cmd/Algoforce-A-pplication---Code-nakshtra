import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../auth/models/user.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/student.dart';
import '../providers/academy_provider.dart';

final leaderboardCohortFilterProvider = StateProvider<String>(
  (ref) => 'All Cohorts',
);
final leaderboardPeriodProvider = StateProvider<String>((ref) => 'All Time');

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3))
      ..play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rows = _ranked(ref);
    final user = ref.watch(authProvider).currentUser;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: responsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Builder Leaderboard', style: AppText.display(size: 28)),
              const SizedBox(height: AppDimensions.space8),
              Text(
                'XP ranking across cohorts, deployments, badges, and placements.',
                style: AppText.body(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppDimensions.space18),
              _Filters(),
              const SizedBox(height: AppDimensions.space18),
              _Podium(rows: rows.take(3).toList(), confetti: _confetti),
              const SizedBox(height: AppDimensions.space24),
              for (var i = 3; i < rows.length; i++)
                _RankRow(rank: i + 1, entry: rows[i]),
              const SizedBox(height: 110),
            ],
          ),
        ),
        if (user?.role == UserRole.builder && rows.isNotEmpty)
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: _MyRank(entry: rows.first, rank: 1),
          ),
      ],
    );
  }

  List<LeaderboardEntry> _ranked(WidgetRef ref) {
    final filter = ref.watch(leaderboardCohortFilterProvider);
    final cohorts = ref.watch(academyProvider).cohorts.where((cohort) {
      return filter == 'All Cohorts' || cohort.name.startsWith(filter);
    });
    final entries = [
      for (final cohort in cohorts)
        for (final student in cohort.students)
          LeaderboardEntry(
            student: student,
            xp: _xp(student),
            cohort: cohort.name,
          ),
    ]..sort((a, b) => b.xp.compareTo(a.xp));
    return entries;
  }

  int _xp(Student student) {
    return (student.feeType == FeeType.paid ? 50 : 0) +
        student.weekProgress * 20 +
        (student.studioDeployed ? 200 : 0) +
        (student.studioDeployed ? 150 : 0) +
        (student.certified ? 300 : 0) +
        (student.placed ? 500 : 0);
  }
}

class _Filters extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: AppDimensions.space10,
      runSpacing: AppDimensions.space10,
      children: [
        SegmentedButton<String>(
          selected: {ref.watch(leaderboardCohortFilterProvider)},
          onSelectionChanged: (value) =>
              ref.read(leaderboardCohortFilterProvider.notifier).state =
                  value.first,
          segments: const [
            ButtonSegment(value: 'All Cohorts', label: Text('All Cohorts')),
            ButtonSegment(value: 'Cohort 1', label: Text('Cohort 1')),
            ButtonSegment(value: 'Cohort 2', label: Text('Cohort 2')),
            ButtonSegment(value: 'Cohort 3', label: Text('Cohort 3')),
          ],
        ),
        DropdownButton<String>(
          value: ref.watch(leaderboardPeriodProvider),
          items: const [
            DropdownMenuItem(value: 'All Time', child: Text('All Time')),
            DropdownMenuItem(value: 'This Month', child: Text('This Month')),
            DropdownMenuItem(value: 'This Week', child: Text('This Week')),
          ],
          onChanged: (value) =>
              ref.read(leaderboardPeriodProvider.notifier).state =
                  value ?? 'All Time',
        ),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.rows, required this.confetti});

  final List<LeaderboardEntry> rows;
  final ConfettiController confetti;

  @override
  Widget build(BuildContext context) {
    if (rows.length < 3) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 340,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ConfettiWidget(
            confettiController: confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 20,
            emissionFrequency: .05,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PodiumPlace(
                rank: 2,
                entry: rows[1],
                height: 130,
                color: AppColors.border2,
              ),
              _PodiumPlace(
                rank: 1,
                entry: rows[0],
                height: 180,
                color: Colors.amber,
              ),
              _PodiumPlace(
                rank: 3,
                entry: rows[2],
                height: 105,
                color: Colors.brown.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({
    required this.rank,
    required this.entry,
    required this.height,
    required this.color,
  });

  final int rank;
  final LeaderboardEntry entry;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (rank == 1)
            const Icon(Icons.workspace_premium_rounded, color: Colors.amber),
          CircleAvatar(
            radius: rank == 1 ? 32 : 26,
            backgroundColor: AppColors.purple,
            child: Text(
              entry.student.name[0],
              style: AppText.heading(color: AppColors.white),
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            entry.student.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(weight: FontWeight.w800),
          ),
          Text('${entry.xp} XP', style: AppText.mono(color: AppColors.purple)),
          const SizedBox(height: AppDimensions.space8),
          Container(
            height: height,
            width: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .28),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Text(
              '#$rank',
              style: AppText.display(size: 28, color: AppColors.navy),
            ),
          ).animate().slideY(begin: 1, end: 0, duration: 420.ms),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.rank, required this.entry});

  final int rank;
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey('rank-$rank'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.space10),
        padding: const EdgeInsets.all(AppDimensions.space12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            SizedBox(width: 34, child: Text('#$rank', style: AppText.mono())),
            CircleAvatar(child: Text(entry.student.name[0])),
            const SizedBox(width: AppDimensions.space10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.student.name,
                    style: AppText.body(weight: FontWeight.w800),
                  ),
                  Text(
                    entry.student.college,
                    style: AppText.body(size: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppDimensions.space6),
                  LinearProgressIndicator(
                    value: _levelProgress(entry.xp),
                    color: AppColors.purple,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.space10),
            Chip(label: Text(_level(entry.xp))),
            const SizedBox(width: AppDimensions.space10),
            Text('${entry.xp} XP', style: AppText.mono(color: AppColors.navy)),
          ],
        ),
      ),
      onVisibilityChanged: (_) {},
    );
  }
}

class _MyRank extends StatelessWidget {
  const _MyRank({required this.entry, required this.rank});

  final LeaderboardEntry entry;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(AppDimensions.radius16),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space14),
        decoration: BoxDecoration(
          color: AppColors.purple,
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
        ),
        child: Row(
          children: [
            Text(
              'My Rank #$rank',
              style: AppText.body(
                color: AppColors.white,
                weight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Text('${entry.xp} XP', style: AppText.mono(color: AppColors.white))
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.08, 1.08),
                  duration: 900.ms,
                ),
            const SizedBox(width: AppDimensions.space10),
            Chip(label: Text(_level(entry.xp))),
          ],
        ),
      ),
    );
  }
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.student,
    required this.xp,
    required this.cohort,
  });

  final Student student;
  final int xp;
  final String cohort;
}

String _level(int xp) {
  if (xp > 600) {
    return 'Champion';
  }
  if (xp > 300) {
    return 'Deployer';
  }
  if (xp > 100) {
    return 'Builder';
  }
  return 'Learner';
}

double _levelProgress(int xp) {
  if (xp > 600) {
    return 1;
  }
  if (xp > 300) {
    return (xp - 300) / 300;
  }
  if (xp > 100) {
    return (xp - 100) / 200;
  }
  return xp / 100;
}
