import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

enum StepNodeState { done, active, upcoming }

class StepFlowWidget extends StatelessWidget {
  const StepFlowWidget({
    super.key,
    required this.steps,
    required this.activeIndex,
    this.doneColor = AppColors.academy,
  });

  final List<String> steps;
  final int activeIndex;
  final Color doneColor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            _StepNode(
                  number: i + 1,
                  label: steps[i],
                  state: i < activeIndex
                      ? StepNodeState.done
                      : (i == activeIndex
                            ? StepNodeState.active
                            : StepNodeState.upcoming),
                  doneColor: doneColor,
                )
                .animate(delay: Duration(milliseconds: i * 80))
                .scale(
                  begin: const Offset(.7, .7),
                  end: const Offset(1, 1),
                  duration: 300.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 200.ms),
            if (i != steps.length - 1)
              Container(width: 52, height: 1, color: AppColors.border2),
          ],
        ],
      ),
    );
  }
}

class _StepNode extends StatefulWidget {
  const _StepNode({
    required this.number,
    required this.label,
    required this.state,
    required this.doneColor,
  });

  final int number;
  final String label;
  final StepNodeState state;
  final Color doneColor;

  @override
  State<_StepNode> createState() => _StepNodeState();
}

class _StepNodeState extends State<_StepNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.state == StepNodeState.done;
    final isActive = widget.state == StepNodeState.active;
    final fill = isDone
        ? AppColors.academyL
        : (isActive ? AppColors.purple : AppColors.white);
    final text = isDone
        ? AppColors.academyD
        : (isActive ? AppColors.white : AppColors.textHint);
    final border = isDone
        ? widget.doneColor
        : (isActive ? AppColors.purple : AppColors.border2);
    return SizedBox(
      width: 82,
      child: Column(
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isActive)
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) {
                      return Opacity(
                        opacity: .6 * (1 - _pulse.value),
                        child: Transform.scale(
                          scale: 1 + _pulse.value * .3,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.purple.withValues(alpha: .45),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: fill,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: border,
                      width: isActive ? 1.8 : 1.5,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.purple.withValues(alpha: .28),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : const [],
                  ),
                  child: Center(
                    child: Text(
                      '${widget.number}',
                      style: AppText.mono(size: 13, color: text),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(size: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
