import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/hero_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_label.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../providers/nexus_provider.dart';
import '../widgets/code_output_panel.dart';
import '../widgets/nexus_settings_sheet.dart';
import '../widgets/pricing_card.dart';
import '../widgets/prompt_input.dart';
import '../widgets/strategy_card.dart';
import '../widgets/template_library.dart';

class NexusScreen extends ConsumerWidget {
  const NexusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nexusProvider);
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroCard(
            eyebrow: 'Nexus AI',
            title: 'Generate product code inside the AlgoForce loop',
            highlight: 'code',
            description:
                'Nexus gives builders a controlled vibe-coding surface for MVP snippets, deployment previews, and Studio handoff history.',
            accent: AppColors.nexus,
            children: [
              PrimaryButton(
                label: 'Open full builder',
                icon: Icons.open_in_full_rounded,
                onPressed: () => context.push('/nexus/builder'),
              ),
              PrimaryButton(
                label: 'Settings',
                icon: Icons.settings_rounded,
                onPressed: () => NexusSettingsSheet.show(context),
              ),
              PrimaryButton(
                label: 'Build history',
                icon: Icons.history_rounded,
                onPressed: () => _showHistory(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const SectionLabel('Template Library'),
          const SizedBox(height: 10),
          const TemplateLibrary(),
          const SizedBox(height: 18),
          _FrameworkSwitcher(state: state),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 900;
              final prompt = Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const PromptInput(),
              );
              final output = state.generatedCode == null
                  ? const StrategyCard(
                      title: 'Ready for generation',
                      body:
                          'Enter a product request and Nexus will return a realistic component with a deployment URL.',
                    )
                  : CodeOutputPanel(
                      filename: state.filename,
                      deployUrl: state.deployUrl,
                      code: state.generatedCode!,
                    );
              if (!wide) {
                return Column(
                  children: [prompt, const SizedBox(height: 14), output],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: prompt),
                  const SizedBox(width: 14),
                  Expanded(flex: 6, child: output),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const SectionLabel('Pricing Strategy'),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: PricingCard(
                  name: 'Builder',
                  price: '₹999/mo',
                  detail: 'Personal Nexus generation history and code export.',
                ),
              ),
              SizedBox(
                width: 220,
                child: PricingCard(
                  name: 'Studio',
                  price: '₹9,999/mo',
                  detail: 'Team prompt libraries and launch handoff workflows.',
                ),
              ),
              SizedBox(
                width: 220,
                child: PricingCard(
                  name: 'Enterprise',
                  price: 'Custom',
                  detail:
                      'Private model routing, audit logs, and delivery governance.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const SectionLabel('Build History'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: state.buildHistory.isEmpty
                ? Text(
                    'Your generated builds will appear here.',
                    style: AppText.body(color: AppColors.textMuted),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.buildHistory.length,
                    itemBuilder: (context, i) {
                      final build = state.buildHistory[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () =>
                            ref.read(nexusProvider.notifier).restoreBuild(i),
                        title: Text(
                          build.prompt,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${build.filename} - ${build.framework} - ${Formatters.timestamp(build.createdAt)}',
                        ),
                        trailing: const Icon(Icons.restore_rounded),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 32),
        ],
      ).animate().fadeIn(duration: 200.ms).slideY(begin: .02, end: 0, duration: 200.ms),
    );
  }

  void _showHistory(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        final state = ref.watch(nexusProvider);
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: state.buildHistory.length,
          itemBuilder: (context, index) {
            final build = state.buildHistory[index];
            return Dismissible(
              key: ValueKey('${build.filename}-${build.createdAt}'),
              background: Container(color: AppColors.verified),
              onDismissed: (_) {
                ref.read(nexusProvider.notifier).deleteBuild(index);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Build removed.')));
              },
              child: ListTile(
                title: Text(build.filename),
                subtitle: Text(
                  build.prompt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: TagPill(
                  label: build.framework,
                  color: AppColors.nexus,
                ),
                onTap: () {
                  ref.read(nexusProvider.notifier).restoreBuild(index);
                  Navigator.of(context).pop();
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _FrameworkSwitcher extends ConsumerWidget {
  const _FrameworkSwitcher({required this.state});

  final NexusState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'React', label: Text('React')),
          ButtonSegment(value: 'Vue', label: Text('Vue')),
          ButtonSegment(value: 'Svelte', label: Text('Svelte')),
          ButtonSegment(value: 'Next.js', label: Text('Next.js')),
          ButtonSegment(value: 'Plain HTML', label: Text('HTML')),
        ],
        selected: {state.framework},
        onSelectionChanged: (value) => ref
            .read(nexusProvider.notifier)
            .updateSettings(framework: value.first),
      ),
    );
  }
}
