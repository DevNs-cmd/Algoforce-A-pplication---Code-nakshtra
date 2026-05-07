import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../shared/widgets/astronaut_widget.dart';
import '../theme/app_colors.dart';

class AstroLoader extends StatefulWidget {
  const AstroLoader({super.key, this.size = 72});

  final double size;

  @override
  State<AstroLoader> createState() => _AstroLoaderState();
}

class _AstroLoaderState extends State<AstroLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _OrbitPainter(progress: _controller.value),
            child: Center(
              child: Transform.rotate(
                angle: _controller.value * math.pi * 2,
                child: AstronautWidget(size: widget.size * .42),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .38;
    final orbit = Paint()
      ..color = AppColors.border2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, orbit);

    final colors = [
      AppColors.purple,
      AppColors.academy,
      AppColors.nexus,
      AppColors.verified,
    ];
    for (var i = 0; i < colors.length; i++) {
      final angle =
          (progress * (1 + i * .16) + i / colors.length) * math.pi * 2;
      final dot = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawCircle(dot, 3.2 + i * .35, Paint()..color = colors[i]);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
