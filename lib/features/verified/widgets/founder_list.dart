import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../models/certified_founder.dart';

class FounderList extends StatelessWidget {
  const FounderList({super.key, required this.founders});

  final List<CertifiedFounder> founders;

  @override
  Widget build(BuildContext context) {
    if (founders.isEmpty) {
      return Text(
        'No certified founders yet - be the first to apply.',
        style: AppText.body(color: AppColors.textMuted),
      );
    }
    return Column(
      children: [
        for (final founder in founders)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: ListTile(
              onTap: () => context.push('/verified/founder/${founder.id}'),
              leading: CircleAvatar(
                backgroundColor: AppColors.verifiedL,
                child: Text(
                  _initials(founder.founderName),
                  style: AppText.body(
                    color: AppColors.verifiedD,
                    weight: FontWeight.w800,
                  ),
                ),
              ),
              title: Text(
                founder.founderName,
                style: AppText.body(weight: FontWeight.w800),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${founder.startupName} • ${founder.sector}',
                    style: AppText.body(size: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 7),
                  LinearPercentIndicator(
                    padding: EdgeInsets.zero,
                    percent: (founder.indexScore / 100).clamp(0, 1).toDouble(),
                    lineHeight: 7,
                    animation: true,
                    backgroundColor: AppColors.bg3,
                    progressColor: founder.indexScore > 70
                        ? AppColors.academy
                        : AppColors.verified,
                    barRadius: const Radius.circular(999),
                  ),
                ],
              ),
              trailing: TagPill(
                label: founder.badgeStatus.name,
                color: _statusColor(founder.badgeStatus),
              ),
            ),
          ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
    return parts.take(2).map((part) => part[0]).join();
  }

  Color _statusColor(BadgeStatus status) {
    return switch (status) {
      BadgeStatus.active => AppColors.academy,
      BadgeStatus.expired => const Color(0xFFF97316),
      BadgeStatus.revoked => AppColors.verified,
    };
  }
}
