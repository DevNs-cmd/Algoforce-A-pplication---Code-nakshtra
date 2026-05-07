import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/nexus_provider.dart';

class PromptInput extends ConsumerStatefulWidget {
  const PromptInput({super.key, this.compact = false, this.streaming = false});

  final bool compact;
  final bool streaming;

  @override
  ConsumerState<PromptInput> createState() => _PromptInputState();
}

class _PromptInputState extends ConsumerState<PromptInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(nexusProvider).promptText,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nexusProvider);
    ref.listen<String>(nexusProvider.select((value) => value.promptText), (
      previous,
      next,
    ) {
      if (next != _controller.text) {
        _controller
          ..text = next
          ..selection = TextSelection.collapsed(offset: next.length);
      }
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          minLines: widget.compact ? 5 : 3,
          maxLines: widget.compact ? 10 : 6,
          decoration: const InputDecoration(
            hintText:
                'Build a SaaS landing page with waitlist form and Stripe checkout',
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.purple),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          onChanged: (value) =>
              ref.read(nexusProvider.notifier).setPrompt(value),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              '${state.promptText.length} characters',
              style: AppText.mono(size: 11, color: AppColors.textHint),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Generate',
              icon: Icons.auto_awesome_rounded,
              loading: state.isGenerating,
              onPressed: state.promptText.trim().isEmpty
                  ? null
                  : () => ref
                        .read(nexusProvider.notifier)
                        .generate(stream: widget.streaming),
            ),
          ],
        ),
      ],
    );
  }
}
