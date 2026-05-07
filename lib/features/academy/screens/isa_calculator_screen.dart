import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/hero_card.dart';
import '../../../shared/widgets/metric_card.dart';

class IsaCalculatorScreen extends StatefulWidget {
  const IsaCalculatorScreen({super.key});

  @override
  State<IsaCalculatorScreen> createState() => _IsaCalculatorScreenState();
}

class _IsaCalculatorScreenState extends State<IsaCalculatorScreen> {
  double _salary = 800000;
  double _percentage = 10;
  double _years = 3;
  double _deferred = 2;
  double _students = 50;

  @override
  Widget build(BuildContext context) {
    final monthly = (_salary / 12) * (_percentage / 100);
    final total = monthly * 12 * _years;
    final revenue = total * _students;
    final upfront = 25000 * _students;
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeroCard(
            eyebrow: 'Academy Finance',
            title: 'Model ISA upside before enrolling a cohort',
            highlight: 'ISA',
            description:
                'Tune salary, share percentage, duration, and deferred period to compare income-share revenue against upfront fees.',
            accent: AppColors.academy,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _slider(
                  'Expected salary',
                  _salary,
                  300000,
                  2000000,
                  100000,
                  (value) => setState(() => _salary = value),
                  Formatters.inr(_salary),
                ),
                _slider(
                  'ISA percentage',
                  _percentage,
                  5,
                  15,
                  1,
                  (value) => setState(() => _percentage = value),
                  '${_percentage.round()}%',
                ),
                _slider(
                  'ISA duration',
                  _years,
                  1,
                  5,
                  1,
                  (value) => setState(() => _years = value),
                  '${_years.round()} years',
                ),
                _slider(
                  'Deferred period',
                  _deferred,
                  0,
                  6,
                  1,
                  (value) => setState(() => _deferred = value),
                  '${_deferred.round()} months',
                ),
                _slider(
                  'Enrolled students',
                  _students,
                  20,
                  80,
                  5,
                  (value) => setState(() => _students = value),
                  '${_students.round()}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 210,
                child: MetricCard(
                  label: 'Monthly payment',
                  value: Formatters.inr(monthly),
                  sub: 'per placed student',
                  color: AppColors.academy,
                ),
              ),
              SizedBox(
                width: 210,
                child: MetricCard(
                  label: 'Total paid',
                  value: Formatters.inr(total),
                  sub: 'per student over term',
                  color: AppColors.studio,
                ),
              ),
              SizedBox(
                width: 210,
                child: MetricCard(
                  label: 'AlgoForce revenue',
                  value: Formatters.compactInr(revenue),
                  sub: 'cohort ISA upside',
                  color: AppColors.nexus,
                ),
              ),
              SizedBox(
                width: 210,
                child: MetricCard(
                  label: 'ROI vs upfront',
                  value: '${(revenue / upfront).toStringAsFixed(1)}x',
                  sub: 'against ₹25K/student',
                  color: AppColors.verified,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    color: AppColors.academy,
                    isCurved: true,
                    spots: [
                      for (
                        var month = 0;
                        month <= (_years * 12).round();
                        month++
                      )
                        FlSpot(
                          month.toDouble(),
                          month < _deferred
                              ? 0
                              : monthly * (month - _deferred) / 100000,
                        ),
                    ],
                  ),
                  LineChartBarData(
                    color: AppColors.purple,
                    dashArray: [6, 4],
                    spots: [
                      const FlSpot(0, 25000 / 100000),
                      FlSpot((_years * 12).toDouble(), 25000 / 100000),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    double step,
    ValueChanged<double> onChanged,
    String display,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: AppText.body(weight: FontWeight.w700)),
            ),
            Text(
              display,
              style: AppText.mono(size: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / step).round(),
          activeColor: AppColors.academy,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
