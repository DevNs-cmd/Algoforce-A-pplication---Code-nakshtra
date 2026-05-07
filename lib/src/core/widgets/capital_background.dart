import 'package:flutter/material.dart';

import '../../app/capital_os_theme.dart';

class CapitalBackground extends StatefulWidget {
  const CapitalBackground({super.key});

  @override
  State<CapitalBackground> createState() => _CapitalBackgroundState();
}

class _CapitalBackgroundState extends State<CapitalBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + t * 0.4, -1),
              end: Alignment(1, 1 - t * 0.35),
              colors: const [
                Color(0xFFF9FCFF),
                Color(0xFFEAF5FF),
                Color(0xFFF4EEFF),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: CustomPaint(painter: _SignalPainter(t)),
        );
      },
    );
  }
}

class _SignalPainter extends CustomPainter {
  const _SignalPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = CapitalColors.deepBlue.withValues(alpha: 0.055);
    final purple = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = CapitalColors.purple.withValues(alpha: 0.07);

    for (var i = 0; i < 9; i++) {
      final y = size.height * (0.08 + i * 0.11);
      final path = Path()
        ..moveTo(size.width * (-0.2 + t * 0.18), y)
        ..cubicTo(
          size.width * 0.2,
          y + 34,
          size.width * 0.68,
          y - 38,
          size.width * 1.2,
          y + 14,
        );
      canvas.drawPath(path, i.isEven ? blue : purple);
    }
  }

  @override
  bool shouldRepaint(covariant _SignalPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
