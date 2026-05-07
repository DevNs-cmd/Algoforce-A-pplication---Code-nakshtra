import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/models/user.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import 'shell_navigation_scope.dart';

class NavigationRailNav extends ConsumerWidget {
  const NavigationRailNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(navigationProvider);
    final role = ref.watch(authProvider).currentUser?.role;
    final items = [
      ...NavigationMetadata.platformItems,
      ...NavigationMetadata.financeItems,
    ].where((item) => _canSeeRail(item.route, role)).toList();
    final selected = items
        .indexWhere((item) => item.route == nav.currentRoute)
        .clamp(0, items.length - 1)
        .toInt();
    return Container(
      width: 72,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: NavigationRail(
        extended: false,
        minWidth: 72,
        backgroundColor: AppColors.white,
        selectedIndex: selected,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          final scope = ShellNavigationScope.maybeOf(context);
          if (scope != null) {
            scope.goToRoute(items[index].route);
          } else {
            context.go(items[index].route);
          }
        },
        indicatorColor: AppColors.purple,
        labelType: NavigationRailLabelType.none,
        destinations: [
          for (final item in items)
            NavigationRailDestination(
              icon: Tooltip(
                message: item.label,
                child: Icon(item.icon, color: AppColors.textHint),
              ),
              selectedIcon: Tooltip(
                message: item.label,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.purple,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: AppColors.white, size: 20),
                ),
              ),
              label: Text(item.label),
            ),
        ],
      ),
    );
  }
}

bool _canSeeRail(String route, UserRole? role) {
  if (role == UserRole.builder || role == UserRole.investor) {
    return route != '/revenue' && route != '/analytics';
  }
  return true;
}
