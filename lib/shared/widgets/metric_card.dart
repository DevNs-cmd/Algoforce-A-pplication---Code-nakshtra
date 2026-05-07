import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  final String label;
  final String value;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppText.body(
              size: 10,
              color: AppColors.textHint,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: AppText.mono(size: 22, color: color)),
          const SizedBox(height: 3),
          Text(sub, style: AppText.body(size: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
