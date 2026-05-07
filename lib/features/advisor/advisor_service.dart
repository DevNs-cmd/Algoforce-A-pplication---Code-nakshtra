import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final advisorServiceProvider = Provider<AdvisorService>((ref) {
  return AdvisorService();
});

class AdvisorService {
  AdvisorService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  final Dio _dio;

  static const systemPrompt = '''
You are the AlgoForce AI Business Advisor - an expert in startup building,
talent operations, MVP development, and founder verification. You understand:
- AlgoForce Academy: cohort training, ISA models, student deployment
- AlgoForce Studio: MVP builds, equity deals, 60-90 day playbooks
- AlgoForce Verified: founder certification, investor matching
- Nexus AI: the vibe coding platform
- Indian startup ecosystem: Tier-2/3 cities, angel networks, accelerators

Current business context:
- 300+ students trained, Jan 2026 operations live
- 3 active revenue streams
- Target: ₹5.4 Cr Year 3

Answer concisely and practically. Reference AlgoForce OS data when useful.
Keep responses under 200 words unless complex analysis is requested.
''';

  Stream<String> streamResponse(
    List<AdvisorMessage> history, {
    String contextLabel = 'General OS',
  }) async* {
    final latest = history.lastOrNull?.content ?? '';
    final response = _fallback(latest, contextLabel: contextLabel);
    for (final token in response.split(' ')) {
      await Future<void>.delayed(const Duration(milliseconds: 28));
      yield '$token ';
    }
  }

  Future<String> generateInsights(String dataJson) async {
    final prompt =
        'Analyze this business data and give 3 specific actionable insights: $dataJson';
    final buffer = StringBuffer();
    await for (final chunk in streamResponse([
      AdvisorMessage.user(prompt),
    ], contextLabel: 'Analytics')) {
      buffer.write(chunk);
    }
    return buffer.toString().trim();
  }

  String _fallback(String prompt, {required String contextLabel}) {
    final lower = prompt.toLowerCase();
    if (lower.contains('academy') || contextLabel == 'Academy') {
      return 'Academy is your strongest margin engine right now. Keep Cohort 2 above 75% utilization, move the top 3 builders into Studio work, and test one referral incentive worth 100 XP plus a fee discount. The operating focus: protect completion rate before expanding seats.';
    }
    if (lower.contains('deal') ||
        lower.contains('price') ||
        contextLabel == 'Studio') {
      return 'For a new Studio client, use a hybrid structure: ₹3-5L cash to cover delivery cost plus 3-7% equity tied to milestone acceptance. If the founder has weak distribution, raise cash and lower equity. If traction is strong, accept less cash and add a monthly retainer after launch.';
    }
    if (lower.contains('verified') || contextLabel == 'Verified') {
      return 'Launch Verified after you can certify 10 founders with repeatable evidence. Keep it non-pay-to-play: application fee, council review, revocation policy, and investor matching only for score-qualified founders. Trust is the product, so scarcity matters.';
    }
    if (lower.contains('revenue') || contextLabel == 'Revenue') {
      return 'Year 2 should lean on Studio retainers and Academy cohorts while Verified matures. Watch three numbers weekly: cohort fill rate, build gross margin, and open pipeline value. If any one falls for two weeks, cut experiments and push founder-led sales.';
    }
    return 'The practical next move is to choose one engine metric and one operating action for the week. My pick: convert Academy readiness into Studio capacity. Identify 3 builders ready for deployment, pair them with one QA-heavy build, and convert the outcome into a public proof point.';
  }

  // Kept so the service mirrors Nexus API wiring and can be upgraded to real
  // HTTP streaming without changing provider/UI contracts.
  Dio get dio => _dio;
}

class AdvisorMessage {
  const AdvisorMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.streaming = false,
  });

  factory AdvisorMessage.user(String content) {
    return AdvisorMessage(
      role: AdvisorRole.user,
      content: content,
      timestamp: DateTime.now(),
    );
  }

  factory AdvisorMessage.assistant(String content, {bool streaming = false}) {
    return AdvisorMessage(
      role: AdvisorRole.assistant,
      content: content,
      timestamp: DateTime.now(),
      streaming: streaming,
    );
  }

  final AdvisorRole role;
  final String content;
  final DateTime timestamp;
  final bool streaming;

  AdvisorMessage copyWith({String? content, bool? streaming}) {
    return AdvisorMessage(
      role: role,
      content: content ?? this.content,
      timestamp: timestamp,
      streaming: streaming ?? this.streaming,
    );
  }
}

enum AdvisorRole { user, assistant }

extension _LastOrNull<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
