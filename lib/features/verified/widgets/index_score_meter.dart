import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';

class IndexScoreMeter extends StatelessWidget {
  const IndexScoreMeter({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final color = score < 40
        ? AppColors.verified
        : (score <= 70 ? const Color(0xFFF97316) : AppColors.academy);
    return CircularPercentIndicator(
      radius: 76,
      lineWidth: 12,
      percent: (score / 100).clamp(0, 1).toDouble(),
      animation: true,
      animateFromLastPercent: true,
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: color,
      backgroundColor: color.withValues(alpha: .15),
      center: Text('$score', style: AppText.mono(size: 32, color: color)),
    );
  }
}
