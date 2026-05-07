import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/astro_loader.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: loading
          ? null
          : () {
              HapticFeedback.lightImpact();
              onPressed?.call();
            },
      icon: loading
          ? const SizedBox(width: 18, height: 18, child: AstroLoader(size: 18))
          : Icon(icon ?? Icons.arrow_forward_rounded, size: 17),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.purple,
        disabledBackgroundColor: AppColors.purple.withValues(alpha: .6),
        foregroundColor: AppColors.white,
        textStyle: AppText.body(
          size: 13,
          color: AppColors.white,
          weight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }
}
