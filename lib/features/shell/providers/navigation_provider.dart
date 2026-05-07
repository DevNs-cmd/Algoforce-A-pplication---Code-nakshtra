import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_icons.dart';

final navigationProvider =
    StateNotifierProvider<NavigationController, NavigationState>(
      (ref) => NavigationController(),
    );

class NavigationState {
  const NavigationState({
    required this.currentRoute,
    required this.topBarTitle,
    required this.topBarTag,
    required this.ghostLabel,
    required this.primaryLabel,
  });

  final String currentRoute;
  final String topBarTitle;
  final String topBarTag;
  final String ghostLabel;
  final String primaryLabel;

  NavigationState copyWith({String? currentRoute}) {
    return NavigationMetadata.forRoute(currentRoute ?? this.currentRoute);
  }
}

class NavigationController extends StateNotifier<NavigationState> {
  NavigationController() : super(NavigationMetadata.forRoute('/'));

  void setRoute(String route) {
    final next = NavigationMetadata.forRoute(route);
    if (next.currentRoute != state.currentRoute) {
      state = next;
    }
  }
}

class NavigationItem {
  const NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String route;
  final String? badge;
}

class NavigationMetadata {
  const NavigationMetadata._();

  static const platformItems = [
    NavigationItem(icon: AppIcons.overview, label: 'Overview', route: '/'),
    NavigationItem(
      icon: AppIcons.academy,
      label: 'Academy',
      route: '/academy',
      badge: 'Active',
    ),
    NavigationItem(
      icon: AppIcons.studio,
      label: 'Studio',
      route: '/studio',
      badge: 'Active',
    ),
    NavigationItem(
      icon: AppIcons.verified,
      label: 'VerifiedTM',
      route: '/verified',
    ),
    NavigationItem(
      icon: AppIcons.nexus,
      label: 'Nexus AI',
      route: '/nexus',
      badge: 'Beta',
    ),
  ];

  static const financeItems = [
    NavigationItem(icon: AppIcons.revenue, label: 'Revenue', route: '/revenue'),
    NavigationItem(
      icon: AppIcons.analytics,
      label: 'Analytics',
      route: '/analytics',
      badge: 'BI',
    ),
    NavigationItem(icon: AppIcons.roadmap, label: 'Roadmap', route: '/roadmap'),
  ];

  static NavigationState forRoute(String route) {
    final parts = route.split('/').where((part) => part.isNotEmpty).toList();
    final base = route == '/' || parts.isEmpty ? '/' : '/${parts.first}';
    return switch (base) {
      '/' => const NavigationState(
        currentRoute: '/',
        topBarTitle: 'Overview',
        topBarTag: 'Live OS',
        ghostLabel: 'Open traction',
        primaryLabel: 'Start cohort',
      ),
      '/academy' => const NavigationState(
        currentRoute: '/academy',
        topBarTitle: 'Academy',
        topBarTag: 'Builder Training',
        ghostLabel: 'View cohorts',
        primaryLabel: 'Enroll student',
      ),
      '/studio' => const NavigationState(
        currentRoute: '/studio',
        topBarTitle: 'Studio',
        topBarTag: 'MVP Builds',
        ghostLabel: 'Calculator',
        primaryLabel: 'Save deal',
      ),
      '/verified' => const NavigationState(
        currentRoute: '/verified',
        topBarTitle: 'VerifiedTM',
        topBarTag: 'Founder Trust',
        ghostLabel: 'Pending queue',
        primaryLabel: 'Apply now',
      ),
      '/nexus' => const NavigationState(
        currentRoute: '/nexus',
        topBarTitle: 'Nexus AI',
        topBarTag: 'Vibe Coding',
        ghostLabel: 'History',
        primaryLabel: 'Open builder',
      ),
      '/revenue' => const NavigationState(
        currentRoute: '/revenue',
        topBarTitle: 'Revenue',
        topBarTag: 'Targets',
        ghostLabel: 'Toggle streams',
        primaryLabel: 'Base case',
      ),
      '/analytics' => const NavigationState(
        currentRoute: '/analytics',
        topBarTitle: 'Analytics',
        topBarTag: 'Business Intelligence',
        ghostLabel: 'Refresh',
        primaryLabel: 'Export',
      ),
      '/roadmap' => const NavigationState(
        currentRoute: '/roadmap',
        topBarTitle: 'Roadmap',
        topBarTag: '2030 Vision',
        ghostLabel: 'Milestones',
        primaryLabel: 'Next phase',
      ),
      '/profile' => const NavigationState(
        currentRoute: '/profile',
        topBarTitle: 'Profile',
        topBarTag: 'Settings',
        ghostLabel: 'Privacy',
        primaryLabel: 'Save',
      ),
      _ => const NavigationState(
        currentRoute: '/',
        topBarTitle: 'Overview',
        topBarTag: 'Live OS',
        ghostLabel: 'Open traction',
        primaryLabel: 'Start cohort',
      ),
    };
  }
}
