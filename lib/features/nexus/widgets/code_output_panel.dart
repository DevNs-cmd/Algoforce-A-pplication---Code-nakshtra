import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/pulse_dot.dart';
import '../../../shared/widgets/ghost_button.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/nexus_provider.dart';

class CodeOutputPanel extends ConsumerWidget {
  const CodeOutputPanel({
    super.key,
    required this.filename,
    required this.deployUrl,
    required this.code,
  });

  final String filename;
  final String deployUrl;
  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nexusProvider);
    final displayedCode = state.showLineNumbers
        ? _withLineNumbers(code, maxLines: state.maxLines)
        : code.split('\n').take(state.maxLines).join('\n');
    final streaming = !state.isStreamingComplete && code.isNotEmpty;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: code.isEmpty ? .5 : 1,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Text(
                      filename,
                      style: AppText.mono(size: 12, color: AppColors.navy),
                    ),
                    const SizedBox(width: 10),
                    if (state.isStreamingComplete)
                      const PulseDot(size: 8)
                    else
                      const SizedBox(
                        width: 8,
                        height: 8,
                        child: PulseDot(color: AppColors.nexus, size: 8),
                      ),
                    const SizedBox(width: 6),
                    Expanded(
                      child:
                          Text(
                                '${state.framework} - ${state.isStreamingComplete ? 'Deployed to $deployUrl' : 'Streaming code'}',
                                overflow: TextOverflow.ellipsis,
                                style: AppText.body(
                                  size: 12,
                                  color: state.isStreamingComplete
                                      ? AppColors.academy
                                      : AppColors.nexus,
                                  weight: FontWeight.w700,
                                ),
                              )
                              .animate(
                                target: state.isStreamingComplete ? 1 : 0,
                              )
                              .slideX(begin: .08, end: 0, duration: 180.ms)
                              .fadeIn(duration: 180.ms),
                    ),
                  ],
                ),
              ),
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 400,
                  minHeight: 220,
                ),
                width: double.infinity,
                color: const Color(0xFF1E1E1E),
                padding: const EdgeInsets.all(14),
                child: SingleChildScrollView(
                  child: SelectableText(
                    code.isEmpty
                        ? '// Nexus output will stream here.'
                        : '$displayedCode${streaming ? '|' : ''}',
                    style: AppText.mono(
                      size: 11,
                      color: const Color(0xFFD4D4D4),
                    ).copyWith(height: 1.45),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    PrimaryButton(
                      label: 'Copy Code',
                      icon: Icons.copy_rounded,
                      onPressed: code.isEmpty
                          ? null
                          : () async {
                              await Clipboard.setData(
                                ClipboardData(text: code),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Code copied.')),
                                );
                              }
                            },
                    ),
                    GhostButton(
                      label: 'Share URL',
                      icon: Icons.ios_share_rounded,
                      onPressed: () async {
                        await launchUrl(
                          Uri.parse('https://$deployUrl'),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _withLineNumbers(String value, {required int maxLines}) {
    final lines = value.split('\n').take(maxLines).toList();
    return [
      for (var i = 0; i < lines.length; i++)
        '${(i + 1).toString().padLeft(3)}  ${lines[i]}',
    ].join('\n');
  }
}
