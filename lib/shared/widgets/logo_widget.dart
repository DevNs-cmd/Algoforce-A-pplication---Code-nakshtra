import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import 'astronaut_widget.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AstronautWidget(size: 28),
          if (!compact) ...[
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Algo',
                    style: AppText.heading(size: 16, color: AppColors.navy),
                  ),
                  TextSpan(
                    text: 'Force',
                    style: AppText.heading(size: 16, color: AppColors.purple),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'AI',
                style: AppText.body(
                  size: 9,
                  color: AppColors.white,
                  weight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
