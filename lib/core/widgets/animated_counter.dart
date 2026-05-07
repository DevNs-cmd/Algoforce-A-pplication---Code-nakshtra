import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../theme/app_text.dart';
import '../utils/formatters.dart';

class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.color,
    this.duration = const Duration(milliseconds: 1200),
  });

  final double value;
  final String prefix;
  final String suffix;
  final Color? color;
  final Duration duration;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(
        'counter-${widget.prefix}-${widget.value}-${widget.suffix}',
      ),
      onVisibilityChanged: (info) {
        if (!_visible && info.visibleFraction > 0.1) {
          setState(() => _visible = true);
        }
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _visible ? widget.value : 0),
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Text(
            '${widget.prefix}${Formatters.number(value.round())}${widget.suffix}',
            style: AppText.mono(
              size: 25,
              color:
                  widget.color ??
                  DefaultTextStyle.of(context).style.color ??
                  Colors.black,
            ),
          );
        },
      ),
    );
  }
}
