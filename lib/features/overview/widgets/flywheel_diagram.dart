import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';

class FlywheelDiagram extends StatelessWidget {
  const FlywheelDiagram({super.key});

  static const _nodes = [
    _FlywheelNodeData(
      'Academy',
      'Students become shippable builders.',
      '300+ trained',
      AppColors.academy,
      '/academy',
    ),
    _FlywheelNodeData(
      'Deploy',
      'Builders ship MVP work into Studio.',
      '10 week sprint',
      AppColors.studio,
      '/studio',
    ),
    _FlywheelNodeData(
      'MVP',
      'Founders get validated product leverage.',
      '4 live builds',
      AppColors.studioD,
      '/studio',
    ),
    _FlywheelNodeData(
      'Founders',
      'Certified founders create investable signal.',
      '87 index avg',
      AppColors.verified,
      '/verified',
    ),
    _FlywheelNodeData(
      'Investors',
      'Investor trust creates diligence revenue.',
      '14 intros',
      AppColors.navy,
      '/verified/investors',
    ),
    _FlywheelNodeData(
      'Fees',
      'Revenue funds stronger cohorts and tooling.',
      '₹3.2L live',
      AppColors.nexus,
      '/revenue',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final mode = ResponsiveValue.of<String>(
      context,
      mobile: 'mobile',
      tablet: 'tablet',
      desktop: 'desktop',
    );
    final content = switch (mode) {
      'mobile' => SingleChildScrollView(
        child: Column(
          children: [
            for (var i = 0; i < _nodes.length; i++) ...[
              _FlywheelNode(data: _nodes[i], index: i),
              if (i != _nodes.length - 1) const _Arrow(vertical: true),
            ],
          ],
        ),
      ),
      'tablet' => const SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 980,
          child: AspectRatio(
            aspectRatio: 16 / 4,
            child: _HorizontalFlywheel(nodes: _nodes),
          ),
        ),
      ),
      _ => const AspectRatio(
        aspectRatio: 16 / 4,
        child: _HorizontalFlywheel(nodes: _nodes),
      ),
    };
    return Semantics(
      label:
          'AlgoForce flywheel diagram connecting Academy, Deploy, MVP, Founders, Investors, and Fees.',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: content,
      ),
    );
  }
}

class _HorizontalFlywheel extends StatelessWidget {
  const _HorizontalFlywheel({required this.nodes});

  final List<_FlywheelNodeData> nodes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              for (var i = 0; i < nodes.length; i++) ...[
                Expanded(
                  child: _FlywheelNode(data: nodes[i], index: i),
                ),
                if (i != nodes.length - 1) const _Arrow(),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: CustomPaint(
            painter: _ReturnArcPainter(
              MediaQuery.of(context).disableAnimations ? 1 : 1,
            ),
          ),
        ),
        Text(
          'Revenue attracts stronger founders and students, then repeats.',
          style: AppText.body(size: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _FlywheelNode extends StatefulWidget {
  const _FlywheelNode({required this.data, required this.index});

  final _FlywheelNodeData data;
  final int index;

  @override
  State<_FlywheelNode> createState() => _FlywheelNodeState();
}

class _FlywheelNodeState extends State<_FlywheelNode> {
  final _key = GlobalKey();
  OverlayEntry? _entry;
  bool _hovered = false;

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final node = MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        _showTooltip();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _hideTooltip();
      },
      child: GestureDetector(
        key: _key,
        onTap: () {
          HapticFeedback.lightImpact();
          context.go(widget.data.route);
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          scale: _hovered ? 1.06 : 1,
          child: Container(
            constraints: const BoxConstraints(minHeight: 54),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: widget.data.color.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: widget.data.color, width: 1.4),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.data.name,
              textAlign: TextAlign.center,
              style: AppText.body(
                size: 12,
                color: widget.data.color,
                weight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
    if (disableAnimations) {
      return node;
    }
    return node
        .animate(delay: Duration(milliseconds: widget.index * 100))
        .fadeIn(duration: 200.ms)
        .scaleXY(
          begin: 0,
          end: 1.08,
          duration: 200.ms,
          curve: Curves.easeOutBack,
        )
        .then()
        .scaleXY(begin: 1.08, end: 1, duration: 100.ms);
  }

  void _showTooltip() {
    _hideTooltip();
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context);
    if (box == null) {
      return;
    }
    final position = box.localToGlobal(Offset.zero);
    _entry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: (position.dy - 92).clamp(8, double.infinity).toDouble(),
        child: Material(
          color: Colors.transparent,
          child:
              Container(
                    width: 220,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.navy3,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.navy3.withValues(alpha: .18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.data.name,
                          style: AppText.body(
                            color: AppColors.white,
                            weight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.data.description,
                          style: AppText.body(
                            size: 11,
                            color: AppColors.white.withValues(alpha: .78),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.data.metric,
                          style: AppText.mono(
                            size: 13,
                            color: widget.data.color,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 120.ms)
                  .scaleXY(begin: .96, end: 1, duration: 120.ms),
        ),
      ),
    );
    overlay.insert(_entry!);
  }

  void _hideTooltip() {
    _entry?.remove();
    _entry = null;
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({this.vertical = false});

  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: vertical ? 24 : 30,
      height: vertical ? 34 : 24,
      child: Icon(
        vertical ? Icons.arrow_downward_rounded : Icons.arrow_forward_rounded,
        color: AppColors.textHint,
        size: 18,
      ),
    ).animate().fadeIn(delay: 250.ms, duration: 200.ms);
  }
}

class _ReturnArcPainter extends CustomPainter {
  const _ReturnArcPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textHint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * .92, 8)
      ..quadraticBezierTo(
        size.width * .5,
        size.height * 1.2,
        size.width * .08,
        8,
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      final length = metric.length * progress;
      while (distance < length) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            (distance + 5).clamp(0, length).toDouble(),
          ),
          paint,
        );
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ReturnArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _FlywheelNodeData {
  const _FlywheelNodeData(
    this.name,
    this.description,
    this.metric,
    this.color,
    this.route,
  );

  final String name;
  final String description;
  final String metric;
  final Color color;
  final String route;
}
