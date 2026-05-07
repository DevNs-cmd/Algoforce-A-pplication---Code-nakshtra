import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/nexus_provider.dart';

class NexusSettingsSheet extends ConsumerWidget {
  const NexusSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => const NexusSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nexusProvider);
    final notifier = ref.read(nexusProvider.notifier);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      shrinkWrap: true,
      children: [
        SwitchListTile(
          value: state.includeComments,
          onChanged: (value) => notifier.updateSettings(includeComments: value),
          title: const Text('Include comments in generated code'),
        ),
        SwitchListTile(
          value: state.autoDeploy,
          onChanged: (value) => notifier.updateSettings(autoDeploy: value),
          title: const Text('Auto-deploy to live URL'),
        ),
        SwitchListTile(
          value: state.showLineNumbers,
          onChanged: (value) => notifier.updateSettings(showLineNumbers: value),
          title: const Text('Show line numbers'),
        ),
        DropdownButtonFormField<int>(
          initialValue: state.maxLines,
          decoration: const InputDecoration(labelText: 'Max lines'),
          items: const [30, 60, 100]
              .map(
                (value) =>
                    DropdownMenuItem(value: value, child: Text('$value')),
              )
              .toList(),
          onChanged: (value) => notifier.updateSettings(maxLines: value),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: state.codeStyle,
          decoration: const InputDecoration(labelText: 'Code style'),
          items: const ['functional', 'class-based', 'hooks-first']
              .map(
                (value) => DropdownMenuItem(value: value, child: Text(value)),
              )
              .toList(),
          onChanged: (value) => notifier.updateSettings(codeStyle: value),
        ),
      ],
    );
  }
}
