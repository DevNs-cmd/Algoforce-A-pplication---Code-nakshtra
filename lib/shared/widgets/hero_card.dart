import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/animations/staggered_animation.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.highlight,
    required this.description,
    this.accent = AppColors.purple,
    this.children = const [],
  });

  final String eyebrow;
  final String title;
  final String highlight;
  final String description;
  final Color accent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final headingSize = AppText.headingSize(context);
    final spans = <TextSpan>[];
    final index = title.indexOf(highlight);
    if (index >= 0) {
      spans
        ..add(TextSpan(text: title.substring(0, index)))
        ..add(
          TextSpan(
            text: highlight,
            style: AppText.heading(size: headingSize, color: AppColors.purple),
          ),
        )
        ..add(TextSpan(text: title.substring(index + highlight.length)));
    } else {
      spans.add(TextSpan(text: title));
    }
    final content = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(height: 3, color: accent),
          ),
          Padding(
            padding: ResponsiveValue.of<EdgeInsets>(
              context,
              mobile: const EdgeInsets.all(18),
              tablet: const EdgeInsets.all(22),
              desktop: const EdgeInsets.all(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: AppText.body(
                    size: 10,
                    color: AppColors.textHint,
                    weight: FontWeight.w800,
                  ).copyWith(letterSpacing: 1.2),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: AppText.heading(
                      size: headingSize,
                      color: AppColors.navy3,
                    ),
                    children: spans,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Text(
                    description,
                    style: AppText.body(size: 13, color: AppColors.textMuted),
                  ),
                ),
                if (children.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  StaggeredAnimation(
                    staggerMs: 50,
                    spacing: 10,
                    children: children,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
    if (MediaQuery.of(context).disableAnimations) {
      return content;
    }
    return content
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: .05, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}
