import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'advisor_service.dart';

final advisorProvider = StateNotifierProvider<AdvisorController, AdvisorState>((
  ref,
) {
  return AdvisorController(ref.watch(advisorServiceProvider));
});

class AdvisorState {
  const AdvisorState({
    this.messages = const [],
    this.isStreaming = false,
    this.contextLabel = 'General OS',
    this.prefill,
  });

  final List<AdvisorMessage> messages;
  final bool isStreaming;
  final String contextLabel;
  final String? prefill;

  AdvisorState copyWith({
    List<AdvisorMessage>? messages,
    bool? isStreaming,
    String? contextLabel,
    String? prefill,
  }) {
    return AdvisorState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      contextLabel: contextLabel ?? this.contextLabel,
      prefill: prefill,
    );
  }
}

class AdvisorController extends StateNotifier<AdvisorState> {
  AdvisorController(this._service) : super(const AdvisorState());

  final AdvisorService _service;
  StreamSubscription<String>? _subscription;

  void setContext(String contextLabel, {String? prefill}) {
    state = state.copyWith(contextLabel: contextLabel, prefill: prefill);
  }

  Future<void> send(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || state.isStreaming) {
      return;
    }
    final userMessage = AdvisorMessage.user(trimmed);
    final assistant = AdvisorMessage.assistant('', streaming: true);
    state = state.copyWith(
      messages: [...state.messages, userMessage, assistant],
      isStreaming: true,
      prefill: '',
    );
    final index = state.messages.length - 1;
    final buffer = StringBuffer();
    await _subscription?.cancel();
    _subscription = _service
        .streamResponse(state.messages, contextLabel: state.contextLabel)
        .listen(
          (chunk) {
            buffer.write(chunk);
            final messages = [...state.messages];
            messages[index] = messages[index].copyWith(
              content: buffer.toString(),
              streaming: true,
            );
            state = state.copyWith(messages: messages);
          },
          onDone: () {
            final messages = [...state.messages];
            messages[index] = messages[index].copyWith(streaming: false);
            state = state.copyWith(messages: messages, isStreaming: false);
          },
          onError: (_) {
            final messages = [...state.messages];
            messages[index] = messages[index].copyWith(
              content:
                  'I could not reach the advisor service. Use the operating dashboard and try again.',
              streaming: false,
            );
            state = state.copyWith(messages: messages, isStreaming: false);
          },
        );
  }

  void clear() {
    unawaited(_subscription?.cancel());
    state = const AdvisorState();
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
