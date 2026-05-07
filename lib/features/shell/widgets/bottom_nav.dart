import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/logo_widget.dart';
import '../../auth/models/user.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import 'shell_navigation_scope.dart';

class BottomNav extends ConsumerWidget {
  const BottomNav({super.key});

  static final _primaryItems = [
    NavigationMetadata.platformItems[0],
    NavigationMetadata.platformItems[1],
    NavigationMetadata.platformItems[2],
    NavigationMetadata.platformItems[3],
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(navigationProvider);
    final role = ref.watch(authProvider).currentUser?.role;
    final primaryItems = _primaryItems
        .where((item) => _canSeeMobile(item.route, role))
        .toList();
    var index = primaryItems.indexWhere(
      (item) => item.route == nav.currentRoute,
    );
    if (index < 0) {
      index = primaryItems.length;
    }
    return SafeArea(
      top: false,
      child: NavigationBar(
        selectedIndex: index.clamp(0, primaryItems.length).toInt(),
        onDestinationSelected: (i) {
          HapticFeedback.selectionClick();
          if (i == primaryItems.length) {
            _openMore(context);
            return;
          }
          final route = primaryItems[i].route;
          final scope = ShellNavigationScope.maybeOf(context);
          if (scope != null) {
            scope.goToRoute(route);
          } else {
            context.go(route);
          }
        },
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.purple4,
        destinations: [
          for (final item in primaryItems)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.icon, color: AppColors.purple),
              label: item.label.replaceAll('TM', ''),
            ),
          const NavigationDestination(
            icon: Icon(Icons.more_horiz_rounded),
            selectedIcon: Icon(
              Icons.more_horiz_rounded,
              color: AppColors.purple,
            ),
            label: 'More',
          ),
        ],
      ),
    );
  }

  void _openMore(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (context) {
        final role = ProviderScope.containerOf(
          context,
        ).read(authProvider).currentUser?.role;
        final items = [
          NavigationMetadata.platformItems[4],
          ...NavigationMetadata.financeItems,
        ].where((item) => _canSeeMobile(item.route, role)).toList();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border2,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const LogoWidget(compact: true),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AlgoForce AI',
                          style: AppText.body(weight: FontWeight.w800),
                        ),
                        Text(
                          'Founder OS controls',
                          style: AppText.body(
                            size: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final item in items)
                ListTile(
                  leading: Icon(item.icon, color: AppColors.purple),
                  title: Text(item.label),
                  trailing: const Icon(Icons.arrow_forward_rounded, size: 18),
                  onTap: () {
                    Navigator.of(context).pop();
                    final scope = ShellNavigationScope.maybeOf(context);
                    if (scope != null) {
                      scope.goToRoute(item.route);
                    } else {
                      context.go(item.route);
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

bool _canSeeMobile(String route, UserRole? role) {
  if (role == UserRole.builder || role == UserRole.investor) {
    return route != '/revenue' && route != '/analytics';
  }
  return true;
}
