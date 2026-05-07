import 'package:flutter/material.dart';

import '../../../shared/widgets/step_flow_widget.dart';

class AcademyStepFlow extends StatelessWidget {
  const AcademyStepFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return const StepFlowWidget(
      activeIndex: 3,
      steps: [
        'Signal',
        'Enroll',
        'Build',
        'Deploy',
        'Certify',
        'Place',
        'Compound',
      ],
    );
  }
}
