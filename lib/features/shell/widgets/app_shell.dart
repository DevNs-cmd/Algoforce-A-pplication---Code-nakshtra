import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/speed_dial_fab.dart';
import '../../academy/widgets/enroll_form_sheet.dart';
import '../../studio/models/build_project.dart';
import '../../studio/providers/studio_provider.dart';
import '../providers/navigation_provider.dart';
import 'bottom_nav.dart';
import 'global_search.dart';
import 'navigation_rail_nav.dart';
import 'notifications_panel.dart';
import 'sidebar_nav.dart';
import 'shell_navigation_scope.dart';
import 'top_bar.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _focusNode = FocusNode();
  late final ValueNotifier<bool> _sidebarCollapsed;

  static const _screenRoutes = [
    '/',
    '/academy',
    '/studio',
    '/verified',
    '/nexus',
    '/revenue',
    '/roadmap',
    '/analytics',
    '/profile',
  ];

  @override
  void initState() {
    super.initState();
    _sidebarCollapsed = ValueNotifier<bool>(
      ref.read(preferencesServiceProvider).getSidebarCollapsed(),
    );
  }

  @override
  void dispose() {
    _sidebarCollapsed.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final route = GoRouterState.of(context).uri.path;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(navigationProvider.notifier).setRoute(route);
      ref.read(preferencesServiceProvider).setActiveScreen(route);
    });

    return ShellNavigationScope(
      currentIndex: widget.navigationShell.currentIndex,
      goToRoute: _goToRoute,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          final router = GoRouter.of(context);
          if (router.canPop()) {
            router.pop();
            return;
          }
          if (widget.navigationShell.currentIndex != 0) {
            widget.navigationShell.goBranch(0);
            return;
          }
          _showExitDialog(context);
        },
        child: Shortcuts(
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.keyK, meta: true):
                _OpenSearchIntent(),
            SingleActivator(LogicalKeyboardKey.keyK, control: true):
                _OpenSearchIntent(),
            SingleActivator(LogicalKeyboardKey.digit1, meta: true):
                _NavigateIntent('/'),
            SingleActivator(LogicalKeyboardKey.digit2, meta: true):
                _NavigateIntent('/academy'),
            SingleActivator(LogicalKeyboardKey.digit3, meta: true):
                _NavigateIntent('/studio'),
            SingleActivator(LogicalKeyboardKey.digit4, meta: true):
                _NavigateIntent('/verified'),
            SingleActivator(LogicalKeyboardKey.digit5, meta: true):
                _NavigateIntent('/nexus'),
            SingleActivator(LogicalKeyboardKey.digit6, meta: true):
                _NavigateIntent('/revenue'),
            SingleActivator(LogicalKeyboardKey.digit7, meta: true):
                _NavigateIntent('/roadmap'),
            SingleActivator(LogicalKeyboardKey.keyN, meta: true):
                _NewActionIntent(),
            SingleActivator(LogicalKeyboardKey.escape): _EscapeIntent(),
          },
          child: Actions(
            actions: {
              _OpenSearchIntent: CallbackAction<_OpenSearchIntent>(
                onInvoke: (_) {
                  showGlobalSearch(context);
                  return null;
                },
              ),
              _NavigateIntent: CallbackAction<_NavigateIntent>(
                onInvoke: (intent) {
                  _goToRoute(intent.route);
                  return null;
                },
              ),
              _NewActionIntent: CallbackAction<_NewActionIntent>(
                onInvoke: (_) {
                  _runContextAction(route);
                  return null;
                },
              ),
              _EscapeIntent: CallbackAction<_EscapeIntent>(
                onInvoke: (_) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).maybePop();
                  }
                  return null;
                },
              ),
            },
            child: Focus(
              focusNode: _focusNode,
              autofocus: true,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < Breakpoints.mobile) {
                    return _mobile(route);
                  }
                  if (constraints.maxWidth < Breakpoints.tablet) {
                    return _tablet();
                  }
                  return _desktop();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mobile(String route) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bg,
      endDrawer: const Drawer(width: 280, child: SidebarNav(drawerMode: true)),
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              mobile: true,
              onMenuPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              onSearchPressed: () => showGlobalSearch(context),
              onNotificationsPressed: () =>
                  showNotificationsPanel(context, ref),
            ),
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) =>
                    _handleSwipe(details.primaryVelocity ?? 0, route),
                child: widget.navigationShell,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
      floatingActionButton: const SpeedDialFab(),
    );
  }

  Widget _tablet() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: const SpeedDialFab(),
      body: SafeArea(
        child: Row(
          children: [
            const NavigationRailNav(),
            Expanded(
              child: Column(
                children: [
                  TopBar(
                    onSearchPressed: () => showGlobalSearch(context),
                    onNotificationsPressed: () =>
                        showNotificationsPanel(context, ref),
                  ),
                  Expanded(child: widget.navigationShell),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _desktop() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: const SpeedDialFab(),
      body: SafeArea(
        child: Row(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: _sidebarCollapsed,
              builder: (context, collapsed, child) {
                return SidebarNav(
                  collapsed: collapsed,
                  onCollapseToggle: () {
                    HapticFeedback.selectionClick();
                    _sidebarCollapsed.value = !collapsed;
                    ref
                        .read(preferencesServiceProvider)
                        .setSidebarCollapsed(_sidebarCollapsed.value);
                  },
                );
              },
            ),
            Expanded(
              child: Column(
                children: [
                  TopBar(
                    onSearchPressed: () => showGlobalSearch(context),
                    onNotificationsPressed: () =>
                        showNotificationsPanel(context, ref),
                  ),
                  Expanded(child: widget.navigationShell),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToRoute(String route) {
    final index = _routeIndex(route);
    if (_isBranchRoot(route)) {
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
      return;
    }
    context.go(route);
  }

  bool _isBranchRoot(String route) {
    final index = _routeIndex(route);
    return index >= 0 &&
        index < _screenRoutes.length &&
        _screenRoutes[index] == route;
  }

  void _showQuickBuildSheet(BuildStatus status) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            18,
            18,
            MediaQuery.viewInsetsOf(context).bottom + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Startup name',
                  helperText: 'Quick-add a Studio build into Discovery.',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  ref
                      .read(studioProvider.notifier)
                      .addQuickProject(status, controller.text);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Build'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _runContextAction(String route) {
    if (route.startsWith('/academy')) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => const EnrollFormSheet(),
      );
      return;
    }
    if (route.startsWith('/studio')) {
      _showQuickBuildSheet(BuildStatus.discovery);
      return;
    }
    if (route.startsWith('/verified')) {
      context.push('/verified/apply');
      return;
    }
    if (route.startsWith('/nexus')) {
      context.push('/nexus/builder');
      return;
    }
    showGlobalSearch(context);
  }

  void _handleSwipe(double velocity, String route) {
    if (velocity.abs() < 240) {
      return;
    }
    final index = _routeIndex(route);
    final next = velocity < 0 ? index + 1 : index - 1;
    if (next >= 0 && next < _screenRoutes.length) {
      HapticFeedback.selectionClick();
      _goToRoute(_screenRoutes[next]);
    }
  }

  int _routeIndex(String route) {
    final parts = route.split('/').where((part) => part.isNotEmpty).toList();
    final base = route == '/' || parts.isEmpty ? '/' : '/${parts.first}';
    final index = _screenRoutes.indexOf(base);
    return index < 0 ? 0 : index;
  }

  void _showExitDialog(BuildContext ctx) {
    showDialog<void>(
      context: ctx,
      builder: (dialogContext) => AlertDialog(
        title: Text('Exit AlgoForce AI?', style: AppText.heading(size: 18)),
        content: Text('Are you sure you want to exit?', style: AppText.body()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          const TextButton(
            onPressed: SystemNavigator.pop,
            child: Text('Exit', style: TextStyle(color: AppColors.verified)),
          ),
        ],
      ),
    );
  }
}

class _OpenSearchIntent extends Intent {
  const _OpenSearchIntent();
}

class _NavigateIntent extends Intent {
  const _NavigateIntent(this.route);
  final String route;
}

class _NewActionIntent extends Intent {
  const _NewActionIntent();
}

class _EscapeIntent extends Intent {
  const _EscapeIntent();
}
