import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';

class MoatTable extends StatelessWidget {
  const MoatTable({super.key});

  static const rows = [
    ['Live builder training', 'partial', 'cross', 'partial', 'check'],
    ['Ships real MVPs', 'cross', 'check', 'partial', 'check'],
    ['Founder certification', 'cross', 'cross', 'partial', 'check'],
    ['Revenue from day one', 'partial', 'check', 'cross', 'check'],
    ['Equity upside', 'cross', 'partial', 'check', 'check'],
    ['AI build tooling', 'cross', 'partial', 'cross', 'check'],
    ['Tier-2/3 builder access', 'partial', 'cross', 'cross', 'check'],
    ['Investor trust data', 'cross', 'cross', 'partial', 'check'],
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 790,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            _row(const [
              'Capability',
              'Bootcamp',
              'Dev Agency',
              'Accelerator',
              'AlgoForce AITM',
            ], header: true),
            for (final row in rows) _MoatRow(values: row),
          ],
        ),
      ),
    );
  }

  static Widget _row(List<String> values, {bool header = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: header ? AppColors.bg2 : AppColors.white,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < values.length; i++)
            SizedBox(
              width: i == 0 ? 220 : 130,
              child: Text(
                values[i],
                style: header
                    ? AppText.body(
                        size: 12,
                        color: AppColors.navy,
                        weight: FontWeight.w800,
                      )
                    : AppText.body(
                        size: 12,
                        color: i == 4 ? AppColors.navy : AppColors.textMuted,
                        weight: i == 4 ? FontWeight.w800 : FontWeight.w500,
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MoatRow extends StatefulWidget {
  const _MoatRow({required this.values});
  final List<String> values;

  @override
  State<_MoatRow> createState() => _MoatRowState();
}

class _MoatRowState extends State<_MoatRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _hovered ? AppColors.purple4 : AppColors.white,
        child: Row(
          children: [
            SizedBox(
              width: 248,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  widget.values.first,
                  style: AppText.body(size: 12, weight: FontWeight.w600),
                ),
              ),
            ),
            for (var i = 1; i < widget.values.length; i++)
              SizedBox(
                width: 130,
                child: Center(child: _mark(widget.values[i], bold: i == 4)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _mark(String value, {required bool bold}) {
    final text = switch (value) {
      'check' => '✓',
      'cross' => '✗',
      _ => '~',
    };
    final color = switch (value) {
      'check' => AppColors.academy,
      'cross' => AppColors.textHint.withValues(alpha: .45),
      _ => AppColors.purple,
    };
    return Text(
      text,
      style: AppText.body(
        size: 16,
        color: color,
        weight: bold ? FontWeight.w900 : FontWeight.w700,
      ),
    );
  }
}
