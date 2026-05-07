import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../shared/widgets/astronaut_widget.dart';
import 'advisor_provider.dart';
import 'advisor_service.dart';

Future<void> showAdvisorSheet(
  BuildContext context,
  WidgetRef ref, {
  String contextLabel = 'General OS',
  String? prefill,
}) {
  ref.read(advisorProvider.notifier).setContext(contextLabel, prefill: prefill);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const AdvisorSheet(),
  );
}

class AdvisorSheet extends ConsumerStatefulWidget {
  const AdvisorSheet({super.key});

  @override
  ConsumerState<AdvisorSheet> createState() => _AdvisorSheetState();
}

class _AdvisorSheetState extends ConsumerState<AdvisorSheet> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _listening = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefill = ref.read(advisorProvider).prefill;
      if (prefill != null && prefill.isNotEmpty) {
        _input.text = prefill;
      }
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _listening.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(advisorProvider, (previous, next) {
      if ((previous?.messages.length ?? 0) != next.messages.length ||
          previous?.messages.lastOrNull?.content !=
              next.messages.lastOrNull?.content) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });
    final state = ref.watch(advisorProvider);
    return DraggableScrollableSheet(
      initialChildSize: .85,
      minChildSize: .55,
      maxChildSize: .96,
      builder: (context, sheetScrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 12, 10),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: AppColors.purple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AlgoForce Advisor',
                            style: AppText.heading(size: 18),
                          ),
                          Text(
                            state.contextLabel,
                            style: AppText.body(
                              size: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  children: [
                    if (state.messages.isEmpty)
                      const _Suggestions()
                    else
                      for (final message in state.messages)
                        _MessageBubble(message: message),
                  ],
                ),
              ),
              _InputBar(
                controller: _input,
                listening: _listening,
                loading: state.isStreaming,
                onMic: _simulateVoice,
                onSend: _send,
              ),
            ],
          ),
        ).animate().slideY(begin: .08, end: 0, duration: 220.ms);
      },
    );
  }

  void _scrollToBottom() {
    if (!_scroll.hasClients) {
      return;
    }
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) {
      return;
    }
    _input.clear();
    await ref.read(advisorProvider.notifier).send(text);
  }

  Future<void> _simulateVoice() async {
    _listening.value = true;
    await Future<void>.delayed(const Duration(seconds: 2));
    _input.text = 'How should I run the next cohort?';
    _listening.value = false;
  }
}

class _Suggestions extends ConsumerWidget {
  const _Suggestions();

  static const questions = [
    'How is our Academy performing?',
    "What's the best deal structure for a new Studio client?",
    'When should we launch Verified?',
    'How do I price a SaaS MVP build?',
    "What's our Year 2 revenue projection?",
    'How should I run the next cohort?',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested questions',
          style: AppText.body(weight: FontWeight.w800),
        ),
        const SizedBox(height: AppDimensions.space10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final question in questions)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(question),
                    onPressed: () => unawaited(
                      ref.read(advisorProvider.notifier).send(question),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space24),
        Container(
          padding: const EdgeInsets.all(AppDimensions.space16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const AstronautWidget(size: 42),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Text(
                  'Ask about cohorts, Studio deals, Verified timing, revenue targets, or Nexus AI execution.',
                  style: AppText.body(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final AdvisorMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AdvisorRole.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.space14),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const AstronautWidget(size: 28),
            const SizedBox(width: AppDimensions.space8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space14,
                    vertical: AppDimensions.space12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.purple : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isUser ? 18 : 4),
                      topRight: Radius.circular(isUser ? 4 : 18),
                      bottomLeft: const Radius.circular(18),
                      bottomRight: const Radius.circular(18),
                    ),
                    border: isUser ? null : Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '${message.content}${message.streaming ? '▌' : ''}',
                    style: AppText.body(
                      color: isUser ? AppColors.white : AppColors.navy,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  TimeOfDay.fromDateTime(message.timestamp).format(context),
                  style: AppText.body(size: 10, color: AppColors.textHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.listening,
    required this.loading,
    required this.onMic,
    required this.onSend,
  });

  final TextEditingController controller;
  final ValueNotifier<bool> listening;
  final bool loading;
  final VoidCallback onMic;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          12,
          10,
          12,
          MediaQuery.viewInsetsOf(context).bottom + 10,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: listening,
              builder: (context, value, child) {
                return IconButton(
                  tooltip: value ? 'Listening...' : 'Voice input',
                  onPressed: loading ? null : onMic,
                  icon: Icon(
                    value ? Icons.graphic_eq_rounded : Icons.mic_none_rounded,
                    color: value ? AppColors.verified : AppColors.textMuted,
                  ),
                );
              },
            ),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Ask the advisor...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.purple,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                tooltip: 'Send',
                onPressed: loading ? null : onSend,
                icon: const Icon(Icons.send_rounded, color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _MessageListX on List<AdvisorMessage> {
  AdvisorMessage? get lastOrNull => isEmpty ? null : last;
}
