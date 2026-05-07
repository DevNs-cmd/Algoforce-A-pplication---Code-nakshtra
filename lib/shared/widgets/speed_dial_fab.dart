import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../features/academy/widgets/enroll_form_sheet.dart';
import '../../features/advisor/advisor_sheet.dart';
import '../../features/shell/widgets/shell_navigation_scope.dart';
import '../../features/studio/models/build_project.dart';
import '../../features/studio/providers/studio_provider.dart';

class SpeedDialFab extends ConsumerWidget {
  const SpeedDialFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = GoRouterState.of(context).uri.path;
    final actions = _actionsFor(context, ref, route);
    return SpeedDial(
      icon: Icons.add_rounded,
      activeIcon: Icons.close_rounded,
      backgroundColor: AppColors.purple,
      foregroundColor: AppColors.white,
      spacing: 10,
      spaceBetweenChildren: 8,
      children: [
        for (final action in actions)
          SpeedDialChild(
            child: Icon(action.icon, color: AppColors.purple),
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.purple,
            label: action.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
            onTap: action.onTap,
          ),
      ],
    );
  }

  List<_FabAction> _actionsFor(
    BuildContext context,
    WidgetRef ref,
    String route,
  ) {
    if (route.startsWith('/academy')) {
      return [
        _FabAction(
          Icons.person_add_alt_1_rounded,
          'Enroll Student',
          () => _showEnroll(context),
        ),
        _FabAction(
          Icons.leaderboard_rounded,
          'View Leaderboard',
          () => context.push('/academy/leaderboard'),
        ),
        _FabAction(
          Icons.calculate_rounded,
          'ISA Calculator',
          () => context.push('/academy/isa-calculator'),
        ),
      ];
    }
    if (route.startsWith('/studio')) {
      return [
        _FabAction(
          Icons.handyman_rounded,
          'New Build Project',
          () => _quickBuild(context, ref),
        ),
        _FabAction(
          Icons.calculate_rounded,
          'Deal Calculator',
          () => context.push('/studio/calculator'),
        ),
        _FabAction(
          Icons.folder_rounded,
          'View Portfolio',
          () => context.push('/studio/portfolio'),
        ),
      ];
    }
    if (route.startsWith('/verified')) {
      return [
        _FabAction(
          Icons.note_add_rounded,
          'New Application',
          () => context.push('/verified/apply'),
        ),
        _FabAction(
          Icons.account_balance_rounded,
          'Investor Dashboard',
          () => context.push('/verified/investors'),
        ),
        _FabAction(
          Icons.handshake_rounded,
          'Deal Room',
          () => context.push('/verified/deal-room'),
        ),
      ];
    }
    if (route.startsWith('/nexus')) {
      return [
        _FabAction(
          Icons.smart_toy_rounded,
          'Open Builder',
          () => context.push('/nexus/builder'),
        ),
        _FabAction(
          Icons.view_module_rounded,
          'Templates',
          () => _snack(context, 'Template library is expanded in Nexus.'),
        ),
        _FabAction(
          Icons.history_rounded,
          'Build History',
          () => _snack(context, 'Build history drawer opened.'),
        ),
      ];
    }
    if (route.startsWith('/revenue')) {
      return [
        _FabAction(
          Icons.query_stats_rounded,
          'Revenue Projector',
          () => _snack(context, 'Jumped to the revenue projector.'),
        ),
        _FabAction(
          Icons.payments_rounded,
          'Unit Economics',
          () => _snack(context, 'Unit economics tab selected.'),
        ),
        _FabAction(
          Icons.content_copy_rounded,
          'Export Report',
          () => _snack(context, 'Report copied to clipboard.'),
        ),
      ];
    }
    if (route.startsWith('/roadmap')) {
      return [
        _FabAction(
          Icons.checklist_rounded,
          'Quick Update',
          () => _snack(context, 'Quick update sheet opened.'),
        ),
        _FabAction(
          Icons.calendar_month_rounded,
          'Gantt View',
          () => _snack(context, 'Gantt view selected.'),
        ),
        _FabAction(
          Icons.warning_rounded,
          'View Risks',
          () => _snack(context, 'Risk register selected.'),
        ),
      ];
    }
    return [
      _FabAction(Icons.playlist_add_rounded, 'New Enrollment', () {
        final scope = ShellNavigationScope.maybeOf(context);
        if (scope != null) {
          scope.goToRoute('/academy');
        } else {
          context.go('/academy');
        }
        _showEnroll(context);
      }),
      _FabAction(Icons.rocket_launch_rounded, 'New Build', () {
        final scope = ShellNavigationScope.maybeOf(context);
        if (scope != null) {
          scope.goToRoute('/studio');
        } else {
          context.go('/studio');
        }
        _quickBuild(context, ref);
      }),
      _FabAction(
        Icons.auto_awesome_rounded,
        'Ask Advisor',
        () => showAdvisorSheet(context, ref),
      ),
    ];
  }

  void _showEnroll(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const EnrollFormSheet(),
    );
  }

  void _quickBuild(BuildContext context, WidgetRef ref) {
    ref
        .read(studioProvider.notifier)
        .addQuickProject(BuildStatus.discovery, 'New Studio Build');
    _snack(context, 'New Studio build added to Discovery.');
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _FabAction {
  const _FabAction(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}
