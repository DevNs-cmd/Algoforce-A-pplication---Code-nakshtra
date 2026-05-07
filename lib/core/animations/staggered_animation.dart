import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StaggeredAnimation extends StatelessWidget {
  const StaggeredAnimation({
    super.key,
    required this.children,
    this.staggerMs = 80,
    this.childAnimationDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
    this.axis = Axis.vertical,
    this.spacing = 0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<Widget> children;
  final int staggerMs;
  final Duration childAnimationDuration;
  final Curve curve;
  final Axis axis;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final animated = [
      for (var i = 0; i < children.length; i++)
        disableAnimations
            ? children[i]
            : children[i]
                  .animate(delay: Duration(milliseconds: i * staggerMs))
                  .fadeIn(duration: childAnimationDuration, curve: curve)
                  .slideY(
                    begin: .04,
                    end: 0,
                    duration: childAnimationDuration,
                    curve: curve,
                  ),
    ];
    if (axis == Axis.horizontal) {
      return Row(
        crossAxisAlignment: crossAxisAlignment,
        children: _spaced(animated, horizontal: true),
      );
    }
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: _spaced(animated),
    );
  }

  List<Widget> _spaced(List<Widget> items, {bool horizontal = false}) {
    if (spacing <= 0 || items.length < 2) {
      return items;
    }
    return [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0)
          SizedBox(
            width: horizontal ? spacing : 0,
            height: horizontal ? 0 : spacing,
          ),
        items[i],
      ],
    ];
  }
}
