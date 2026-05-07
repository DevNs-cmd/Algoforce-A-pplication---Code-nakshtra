import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/ghost_button.dart';
import '../../../shared/widgets/logo_widget.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../../academy/providers/academy_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../studio/providers/studio_provider.dart';
import '../../verified/providers/verified_provider.dart';
import '../providers/navigation_provider.dart';

class TopBar extends ConsumerWidget {
  const TopBar({
    super.key,
    this.mobile = false,
    this.onMenuPressed,
    this.onSearchPressed,
    this.onNotificationsPressed,
  });

  final bool mobile;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationsPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(navigationProvider);
    final themeMode = ref.watch(themeModeProvider);
    final unread = ref.watch(notificationsProvider).unreadCount;
    final route = GoRouterState.of(context).uri.path;
    final breadcrumbs = _breadcrumbsFor(route, ref);
    final showBreadcrumbs =
        !mobile &&
        MediaQuery.sizeOf(context).width >= Breakpoints.tablet &&
        breadcrumbs.length > 1;
    final content = Container(
      height: showBreadcrumbs ? 82 : 56,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          SizedBox(
            height: 55,
            child: Row(
              children: [
                if (GoRouter.of(context).canPop())
                  Tooltip(
                    message: 'Go back',
                    child: IconButton(
                      onPressed: () => GoRouter.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                if (mobile) ...[
                  const LogoWidget(compact: true),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    nav.topBarTitle,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.heading(size: 16, color: AppColors.navy3),
                  ).animate().fadeIn(delay: 200.ms, duration: 200.ms),
                ),
                if (!mobile) ...[
                  const SizedBox(width: 10),
                  TagPill(label: nav.topBarTag),
                ],
                const Spacer(),
                Tooltip(
                  message: themeMode == ThemeMode.dark
                      ? 'Switch to light mode'
                      : 'Switch to dark mode',
                  child: IconButton(
                    onPressed: () =>
                        ref.read(themeModeProvider.notifier).toggle(),
                    icon: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Search',
                  child: IconButton(
                    onPressed: onSearchPressed,
                    icon: const Icon(Icons.search_rounded),
                  ),
                ),
                Tooltip(
                  message: 'Notifications',
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: onNotificationsPressed,
                        icon: const Icon(Icons.notifications_none_rounded),
                      ),
                      if (unread > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.verified,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unread > 9 ? '9+' : '$unread',
                              style: AppText.body(
                                size: 9,
                                color: AppColors.white,
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (mobile)
                  Tooltip(
                    message: 'Open navigation',
                    child: IconButton(
                      onPressed: onMenuPressed,
                      icon: const Icon(Icons.menu_rounded),
                    ),
                  )
                else if (MediaQuery.sizeOf(context).width > 720) ...[
                  const SizedBox(width: 8),
                  if (nav.currentRoute == '/revenue')
                    GhostButton(
                      label: 'Export Model',
                      icon: Icons.download_rounded,
                      onPressed: () => _handleGhost(context, nav.currentRoute),
                    )
                  else
                    GhostButton(
                      label: nav.ghostLabel,
                      icon: Icons.tune_rounded,
                      onPressed: () => _handleGhost(context, nav.currentRoute),
                    ),
                  const SizedBox(width: 10),
                  PrimaryButton(
                    label: nav.primaryLabel,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => _handlePrimary(context, nav.currentRoute),
                  ),
                ],
              ],
            ),
          ),
          if (showBreadcrumbs)
            BreadcrumbTrail(segments: breadcrumbs)
          else
            const SizedBox.shrink(),
        ],
      ),
    );
    if (MediaQuery.of(context).disableAnimations) {
      return content;
    }
    return content.animate().slideY(
      begin: -1,
      end: 0,
      duration: 300.ms,
      curve: Curves.easeOutCubic,
    );
  }

  void _handleGhost(BuildContext context, String route) {
    HapticFeedback.lightImpact();
    switch (route) {
      case '/studio':
        context.push('/studio/calculator');
        return;
      case '/revenue':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Open Export Model from the Revenue projector panel.',
            ),
          ),
        );
        return;
      case '/nexus':
        context.push('/nexus/builder');
        return;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Focused ${route == '/' ? 'overview' : route.substring(1)} controls are ready.',
            ),
          ),
        );
        return;
    }
  }

  void _handlePrimary(BuildContext context, String route) {
    HapticFeedback.lightImpact();
    switch (route) {
      case '/academy':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Use Enroll student to open the Academy application sheet.',
            ),
          ),
        );
        return;
      case '/verified':
        context.push('/verified/apply');
        return;
      case '/nexus':
        context.push('/nexus/builder');
        return;
      case '/studio':
        context.push('/studio/calculator');
        return;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AlgoForce action queued in the live OS.'),
          ),
        );
        return;
    }
  }
}

class BreadcrumbTrail extends StatelessWidget {
  const BreadcrumbTrail({super.key, required this.segments});

  final List<BreadcrumbSegment> segments;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: AppColors.textHint,
                ),
              ),
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: i == segments.length - 1
                  ? null
                  : () => GoRouter.of(context).go(segments[i].route),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                child: Text(
                  segments[i].label,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(
                    size: 12,
                    color: i == segments.length - 1
                        ? AppColors.navy
                        : AppColors.textHint,
                    weight: i == segments.length - 1
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BreadcrumbSegment {
  const BreadcrumbSegment({required this.label, required this.route});

  final String label;
  final String route;
}

List<BreadcrumbSegment> _breadcrumbsFor(String route, WidgetRef ref) {
  final parts = route.split('/').where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) {
    return const [BreadcrumbSegment(label: 'Overview', route: '/')];
  }
  final base = parts.first;
  return switch (base) {
    'academy' => _academyBreadcrumbs(parts, ref),
    'studio' => _studioBreadcrumbs(parts, ref),
    'verified' => _verifiedBreadcrumbs(parts, ref),
    'nexus' => [
      const BreadcrumbSegment(label: 'Nexus AI', route: '/nexus'),
      if (parts.length > 1)
        const BreadcrumbSegment(label: 'Builder', route: '/nexus/builder'),
    ],
    'revenue' => const [BreadcrumbSegment(label: 'Revenue', route: '/revenue')],
    'roadmap' => const [BreadcrumbSegment(label: 'Roadmap', route: '/roadmap')],
    'analytics' => const [
      BreadcrumbSegment(label: 'Analytics', route: '/analytics'),
    ],
    'profile' => const [BreadcrumbSegment(label: 'Profile', route: '/profile')],
    _ => const [BreadcrumbSegment(label: 'Overview', route: '/')],
  };
}

List<BreadcrumbSegment> _academyBreadcrumbs(List<String> parts, WidgetRef ref) {
  final academy = ref.watch(academyProvider);
  final crumbs = <BreadcrumbSegment>[
    const BreadcrumbSegment(label: 'Academy', route: '/academy'),
  ];
  if (parts.length == 1) {
    return crumbs;
  }
  if (parts[1] == 'isa-calculator') {
    return [
      ...crumbs,
      const BreadcrumbSegment(
        label: 'ISA Calculator',
        route: '/academy/isa-calculator',
      ),
    ];
  }
  if (parts[1] == 'leaderboard') {
    return [
      ...crumbs,
      const BreadcrumbSegment(
        label: 'Leaderboard',
        route: '/academy/leaderboard',
      ),
    ];
  }
  if (parts[1] == 'progress-board') {
    return [
      ...crumbs,
      const BreadcrumbSegment(
        label: 'Progress Board',
        route: '/academy/progress-board',
      ),
    ];
  }
  final cohortId = parts[1] == 'cohort' && parts.length > 2
      ? parts[2]
      : parts[1];
  final cohort = academy.cohortById(cohortId);
  final cohortLabel = cohort?.name.split(' - ').first ?? cohortId;
  crumbs.add(
    BreadcrumbSegment(label: cohortLabel, route: '/academy/cohort/$cohortId'),
  );
  final studentIndex = parts.indexOf('student');
  if (studentIndex >= 0 && parts.length > studentIndex + 1) {
    final studentId = parts[studentIndex + 1];
    final student = academy.studentById(cohortId, studentId);
    crumbs.add(
      BreadcrumbSegment(
        label: student?.name ?? studentId,
        route: '/academy/cohort/$cohortId/student/$studentId',
      ),
    );
  }
  return crumbs;
}

List<BreadcrumbSegment> _studioBreadcrumbs(List<String> parts, WidgetRef ref) {
  final studio = ref.watch(studioProvider);
  final crumbs = <BreadcrumbSegment>[
    const BreadcrumbSegment(label: 'Studio', route: '/studio'),
  ];
  if (parts.length == 1) {
    return crumbs;
  }
  if (parts[1] == 'portfolio') {
    return [
      ...crumbs,
      const BreadcrumbSegment(label: 'Portfolio', route: '/studio/portfolio'),
    ];
  }
  if (parts[1] == 'calculator') {
    return [
      ...crumbs,
      const BreadcrumbSegment(
        label: 'Deal Calculator',
        route: '/studio/calculator',
      ),
    ];
  }
  final projectId = parts[1] == 'project' && parts.length > 2
      ? parts[2]
      : parts[1];
  final project = studio.projectById(projectId);
  return [
    ...crumbs,
    BreadcrumbSegment(
      label: project?.startupName ?? projectId,
      route: '/studio/project/$projectId',
    ),
  ];
}

List<BreadcrumbSegment> _verifiedBreadcrumbs(
  List<String> parts,
  WidgetRef ref,
) {
  final verified = ref.watch(verifiedProvider);
  final crumbs = <BreadcrumbSegment>[
    const BreadcrumbSegment(label: 'Verified', route: '/verified'),
  ];
  if (parts.length == 1) {
    return crumbs;
  }
  final second = parts[1];
  if (second == 'apply') {
    return [
      ...crumbs,
      const BreadcrumbSegment(label: 'Apply', route: '/verified/apply'),
    ];
  }
  if (second == 'investors') {
    return [
      ...crumbs,
      const BreadcrumbSegment(
        label: 'Investor Dashboard',
        route: '/verified/investors',
      ),
    ];
  }
  if (second == 'deal-room') {
    return [
      ...crumbs,
      const BreadcrumbSegment(label: 'Deal Room', route: '/verified/deal-room'),
    ];
  }
  final founderId = second == 'founder' && parts.length > 2 ? parts[2] : second;
  String? founderName;
  for (final founder in verified.certifiedFounders) {
    if (founder.id == founderId) {
      founderName = founder.founderName;
      break;
    }
  }
  return [
    ...crumbs,
    BreadcrumbSegment(
      label: founderName ?? founderId,
      route: '/verified/founder/$founderId',
    ),
  ];
}
