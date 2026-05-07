import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final overviewProvider =
    StateNotifierProvider.autoDispose<OverviewController, OverviewState>(
      (ref) => OverviewController(),
    );

final liveMetricsProvider =
    StateNotifierProvider<LiveMetricsController, LiveMetricsState>(
      (ref) => LiveMetricsController(),
    );

class OverviewState {
  const OverviewState({
    required this.dayCount,
    required this.currentPhraseIndex,
    required this.phrases,
  });

  final int dayCount;
  final int currentPhraseIndex;
  final List<String> phrases;

  OverviewState copyWith({int? currentPhraseIndex}) {
    return OverviewState(
      dayCount: dayCount,
      currentPhraseIndex: currentPhraseIndex ?? this.currentPhraseIndex,
      phrases: phrases,
    );
  }
}

class LiveMetricsState {
  const LiveMetricsState({
    required this.revenueThisMonth,
    required this.refreshCount,
  });

  final int revenueThisMonth;
  final int refreshCount;

  LiveMetricsState copyWith({int? revenueThisMonth, int? refreshCount}) {
    return LiveMetricsState(
      revenueThisMonth: revenueThisMonth ?? this.revenueThisMonth,
      refreshCount: refreshCount ?? this.refreshCount,
    );
  }
}

class LiveMetricsController extends StateNotifier<LiveMetricsState> {
  LiveMetricsController()
    : super(const LiveMetricsState(revenueThisMonth: 320000, refreshCount: 0)) {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      final delta = 2500 + Random().nextInt(9000);
      state = state.copyWith(
        revenueThisMonth: state.revenueThisMonth + delta,
        refreshCount: state.refreshCount + 1,
      );
    });
  }

  late final Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

class OverviewController extends StateNotifier<OverviewState> {
  OverviewController()
    : super(
        OverviewState(
          dayCount: DateTime.now().difference(DateTime(2026, 1, 1)).inDays,
          currentPhraseIndex: 0,
          phrases: const [
            'We train builders.',
            'We build companies.',
            'We verify founders.',
            'We own the upside.',
          ],
        ),
      ) {
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      state = state.copyWith(
        currentPhraseIndex:
            (state.currentPhraseIndex + 1) % state.phrases.length,
      );
    });
  }

  late final Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
