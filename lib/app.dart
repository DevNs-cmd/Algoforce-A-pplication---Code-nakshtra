import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/widgets/error_boundary_widget.dart';
import 'features/academy/providers/academy_provider.dart';
import 'features/activity/providers/activity_feed_provider.dart';
import 'features/nexus/providers/nexus_provider.dart';
import 'features/revenue/providers/revenue_provider.dart';
import 'features/roadmap/providers/roadmap_provider.dart';
import 'features/verified/providers/verified_provider.dart';

class AlgoForceApp extends ConsumerStatefulWidget {
  const AlgoForceApp({super.key});

  @override
  ConsumerState<AlgoForceApp> createState() => _AlgoForceAppState();
}

class _AlgoForceAppState extends ConsumerState<AlgoForceApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ErrorWidget.builder = (details) =>
        ErrorBoundaryWidget.friendlyError(details.exception, details.stack, () {
          ref
            ..invalidate(activityFeedProvider)
            ..invalidate(academyProvider)
            ..invalidate(nexusProvider)
            ..invalidate(revenueProvider)
            ..invalidate(roadmapProvider)
            ..invalidate(verifiedProvider);
        });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref
        ..invalidate(activityFeedProvider)
        ..invalidate(academyProvider)
        ..invalidate(nexusProvider)
        ..invalidate(revenueProvider)
        ..invalidate(roadmapProvider)
        ..invalidate(verifiedProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return AnimatedTheme(
      data: themeMode == ThemeMode.dark
          ? AppTheme.darkTheme
          : AppTheme.lightTheme,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: MaterialApp.router(
        title: 'AlgoForce AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
