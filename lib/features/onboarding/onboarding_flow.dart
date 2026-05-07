import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../shared/widgets/logo_widget.dart';
import '../../shared/widgets/primary_button.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _OnboardingPage(
        icon: LogoWidget(),
        title: 'Welcome to your Startup OS',
        body:
            'AlgoForce connects Academy builders, Studio builds, Verified founders, Nexus AI, revenue targets, and roadmap execution.',
      ),
      const _OnboardingPage(
        icon: Icon(Icons.hub_rounded, color: AppColors.purple, size: 54),
        title: 'Three engines compound together',
        body:
            'Academy creates builders, Studio ships MVPs, and Verified turns trust into investor-ready signal.',
      ),
      const _OnboardingPage(
        icon: Icon(
          Icons.dashboard_customize_rounded,
          color: AppColors.nexus,
          size: 54,
        ),
        title: 'Swipe through every operating desk',
        body:
            'Use Overview, Academy, Studio, Verified, Nexus AI, Revenue, and Roadmap as one connected control surface.',
      ),
      _OnboardingPage(
        icon: Lottie.asset(
          'assets/lottie/venture_pulse.json',
          width: 88,
          height: 88,
          repeat: true,
        ),
        title: "You're ready",
        body:
            'Enter the OS and start moving builders, founders, product code, and milestones forward.',
      ),
    ];
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onComplete,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (value) => setState(() => _index = value),
                children: pages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: _index == i ? 24 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _index == i ? AppColors.purple : AppColors.border2,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                label: _index == pages.length - 1
                    ? 'Enter the OS'
                    : 'Get Started',
                icon: _index == pages.length - 1
                    ? Icons.login_rounded
                    : Icons.arrow_forward_rounded,
                onPressed: () {
                  if (_index == pages.length - 1) {
                    widget.onComplete();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final Widget icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: icon,
          ),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.display(size: 34),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Text(
              body,
              textAlign: TextAlign.center,
              style: AppText.body(size: 14, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
