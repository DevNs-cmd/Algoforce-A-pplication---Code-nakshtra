import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/tag_pill.dart';

class TechStackPills extends StatelessWidget {
  const TechStackPills({super.key, required this.stack});

  final List<String> stack;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in stack) TagPill(label: item, color: AppColors.studio),
      ],
    );
  }
}
