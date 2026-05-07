import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/inline_editable_text.dart';

class UnitEconomics extends StatefulWidget {
  const UnitEconomics({super.key});

  @override
  State<UnitEconomics> createState() => _UnitEconomicsState();
}

class _UnitEconomicsState extends State<UnitEconomics> {
  final values = <String, double>{
    'academyRevenue': 25000,
    'mentorCost': 4500,
    'contentCost': 1200,
    'platformCost': 800,
    'studioRevenue': 500000,
    'builderCost': 180000,
    'oversightCost': 55000,
    'verifiedRevenue': 30000,
    'reviewCost': 6500,
    'verifiedPlatform': 1200,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Unit economics', style: AppText.heading(size: 16)),
          const SizedBox(height: 12),
          _section('Academy per student', 'academyRevenue', [
            'mentorCost',
            'contentCost',
            'platformCost',
          ], ltv: 90000),
          _section('Studio per build', 'studioRevenue', [
            'builderCost',
            'oversightCost',
          ], equityValue: 220000),
          _section('Verified per cert', 'verifiedRevenue', [
            'reviewCost',
            'verifiedPlatform',
          ]),
        ],
      ),
    );
  }

  Widget _section(
    String title,
    String revenueKey,
    List<String> costKeys, {
    double ltv = 0,
    double equityValue = 0,
  }) {
    final revenue = values[revenueKey] ?? 0;
    final cost = costKeys.fold<double>(
      0,
      (sum, key) => sum + (values[key] ?? 0),
    );
    final profit = revenue - cost;
    final margin = revenue == 0 ? 0 : profit / revenue * 100;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.body(weight: FontWeight.w800)),
          const SizedBox(height: 8),
          _editable('Revenue', revenueKey),
          for (final key in costKeys) _editable(_label(key), key),
          if (ltv > 0)
            Text(
              'LTV return path: ${Formatters.inr(ltv)}',
              style: AppText.body(size: 12, color: AppColors.textMuted),
            ),
          if (equityValue > 0)
            Text(
              'Probability-weighted equity: ${Formatters.inr(equityValue)}',
              style: AppText.body(size: 12, color: AppColors.textMuted),
            ),
          const SizedBox(height: 6),
          Text(
            'Gross profit ${Formatters.inr(profit)} - ${margin.round()}% margin',
            style: AppText.mono(
              size: 12,
              color: margin > 50 ? AppColors.academy : AppColors.verified,
            ),
          ),
        ],
      ),
    );
  }

  Widget _editable(String label, String key) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppText.body(size: 12))),
        SizedBox(
          width: 120,
          child: InlineEditableText(
            value: Formatters.inr(values[key] ?? 0),
            style: AppText.mono(size: 12, color: AppColors.navy),
            keyboardType: TextInputType.number,
            onSubmitted: (value) {
              final parsed = double.tryParse(
                value.replaceAll(RegExp(r'[^0-9.]'), ''),
              );
              if (parsed != null) {
                setState(() => values[key] = parsed);
              }
            },
          ),
        ),
      ],
    );
  }

  String _label(String key) {
    return switch (key) {
      'mentorCost' => 'Mentor hours + rate',
      'contentCost' => 'Content',
      'platformCost' => 'Platform',
      'builderCost' => 'Builder cost',
      'oversightCost' => 'Senior oversight',
      'reviewCost' => 'Review time',
      'verifiedPlatform' => 'Platform cost',
      _ => key,
    };
  }
}
