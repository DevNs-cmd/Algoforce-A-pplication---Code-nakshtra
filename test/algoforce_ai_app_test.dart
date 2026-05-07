import 'package:algoforce_ai_app/app.dart';
import 'package:algoforce_ai_app/core/router/app_router.dart';
import 'package:algoforce_ai_app/core/services/preferences_service.dart';
import 'package:algoforce_ai_app/features/auth/models/user.dart';
import 'package:algoforce_ai_app/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('boots the AlgoForce AI operating shell', (tester) async {
    final defaultErrorBuilder = ErrorWidget.builder;
    addTearDown(() {
      ErrorWidget.builder = defaultErrorBuilder;
    });
    final user = AlgoUser(
      id: 'test-user',
      name: 'AlgoForce AI',
      email: 'founder@algoforce.ai',
      phone: '9876543210',
      role: UserRole.admin,
      createdAt: DateTime(2026),
      isEmailVerified: true,
      isPhoneVerified: true,
      preferences: const {},
    );
    SharedPreferences.setMockInitialValues({
      PreferencesService.onboardingCompleteKey: true,
      AuthService.userKey: user.encode(),
      AuthService.tokenKey: 'test-token',
      AuthService.sessionKey: DateTime(2099).toIso8601String(),
    });
    final prefs = await SharedPreferences.getInstance();
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const AlgoForceApp(),
      ),
    );
    await tester.pumpAndSettle();
    ErrorWidget.builder = defaultErrorBuilder;

    expect(find.text('AlgoForce AI'), findsWidgets);
    expect(find.text('Overview'), findsWidgets);

    final router = AppRouter.router;
    for (final path in const [
      '/',
      '/academy',
      '/academy/leaderboard',
      '/academy/progress-board',
      '/academy/isa-calculator',
      '/studio',
      '/studio/portfolio',
      '/studio/calculator',
      '/verified',
      '/verified/apply',
      '/verified/investors',
      '/verified/deal-room',
      '/nexus',
      '/nexus/builder',
      '/revenue',
      '/roadmap',
      '/analytics',
      '/profile',
    ]) {
      router.go(path);
      await tester.pump(const Duration(milliseconds: 350));
      final exception = tester.takeException();
      expect(exception, isNull, reason: path);
    }

    for (final pair in const [
      ('/academy', '/academy/cohort/c1'),
      ('/academy', '/academy/cohort/c1/student/s1'),
      ('/studio', '/studio/project/p1'),
      ('/verified', '/verified/founder/f1'),
    ]) {
      router.go(pair.$1);
      await tester.pump(const Duration(milliseconds: 350));
      router.push(pair.$2);
      await tester.pump(const Duration(milliseconds: 350));
      expect(router.canPop(), isTrue, reason: pair.$2);
      router.pop();
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.takeException(), isNull, reason: 'back from ${pair.$2}');
    }
    addTearDown(() => tester.binding.setSurfaceSize(null));
  });
}
