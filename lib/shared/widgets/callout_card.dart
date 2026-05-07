import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

class CalloutCard extends StatelessWidget {
  const CalloutCard({
    super.key,
    required this.text,
    this.background = AppColors.purple3,
    this.foreground = AppColors.purple2,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: AppText.body(size: 12, color: foreground).copyWith(height: 1.6),
      ),
    );
  }
}
