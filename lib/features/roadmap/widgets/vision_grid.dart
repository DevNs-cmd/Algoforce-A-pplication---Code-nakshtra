import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/animated_counter.dart';

class VisionGrid extends StatelessWidget {
  const VisionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _VisionItem(
        'Builders trained',
        2000,
        '+',
        AppColors.academyL,
        AppColors.academyD,
      ),
      _VisionItem(
        'Companies co-built',
        100,
        '+',
        AppColors.studioL,
        AppColors.studioD,
      ),
      _VisionItem(
        'Funding facilitated',
        50,
        'M+',
        AppColors.verifiedL,
        AppColors.verifiedD,
        prefix: r'$',
      ),
      _VisionItem(
        'Nexus AI users',
        10000,
        '',
        AppColors.nexusL,
        AppColors.nexusD,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth < 680 ? 2 : 4;
        final width = (constraints.maxWidth - (count - 1) * 12) / count;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in items)
              Container(
                width: width,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: item.bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedCounter(
                      value: item.value.toDouble(),
                      prefix: item.prefix,
                      suffix: item.suffix,
                      color: item.color,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      style: AppText.body(
                        size: 12,
                        color: item.color,
                        weight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _VisionItem {
  const _VisionItem(
    this.label,
    this.value,
    this.suffix,
    this.bg,
    this.color, {
    this.prefix = '',
  });

  final String label;
  final int value;
  final String suffix;
  final Color bg;
  final Color color;
  final String prefix;
}
