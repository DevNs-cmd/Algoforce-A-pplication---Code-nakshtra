import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/astronaut_widget.dart';
import '../services/auth_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..forward();
    unawaited(_routeAfterIntro());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _routeAfterIntro() async {
    await Future<void>.delayed(const Duration(milliseconds: 2400));
    if (!mounted) {
      return;
    }
    final prefs = ref.read(preferencesServiceProvider);
    final auth = ref.read(authServiceProvider);
    final firstLaunch = !prefs.getOnboardingComplete();
    if (firstLaunch) {
      context.go('/onboarding');
      return;
    }
    final valid = await auth.isSessionValid();
    if (!mounted) {
      return;
    }
    context.go(valid ? '/' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AstronautWidget(size: 116)
                .animate(controller: reduceMotion ? null : _controller)
                .slideY(
                  begin: -.3,
                  end: 0,
                  delay: 200.ms,
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(delay: 120.ms, duration: 180.ms),
            const SizedBox(height: AppDimensions.space24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle(
                  style: AppText.display(size: 34, color: AppColors.navy),
                  child: AnimatedTextKit(
                    isRepeatingAnimation: false,
                    totalRepeatCount: 1,
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'AlgoForce',
                        speed: const Duration(milliseconds: 62),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.space8),
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(.36, .44, curve: Curves.elasticOut),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space8,
                      vertical: AppDimensions.space4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.purple,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radius8,
                      ),
                    ),
                    child: Text(
                      'AI',
                      style: AppText.body(
                        size: 13,
                        color: AppColors.white,
                        weight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space12),
            Text(
              'Your Startup Operating System',
              style: AppText.body(size: 16, color: AppColors.textMuted),
            ).animate().fadeIn(delay: 1400.ms, duration: 300.ms),
            const SizedBox(height: AppDimensions.space28),
            const _LoadingDots().animate().fadeIn(delay: 1800.ms),
            const SizedBox(height: AppDimensions.space14),
            Text(
              AppStrings.operatingThesis,
              textAlign: TextAlign.center,
              style: AppText.body(size: 12, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
                width: AppDimensions.space8,
                height: AppDimensions.space8,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space4,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.purple,
                  shape: BoxShape.circle,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .moveY(
                begin: 0,
                end: -8,
                delay: Duration(milliseconds: i * 150),
                duration: 300.ms,
                curve: Curves.easeOut,
              )
              .then()
              .moveY(begin: -8, end: 0, duration: 300.ms),
      ],
    );
  }
}
