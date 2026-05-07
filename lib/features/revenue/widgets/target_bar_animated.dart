import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../providers/revenue_provider.dart';

class TargetBarsAnimated extends ConsumerWidget {
  const TargetBarsAnimated({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(revenueProvider).targetBarsVisible;
    return VisibilityDetector(
      key: const ValueKey('target-bars'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > .15) {
          ref.read(revenueProvider.notifier).setTargetsVisible();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            _row('Year 1', '₹1.2 Cr', .22, AppColors.academy, visible),
            _row('Year 2', '₹2.6 Cr', .48, AppColors.studio, visible),
            _row('Year 3', '₹5.4 Cr', 1, AppColors.verified, visible),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String year,
    String amount,
    double target,
    Color color,
    bool visible,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              year,
              style: AppText.body(size: 12, weight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: visible ? target : 0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  color: color,
                  backgroundColor: AppColors.bg3,
                  minHeight: 9,
                  borderRadius: BorderRadius.circular(999),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Text(amount, style: AppText.mono(size: 12, color: color)),
        ],
      ),
    );
  }
}
