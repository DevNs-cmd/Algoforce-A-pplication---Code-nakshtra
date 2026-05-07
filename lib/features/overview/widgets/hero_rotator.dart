import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../providers/overview_provider.dart';

class HeroRotator extends ConsumerWidget {
  const HeroRotator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(overviewProvider);
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, .3),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                state.phrases[state.currentPhraseIndex],
                key: ValueKey(state.currentPhraseIndex),
                style: AppText.display(size: 38),
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Text(
                AppStrings.overviewSubtitle,
                style: AppText.body(size: 14, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Text(
            'Day ${state.dayCount} of operations',
            style: AppText.mono(size: 11, color: AppColors.textHint),
          ),
        ),
      ],
    );
  }
}
