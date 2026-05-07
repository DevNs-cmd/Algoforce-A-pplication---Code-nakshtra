import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../providers/nexus_provider.dart';
import '../widgets/code_output_panel.dart';
import '../widgets/nexus_settings_sheet.dart';
import '../widgets/prompt_input.dart';

class BuilderScreen extends ConsumerWidget {
  const BuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nexusProvider);
    final settings = _SettingsPanel(state: state);
    const prompt = PromptInput(compact: true, streaming: true);
    final output = CodeOutputPanel(
      filename: state.filename,
      deployUrl: state.deployUrl,
      code: state.streamedCode.isEmpty
          ? (state.generatedCode ?? '')
          : state.streamedCode,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 820;
        final left = SingleChildScrollView(
          padding: responsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Nexus Builder',
                      style: AppText.heading(size: 22),
                    ),
                  ),
                  IconButton(
                    onPressed: () => NexusSettingsSheet.show(context),
                    icon: const Icon(Icons.settings_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              prompt,
              const SizedBox(height: 18),
              settings,
            ],
          ),
        );
        final right = SingleChildScrollView(
          padding: responsivePadding(context),
          child: output,
        );
        if (!wide) {
          return Column(
            children: [
              Expanded(child: left),
              Expanded(child: right),
            ],
          );
        }
        return Row(
              children: [
                SizedBox(width: constraints.maxWidth * .4, child: left),
                const VerticalDivider(width: 1, color: AppColors.border),
                Expanded(child: right),
              ],
            )
            .animate()
            .fadeIn(duration: 200.ms)
            .slideY(begin: .02, end: 0, duration: 200.ms);
      },
    );
  }
}

class _SettingsPanel extends ConsumerWidget {
  const _SettingsPanel({required this.state});

  final NexusState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(nexusProvider.notifier);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: AppText.heading(size: 16)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: state.framework,
            decoration: const InputDecoration(labelText: 'Framework'),
            items: const ['React', 'Vue', 'Svelte', 'Next.js', 'Plain HTML']
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => notifier.updateSettings(framework: value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: state.styling,
            decoration: const InputDecoration(labelText: 'Styling'),
            items: const ['Tailwind', 'CSS Modules', 'Styled Components']
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => notifier.updateSettings(styling: value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: state.includeTypeScript,
            onChanged: (value) =>
                notifier.updateSettings(includeTypeScript: value),
            title: const Text('Include TypeScript'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: state.mobileResponsive,
            onChanged: (value) =>
                notifier.updateSettings(mobileResponsive: value),
            title: const Text('Mobile responsive'),
          ),
        ],
      ),
    );
  }
}
