import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../providers/roadmap_models.dart';

class GanttChart extends StatelessWidget {
  const GanttChart({super.key, required this.phases});

  final List<Phase> phases;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: CustomPaint(
        painter: _GanttPainter(phases),
        child: Semantics(
          label:
              'Gantt chart showing four phases across months one through twelve.',
        ),
      ),
    );
  }
}

class _GanttPainter extends CustomPainter {
  const _GanttPainter(this.phases);

  final List<Phase> phases;

  @override
  void paint(Canvas canvas, Size size) {
    final label = TextPainter(textDirection: TextDirection.ltr);
    const chartLeft = 120.0;
    final rowHeight = (size.height - 30) / phases.length;
    final monthWidth = (size.width - chartLeft) / 12;
    for (var month = 1; month <= 12; month++) {
      final x = chartLeft + monthWidth * (month - 1);
      canvas.drawLine(
        Offset(x, 20),
        Offset(x, size.height),
        Paint()..color = AppColors.border,
      );
      label.text = TextSpan(
        text: '$month',
        style: AppText.mono(size: 10, color: AppColors.textHint),
      );
      label.layout();
      label.paint(canvas, Offset(x + 4, 0));
    }
    final currentX = chartLeft + monthWidth * 4;
    final dash = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 1.4;
    for (var y = 20.0; y < size.height; y += 10) {
      canvas.drawLine(Offset(currentX, y), Offset(currentX, y + 5), dash);
    }
    for (var i = 0; i < phases.length; i++) {
      final y = 28 + i * rowHeight;
      label.text = TextSpan(
        text: phases[i].title,
        style: AppText.body(
          size: 11,
          color: AppColors.navy,
          weight: FontWeight.w800,
        ),
      );
      label.layout(maxWidth: chartLeft - 10);
      label.paint(canvas, Offset(0, y + 8));
      final startMonth = i * 3 + 1;
      final endMonth = startMonth + 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          chartLeft + monthWidth * (startMonth - 1),
          y + 6,
          monthWidth * (endMonth - startMonth + 1) - 8,
          24,
        ),
        const Radius.circular(7),
      );
      final color = [
        AppColors.academy,
        AppColors.verified,
        AppColors.nexus,
        AppColors.studio,
      ][i % 4];
      canvas.drawRRect(rect, Paint()..color = color.withValues(alpha: .18));
      canvas.drawRRect(
        rect,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GanttPainter oldDelegate) =>
      oldDelegate.phases != phases;
}
