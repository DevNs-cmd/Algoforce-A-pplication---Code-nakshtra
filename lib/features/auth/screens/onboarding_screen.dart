import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/astronaut_widget.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  final _page = ValueNotifier<int>(0);

  @override
  void dispose() {
    _controller.dispose();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).currentUser;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _page,
              builder: (context, page, child) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: page < 4
                      ? TextButton(
                          onPressed: () => _jumpTo(4),
                          child: const Text('Skip'),
                        )
                      : const SizedBox(height: 48),
                );
              },
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) => _page.value = index,
                children: [
                  _WelcomePage(),
                  const _EnginePage(
                    accent: AppColors.academy,
                    illustration: _StudentIllustration(),
                    title: 'Train Real Builders',
                    body:
                        'Our Academy turns college students into deployed engineers in 12 weeks. Real projects from week 4.',
                    stats: [
                      '300+ Trained',
                      '80% Gross Margin',
                      '₹12.5L per Cohort',
                    ],
                  ),
                  const _EnginePage(
                    accent: AppColors.studio,
                    illustration: _RocketIllustration(),
                    title: 'Build MVPs in 60 Days',
                    body:
                        'AlgoForce becomes your co-founder. Cash + equity deals. Proprietary Nexus AI cuts build time 4x.',
                    stats: [
                      r'$5-10K per build',
                      '82% Margin',
                      '15+ Equity Stakes',
                    ],
                  ),
                  const _EnginePage(
                    accent: AppColors.verified,
                    illustration: _ShieldIllustration(),
                    title: 'The Trust Layer India Needs',
                    body:
                        '5-layer founder verification. Not pay-to-play. Connects certified founders directly to investors.',
                    stats: [
                      '87% Gross Margin',
                      '₹30K per Cert',
                      '95% Success Fee Margin',
                    ],
                  ),
                  _ReadyPage(user: user, onEnter: _enterOs),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ValueListenableBuilder<int>(
                valueListenable: _page,
                builder: (context, page, child) {
                  return Row(
                    children: [
                      if (page > 0)
                        TextButton.icon(
                          onPressed: () => _jumpTo(page - 1),
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Back'),
                        )
                      else
                        const SizedBox(width: 96),
                      const Spacer(),
                      _Dots(page: page),
                      const Spacer(),
                      if (page < 4)
                        ElevatedButton.icon(
                          onPressed: () => _jumpTo(page + 1),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Next'),
                        )
                      else
                        const SizedBox(width: 96),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _jumpTo(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _enterOs() async {
    await ref.read(preferencesServiceProvider).setOnboardingComplete(true);
    if (mounted) {
      context.go('/');
    }
  }
}

class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _PageShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AstronautWidget(size: 200)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(begin: -8, end: 8, duration: 1600.ms),
          const SizedBox(height: AppDimensions.space24),
          DefaultTextStyle(
            textAlign: TextAlign.center,
            style: AppText.display(size: 28, color: AppColors.navy),
            child: AnimatedTextKit(
              isRepeatingAnimation: false,
              animatedTexts: [
                TypewriterAnimatedText(
                  'Welcome to AlgoForce AI',
                  speed: const Duration(milliseconds: 42),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space12),
          Text(
            'Your complete startup operating system',
            textAlign: TextAlign.center,
            style: AppText.body(size: 16, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _EnginePage extends StatelessWidget {
  const _EnginePage({
    required this.accent,
    required this.illustration,
    required this.title,
    required this.body,
    required this.stats,
  });

  final Color accent;
  final Widget illustration;
  final String title;
  final String body;
  final List<String> stats;

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 220, height: 180, child: illustration),
          const SizedBox(height: AppDimensions.space24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.heading(size: 24, color: AppColors.navy),
          ),
          const SizedBox(height: AppDimensions.space12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppText.body(size: 16, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppDimensions.space18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppDimensions.space8,
            runSpacing: AppDimensions.space8,
            children: [
              for (final stat in stats)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space12,
                    vertical: AppDimensions.space8,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(AppDimensions.radius12),
                  ),
                  child: Text(
                    stat,
                    style: AppText.body(
                      size: 12,
                      color: accent,
                      weight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadyPage extends StatelessWidget {
  const _ReadyPage({required this.user, required this.onEnter});

  final AlgoUser? user;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AstronautWidget(size: 220)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(.96, .96),
                end: const Offset(1.04, 1.04),
                duration: 1100.ms,
              ),
          const SizedBox(height: AppDimensions.space24),
          Text(
            "You're all set!",
            style: AppText.display(size: 32, color: AppColors.navy),
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            'Welcome, ${user?.name ?? 'builder'}',
            style: AppText.heading(size: 18, color: AppColors.purple),
          ),
          const SizedBox(height: AppDimensions.space12),
          Text(
            _messageFor(user?.role),
            textAlign: TextAlign.center,
            style: AppText.body(size: 16, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppDimensions.space28),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: onEnter,
              icon: const Icon(Icons.dashboard_rounded),
              label: const Text('Enter the OS'),
            ),
          ),
        ],
      ),
    );
  }

  String _messageFor(UserRole? role) {
    return switch (role) {
      UserRole.builder => 'Check out the Academy to join an active cohort.',
      UserRole.investor =>
        'Browse Verified founders ready for your next check.',
      _ => 'Start by exploring the Studio or apply for Verified certification.',
    };
  }
}

class _PageShell extends StatelessWidget {
  const _PageShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.space28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: child,
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.page});

  final int page;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: i == page ? 22 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: i == page ? AppColors.purple : AppColors.border2,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
      ],
    );
  }
}

class _StudentIllustration extends StatelessWidget {
  const _StudentIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StudentPainter());
  }
}

class _RocketIllustration extends StatelessWidget {
  const _RocketIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _RocketPainter());
  }
}

class _ShieldIllustration extends StatelessWidget {
  const _ShieldIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ShieldPainter());
  }
}

class _StudentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()..color = AppColors.academy;
    final navy = Paint()..color = AppColors.navy;
    final screen = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * .2, size.height * .15, size.width * .6, 72),
      const Radius.circular(12),
    );
    canvas.drawRRect(screen, Paint()..color = AppColors.academyL);
    for (var i = 0; i < 3; i++) {
      final x = size.width * (.28 + i * .18);
      canvas.drawCircle(Offset(x, size.height * .68), 18, navy);
      canvas.drawRect(Rect.fromLTWH(x - 14, size.height * .78, 28, 38), green);
    }
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(size.width * .3, 42 + i * 14, size.width * .4, 5),
        Paint()..color = AppColors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RocketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .48);
    final path = Path()
      ..moveTo(center.dx, 12)
      ..quadraticBezierTo(center.dx + 42, 62, center.dx + 24, 120)
      ..lineTo(center.dx - 24, 120)
      ..quadraticBezierTo(center.dx - 42, 62, center.dx, 12);
    canvas.drawPath(path, Paint()..color = AppColors.studio);
    canvas.drawCircle(center, 16, Paint()..color = AppColors.white);
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - 16, 120)
        ..lineTo(center.dx - 36, 156)
        ..lineTo(center.dx - 4, 136),
      Paint()..color = AppColors.verified,
    );
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + 16, 120)
        ..lineTo(center.dx + 36, 156)
        ..lineTo(center.dx + 4, 136),
      Paint()..color = AppColors.verified,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 18)
      ..lineTo(size.width * .78, 46)
      ..quadraticBezierTo(size.width * .72, 128, size.width / 2, 158)
      ..quadraticBezierTo(size.width * .28, 128, size.width * .22, 46)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.verifiedL);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = AppColors.verified,
    );
    final check = Path()
      ..moveTo(size.width * .38, 88)
      ..lineTo(size.width * .48, 104)
      ..lineTo(size.width * .66, 72);
    canvas.drawPath(
      check,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.verified,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
