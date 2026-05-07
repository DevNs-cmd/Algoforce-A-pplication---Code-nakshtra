import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AstronautWidget extends StatelessWidget {
  const AstronautWidget({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _AstronautPainter()),
    );
  }
}

class _AstronautPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 28;
    final stroke = Paint()
      ..color = AppColors.navy3
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * scale
      ..strokeCap = StrokeCap.round;
    final white = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;
    final visor = Paint()
      ..color = const Color(0xFF111111)
      ..style = PaintingStyle.fill;
    final soft = Paint()
      ..color = AppColors.bg3
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * scale;

    final c = Offset(14 * scale, 10 * scale);
    canvas.drawCircle(c, 8.5 * scale, white);
    canvas.drawCircle(c, 8.5 * scale, stroke);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(15.5 * scale, 9 * scale),
        width: 12 * scale,
        height: 9 * scale,
      ),
      visor,
    );
    canvas.drawCircle(
      Offset(18.5 * scale, 6.5 * scale),
      1.6 * scale,
      Paint()..color = Colors.white.withValues(alpha: .9),
    );
    canvas.drawCircle(Offset(4.2 * scale, 10 * scale), 2 * scale, white);
    canvas.drawCircle(Offset(23.8 * scale, 10 * scale), 2 * scale, white);
    canvas.drawCircle(Offset(4.2 * scale, 10 * scale), 2 * scale, stroke);
    canvas.drawCircle(Offset(23.8 * scale, 10 * scale), 2 * scale, stroke);
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(9 * scale, 17 * scale, 10 * scale, 7 * scale),
      Radius.circular(3 * scale),
    );
    canvas.drawRRect(body, white);
    canvas.drawRRect(body, soft);
    canvas.drawLine(
      Offset(9 * scale, 18.5 * scale),
      Offset(5.5 * scale, 21 * scale),
      stroke,
    );
    canvas.drawLine(
      Offset(19 * scale, 18.5 * scale),
      Offset(22.5 * scale, 21 * scale),
      stroke,
    );
    canvas.drawLine(
      Offset(11 * scale, 24 * scale),
      Offset(7 * scale, 26 * scale),
      stroke,
    );
    canvas.drawLine(
      Offset(17 * scale, 24 * scale),
      Offset(21 * scale, 26 * scale),
      stroke,
    );
    canvas.drawCircle(
      Offset(14 * scale, 20.5 * scale),
      1.2 * scale,
      Paint()..color = AppColors.purple,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
