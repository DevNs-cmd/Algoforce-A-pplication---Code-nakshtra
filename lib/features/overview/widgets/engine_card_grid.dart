import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/responsive_grid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/engine_card.dart';

class EngineCardGrid extends StatelessWidget {
  const EngineCardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          EngineCard(
            title: 'Academy',
            description: 'Cohorts that train builders on real MVP missions.',
            metric: '~80%',
            color: AppColors.academy,
            icon: const Icon(
              Icons.change_history_rounded,
              color: AppColors.academy,
            ),
            onTap: () => context.go('/academy'),
          ),
          EngineCard(
            title: 'Studio',
            description:
                'Founder MVP builds with cash, equity, or hybrid deals.',
            metric: r'$5-10K',
            color: AppColors.studio,
            icon: const Icon(Icons.diamond_rounded, color: AppColors.studio),
            onTap: () => context.go('/studio'),
          ),
          EngineCard(
            title: 'Verified',
            description: 'A trust layer for founders, investors, and partners.',
            metric: '~87%',
            color: AppColors.verified,
            icon: const Icon(Icons.adjust_rounded, color: AppColors.verified),
            onTap: () => context.go('/verified'),
          ),
          EngineCard(
            title: 'Nexus AI',
            description: 'Internal AI builder that accelerates delivery loops.',
            metric: '3-4x',
            color: AppColors.nexus,
            icon: Text('AI', style: AppText.mono(color: AppColors.nexus)),
            onTap: () => context.go('/nexus'),
          ),
        ];
        final count = ResponsiveGridDelegate.crossAxisCount(
          context,
          mobileCount: 2,
          tabletCount: 2,
          desktopCount: 4,
        );
        final width = (constraints.maxWidth - (count - 1) * 12) / count;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: ResponsiveGridDelegate.of(
            context,
            mobileCount: 2,
            tabletCount: 2,
            desktopCount: 4,
            childAspectRatio: width / 210,
          ),
          itemBuilder: (context, index) => cards[index],
        );
      },
    );
  }
}
