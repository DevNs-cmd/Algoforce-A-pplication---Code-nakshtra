import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/responsive_grid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../providers/nexus_provider.dart';

class TemplateLibrary extends ConsumerWidget {
  const TemplateLibrary({super.key});

  static const templates = [
    (
      'SaaS Landing Page',
      'Build a SaaS landing page with hero, features, pricing, and waitlist form',
      Icons.web_rounded,
      ['React', 'Pricing'],
    ),
    (
      'Dashboard UI',
      'Build an analytics dashboard with sidebar nav, metric cards, and charts',
      Icons.dashboard_rounded,
      ['Charts', 'Admin'],
    ),
    (
      'E-commerce Store',
      'Build a product listing page with filters, cart, and checkout',
      Icons.shopping_bag_rounded,
      ['Cart', 'Checkout'],
    ),
    (
      'Blog Platform',
      'Build a blog with post list, post detail, and comment section',
      Icons.article_rounded,
      ['CMS', 'Comments'],
    ),
    (
      'Auth System',
      'Build a login and signup flow with form validation and JWT handling',
      Icons.lock_rounded,
      ['JWT', 'Forms'],
    ),
    (
      'REST API Client',
      'Build a REST API client component with request/response display',
      Icons.api_rounded,
      ['API', 'Debug'],
    ),
    (
      'Kanban Board',
      'Build a drag-and-drop Kanban board with 4 status columns',
      Icons.view_kanban_rounded,
      ['DnD', 'Workflow'],
    ),
    (
      'Portfolio Site',
      'Build a developer portfolio with projects, skills, and contact form',
      Icons.badge_rounded,
      ['Portfolio', 'Contact'],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ResponsiveGridDelegate.crossAxisCount(
      context,
      mobileCount: 1,
      tabletCount: 2,
      desktopCount: 4,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - (count - 1) * 10) / count;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final template in templates)
              SizedBox(
                width: width,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () =>
                      ref.read(nexusProvider.notifier).setPrompt(template.$2),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(template.$3, color: AppColors.nexus),
                        const SizedBox(height: 8),
                        Text(
                          template.$1,
                          style: AppText.body(weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final tag in template.$4)
                              TagPill(label: tag, color: AppColors.nexus),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
