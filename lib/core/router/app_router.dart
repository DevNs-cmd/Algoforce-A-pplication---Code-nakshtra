import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/academy/screens/academy_screen.dart';
import '../../features/academy/screens/cohort_detail_screen.dart';
import '../../features/academy/screens/isa_calculator_screen.dart';
import '../../features/academy/screens/leaderboard_screen.dart';
import '../../features/academy/screens/progress_board_screen.dart';
import '../../features/academy/screens/student_profile_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/auth/models/user.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/otp_verify_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/dealroom/deal_room_screen.dart';
import '../../features/nexus/screens/builder_screen.dart';
import '../../features/nexus/screens/nexus_screen.dart';
import '../../features/overview/screens/overview_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/revenue/screens/revenue_screen.dart';
import '../../features/roadmap/screens/roadmap_screen.dart';
import '../../features/shell/widgets/app_shell.dart';
import '../../features/studio/screens/build_detail_screen.dart';
import '../../features/studio/screens/deal_calculator_screen.dart';
import '../../features/studio/screens/portfolio_screen.dart';
import '../../features/studio/screens/studio_screen.dart';
import '../../features/verified/screens/founder_application_screen.dart';
import '../../features/verified/screens/founder_profile_screen.dart';
import '../../features/verified/screens/investor_dashboard_screen.dart';
import '../../features/verified/screens/verified_screen.dart';
import '../../shared/widgets/primary_button.dart';
import '../services/preferences_service.dart';
import '../widgets/error_boundary_widget.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorOverviewKey = GlobalKey<NavigatorState>(
  debugLabel: 'overview',
);
final _shellNavigatorAcademyKey = GlobalKey<NavigatorState>(
  debugLabel: 'academy',
);
final _shellNavigatorStudioKey = GlobalKey<NavigatorState>(
  debugLabel: 'studio',
);
final _shellNavigatorVerifiedKey = GlobalKey<NavigatorState>(
  debugLabel: 'verified',
);
final _shellNavigatorNexusKey = GlobalKey<NavigatorState>(debugLabel: 'nexus');
final _shellNavigatorRevenueKey = GlobalKey<NavigatorState>(
  debugLabel: 'revenue',
);
final _shellNavigatorRoadmapKey = GlobalKey<NavigatorState>(
  debugLabel: 'roadmap',
);
final _shellNavigatorAnalyticsKey = GlobalKey<NavigatorState>(
  debugLabel: 'analytics',
);
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(
  debugLabel: 'profile',
);

class AppRouter {
  const AppRouter._();

  static final roleAccess = <String, List<UserRole>>{
    '/verified/investors': [UserRole.investor, UserRole.admin],
    '/verified/deal-room': [
      UserRole.investor,
      UserRole.founder,
      UserRole.admin,
    ],
    '/analytics': [UserRole.admin, UserRole.founder],
    '/academy/leaderboard': UserRole.values,
  };

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/otp-verify',
        builder: (context, state) =>
            OtpVerifyScreen(phone: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorOverviewKey,
            routes: [_route('/', const OverviewScreen())],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorAcademyKey,
            routes: [
              _route(
                '/academy',
                const AcademyScreen(),
                routes: [
                  _route(
                    'cohort/:cohortId',
                    null,
                    builder: (context, state) => CohortDetailScreen(
                      cohortId: state.pathParameters['cohortId']!,
                    ),
                    routes: [
                      _route(
                        'student/:studentId',
                        null,
                        builder: (context, state) => StudentProfileScreen(
                          cohortId: state.pathParameters['cohortId']!,
                          studentId: state.pathParameters['studentId']!,
                        ),
                      ),
                    ],
                  ),
                  _route('leaderboard', const LeaderboardScreen()),
                  _route('progress-board', const ProgressBoardScreen()),
                  _route('isa-calculator', const IsaCalculatorScreen()),
                  _route(
                    ':cohortId',
                    null,
                    builder: (context, state) => CohortDetailScreen(
                      cohortId: state.pathParameters['cohortId']!,
                    ),
                    routes: [
                      _route(
                        'student/:studentId',
                        null,
                        builder: (context, state) => StudentProfileScreen(
                          cohortId: state.pathParameters['cohortId']!,
                          studentId: state.pathParameters['studentId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorStudioKey,
            routes: [
              _route(
                '/studio',
                const StudioScreen(),
                routes: [
                  _route(
                    'project/:projectId',
                    null,
                    builder: (context, state) => BuildDetailScreen(
                      projectId: state.pathParameters['projectId']!,
                    ),
                  ),
                  _route('portfolio', const PortfolioScreen()),
                  _route('calculator', const DealCalculatorScreen()),
                  _route(
                    ':projectId',
                    null,
                    builder: (context, state) => BuildDetailScreen(
                      projectId: state.pathParameters['projectId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorVerifiedKey,
            routes: [
              _route(
                '/verified',
                const VerifiedScreen(),
                routes: [
                  _route('apply', const FounderApplicationScreen()),
                  _route('investors', const InvestorDashboardScreen()),
                  _route('deal-room', const DealRoomScreen()),
                  _route(
                    'founder/:founderId',
                    null,
                    builder: (context, state) => FounderProfileScreen(
                      founderId: state.pathParameters['founderId']!,
                    ),
                  ),
                  _route(
                    ':founderId',
                    null,
                    builder: (context, state) => FounderProfileScreen(
                      founderId: state.pathParameters['founderId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorNexusKey,
            routes: [
              _route(
                '/nexus',
                const NexusScreen(),
                routes: [_route('builder', const BuilderScreen())],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorRevenueKey,
            routes: [_route('/revenue', const RevenueScreen())],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorRoadmapKey,
            routes: [_route('/roadmap', const RoadmapScreen())],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorAnalyticsKey,
            routes: [_route('/analytics', const AnalyticsScreen())],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [_route('/profile', const ProfileScreen())],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context, listen: false);
      final auth = container.read(authProvider);
      final prefs = container.read(preferencesServiceProvider);
      final location = state.uri.path;
      final onboardingComplete = prefs.getOnboardingComplete();
      final storedExpiry = prefs.getString(AuthService.sessionKey);
      final hasValidStoredSession =
          storedExpiry != null &&
          (DateTime.tryParse(storedExpiry)?.isAfter(DateTime.now()) ?? false) &&
          prefs.getString(AuthService.userKey) != null;
      final isOnAuth = {
        '/login',
        '/register',
        '/forgot-password',
        '/otp-verify',
        '/onboarding',
      }.contains(location);

      if (location == '/splash') {
        return null;
      }
      if (!auth.isAuthenticated && !hasValidStoredSession) {
        if (location == '/onboarding' && !onboardingComplete) {
          return null;
        }
        return isOnAuth ? null : '/login';
      }
      if ((location == '/login' ||
              location == '/register' ||
              location == '/forgot-password') &&
          !onboardingComplete) {
        return '/onboarding';
      }
      if (isOnAuth && location != '/onboarding') {
        return '/';
      }
      if (location == '/onboarding' && onboardingComplete) {
        return '/';
      }
      final currentUser = auth.currentUser;
      if (currentUser != null) {
        for (final entry in roleAccess.entries) {
          if (location == entry.key || location.startsWith('${entry.key}/')) {
            if (!entry.value.contains(currentUser.role)) {
              return '/';
            }
          }
        }
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.travel_explore_rounded, size: 42),
              const SizedBox(height: 14),
              const Text('This AlgoForce route is not active yet.'),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Back to dashboard',
                icon: Icons.dashboard_rounded,
                onPressed: () => context.go('/'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  static GoRoute _route(
    String path,
    Widget? child, {
    Widget Function(BuildContext, GoRouterState)? builder,
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      routes: routes,
      pageBuilder: (context, state) {
        final pageChild = ErrorBoundaryWidget(
          child: child ?? builder!(context, state),
        );
        return CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 240),
          child: pageChild,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            );
            return FadeTransition(
              opacity: curve,
              child: ScaleTransition(
                scale: Tween<double>(begin: .97, end: 1).animate(curve),
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}
