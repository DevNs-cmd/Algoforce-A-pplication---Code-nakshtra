import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/tag_pill.dart';

class PricingCard extends StatelessWidget {
  const PricingCard({
    super.key,
    required this.name,
    required this.price,
    required this.detail,
  });

  final String name;
  final String price;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.nexusL,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.nexus.withValues(alpha: .25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TagPill(label: name, color: AppColors.nexus),
          const SizedBox(height: 12),
          Text(price, style: AppText.mono(size: 24, color: AppColors.nexusD)),
          const SizedBox(height: 6),
          Text(detail, style: AppText.body(size: 12, color: AppColors.nexusD)),
        ],
      ),
    );
  }
}
