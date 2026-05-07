import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppText.body(
        size: 10,
        color: AppColors.textHint,
        weight: FontWeight.w800,
      ).copyWith(letterSpacing: 1.2),
    );
  }
}
