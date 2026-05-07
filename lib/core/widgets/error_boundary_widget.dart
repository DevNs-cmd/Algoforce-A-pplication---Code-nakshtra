import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/primary_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class ErrorBoundaryWidget extends StatefulWidget {
  const ErrorBoundaryWidget({super.key, required this.child});

  final Widget child;

  static Widget friendlyError(
    Object error,
    StackTrace? stack,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Container(
        width: 460,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.bug_report_rounded,
              color: AppColors.verified,
              size: 34,
            ),
            const SizedBox(height: 10),
            Text('Something went wrong', style: AppText.heading(size: 18)),
            const SizedBox(height: 6),
            Text(
              'The AlgoForce screen hit an unexpected state. Retry will remount this view.',
              style: AppText.body(color: AppColors.textMuted),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 12),
              Text(
                '$error',
                style: AppText.mono(size: 11, color: AppColors.verified),
              ),
              if (stack != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 140),
                  child: SingleChildScrollView(
                    child: Text(
                      '$stack',
                      style: AppText.mono(size: 10, color: AppColors.textMuted),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 14),
            PrimaryButton(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<ErrorBoundaryWidget> createState() => _ErrorBoundaryWidgetState();
}

class _ErrorBoundaryWidgetState extends State<ErrorBoundaryWidget> {
  int _version = 0;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: ValueKey(_version), child: widget.child);
  }

  void retry() {
    setState(() => _version++);
  }
}
