import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/margin_bar.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../providers/revenue_models.dart';

class StreamBreakdownCard extends StatelessWidget {
  const StreamBreakdownCard({
    super.key,
    required this.stream,
    required this.onChanged,
  });

  final RevenueStream stream;
  final ValueChanged<bool> onChanged;

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
                  stream.name,
                  style: AppText.body(weight: FontWeight.w800),
                ),
              ),
              stream.critical
                  ? const Tooltip(
                      message: 'Critical path stream',
                      child: Icon(
                        Icons.lock_rounded,
                        color: AppColors.textHint,
                        size: 18,
                      ),
                    )
                  : Switch(
                      value: stream.active,
                      activeThumbColor: stream.color,
                      onChanged: onChanged,
                    ),
            ],
          ),
          const SizedBox(height: 6),
          TagPill(label: stream.when, color: stream.color),
          const SizedBox(height: 10),
          Text(
            stream.scale,
            style: AppText.body(size: 12, color: AppColors.textMuted),
          ),
          Text(
            stream.perUnit,
            style: AppText.mono(size: 13, color: AppColors.navy),
          ),
          const Spacer(),
          MarginBar(percent: stream.marginPercent, color: stream.color),
        ],
      ),
    );
  }
}
