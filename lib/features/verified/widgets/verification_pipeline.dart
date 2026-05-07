import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../providers/verified_provider.dart';

class VerificationPipeline extends ConsumerWidget {
  const VerificationPipeline({super.key});

  static const layers = ['Identity', 'Business', 'Index', 'Council', 'Payment'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(verifiedProvider).pendingApplications;
    return Container(
      height: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < layers.length; i++)
              Container(
                width: 190,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      layers[i],
                      style: AppText.body(weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: apps
                            .where((app) => app.currentLayer == i + 1)
                            .length,
                        itemBuilder: (context, index) {
                          final app = apps
                              .where((app) => app.currentLayer == i + 1)
                              .toList()[index];
                          final status =
                              app.layerStatuses[(app.currentLayer - 1).clamp(
                                0,
                                app.layerStatuses.length - 1,
                              )];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _statusColor(
                                status,
                              ).withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _statusColor(
                                  status,
                                ).withValues(alpha: .4),
                              ),
                            ),
                            child: InkWell(
                              onTap: () => ref
                                  .read(verifiedProvider.notifier)
                                  .advanceApplicationLayer(app.id),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app.founderName,
                                    style: AppText.body(
                                      size: 12,
                                      weight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    app.startupName,
                                    style: AppText.body(
                                      size: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'passed' => AppColors.academy,
      'failed' => AppColors.verified,
      'in-review' => const Color(0xFFF59E0B),
      _ => AppColors.textHint,
    };
  }
}
