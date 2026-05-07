import 'package:flutter/material.dart';

import '../../../shared/widgets/step_flow_widget.dart';

class VerificationStepper extends StatelessWidget {
  const VerificationStepper({super.key, required this.currentLayer});

  final int currentLayer;

  @override
  Widget build(BuildContext context) {
    return StepFlowWidget(
      activeIndex: (currentLayer - 1).clamp(0, 4).toInt(),
      steps: const ['Identity', 'Business', 'Index', 'Council', 'Payment'],
    );
  }
}
