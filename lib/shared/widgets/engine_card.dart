import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

class EngineCard extends StatefulWidget {
  const EngineCard({
    super.key,
    required this.title,
    required this.description,
    required this.metric,
    required this.color,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String description;
  final String metric;
  final Color color;
  final Widget icon;
  final VoidCallback? onTap;

  @override
  State<EngineCard> createState() => _EngineCardState();
}

class _EngineCardState extends State<EngineCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    return MouseRegion(
      onEnter: (_) {
        if (desktop) {
          setState(() => _hovered = true);
          if (!MediaQuery.of(context).disableAnimations) {
            _shimmerController
              ..reset()
              ..forward();
          }
        }
      },
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? widget.color.withValues(alpha: .35)
                : AppColors.border,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: .15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap?.call();
          },
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(height: 3, color: widget.color),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: .13),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: widget.icon),
                    ),
                    const SizedBox(height: 14),
                    Text(widget.title, style: AppText.heading(size: 13)),
                    const SizedBox(height: 6),
                    Text(
                      widget.description,
                      style: AppText.body(size: 12, color: AppColors.textMuted),
                    ),
                    const Spacer(),
                    Text(
                      widget.metric,
                      style: AppText.mono(size: 22, color: widget.color),
                    ),
                  ],
                ),
              ),
              if (_hovered)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      final x = -1 + _shimmerController.value * 2.4;
                      return FractionalTranslation(
                        translation: Offset(x, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 90,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: .36),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
