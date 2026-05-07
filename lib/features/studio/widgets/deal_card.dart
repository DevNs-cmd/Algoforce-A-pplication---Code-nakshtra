import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../models/build_project.dart';
import '../models/deal.dart';

class DealCard extends StatelessWidget {
  const DealCard({super.key, required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  deal.founderName,
                  style: AppText.body(weight: FontWeight.w800),
                ),
              ),
              TagPill(label: deal.type.name, color: _dealColor(deal.type)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${Formatters.inr(deal.cashAmount)} cash • ${deal.equityPercent.toStringAsFixed(1)}% equity',
            style: AppText.mono(size: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          Text(
            '${deal.status} on ${Formatters.shortDate(deal.signedDate)}',
            style: AppText.body(size: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Color _dealColor(DealType type) {
    return switch (type) {
      DealType.cash => AppColors.nexus,
      DealType.equity => AppColors.studio,
      DealType.hybrid => AppColors.academy,
    };
  }
}
