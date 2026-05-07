import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/tag_pill.dart';

class RiskRegister extends StatelessWidget {
  const RiskRegister({super.key});

  static const risks = [
    _Risk(
      'Cohort enrollment below 30',
      'Medium',
      'High',
      'Activate backup ambassador channel',
    ),
    _Risk(
      'Studio build delayed >2 weeks',
      'Medium',
      'Medium',
      'Assign additional builder from Cohort 1 alumni',
    ),
    _Risk(
      'Verified launch rejected by investors',
      'Low',
      'High',
      'Pre-secure 5 investor commitments before launch',
    ),
    _Risk(
      'Nexus API costs exceed budget',
      'Low',
      'Medium',
      'Rate limit per user, add usage-based billing tier',
    ),
    _Risk(
      'Founder misrepresentation in Verified',
      'Low',
      'High',
      'Layer 1 ID check + council review filter',
    ),
    _Risk(
      'Key team member departure',
      'Medium',
      'High',
      'Document all processes, cross-train',
    ),
    _Risk(
      'US/EU outbound conversion below 5%',
      'Medium',
      'Medium',
      'Pivot to warm referral channel first',
    ),
    _Risk(
      'Nexus SaaS delayed past Q4',
      'Medium',
      'Low',
      'Internal builds prove product, launch with waitlist',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: CustomPaint(
            painter: const _RiskMatrixPainter(risks),
            child: Semantics(
              label:
                  'Risk matrix with risks positioned by probability and impact.',
            ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: risks.length,
          itemBuilder: (context, index) {
            final risk = risks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  risk.title,
                  style: AppText.body(weight: FontWeight.w800),
                ),
                subtitle: Text(
                  risk.mitigation,
                  style: AppText.body(size: 12, color: AppColors.textMuted),
                ),
                trailing: Wrap(
                  spacing: 6,
                  children: [
                    TagPill(label: risk.probability, color: AppColors.nexus),
                    TagPill(label: risk.impact, color: AppColors.verified),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RiskMatrixPainter extends CustomPainter {
  const _RiskMatrixPainter(this.risks);

  final List<_Risk> risks;

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = AppColors.border2
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      axis,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      axis,
    );
    final text = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < risks.length; i++) {
      final risk = risks[i];
      final p = risk.probability == 'Low' ? .25 : .72;
      final impact = risk.impact == 'Low'
          ? .25
          : (risk.impact == 'Medium' ? .56 : .82);
      final point = Offset(
        p * size.width + (i % 2) * 8,
        (1 - impact) * size.height + (i % 3) * 7,
      );
      canvas.drawCircle(point, 7, Paint()..color = AppColors.purple);
      text.text = TextSpan(
        text: '${i + 1}',
        style: AppText.mono(size: 9, color: AppColors.white),
      );
      text.layout();
      text.paint(canvas, point - Offset(text.width / 2, text.height / 2));
    }
    text.text = TextSpan(
      text: 'Probability → / Impact ↑',
      style: AppText.body(size: 11, color: AppColors.textMuted),
    );
    text.layout();
    text.paint(canvas, const Offset(8, 8));
  }

  @override
  bool shouldRepaint(covariant _RiskMatrixPainter oldDelegate) => false;
}

class _Risk {
  const _Risk(this.title, this.probability, this.impact, this.mitigation);

  final String title;
  final String probability;
  final String impact;
  final String mitigation;
}
