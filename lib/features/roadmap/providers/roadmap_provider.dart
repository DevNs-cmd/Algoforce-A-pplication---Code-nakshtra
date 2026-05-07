import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/mock_data.dart';
import '../../../core/services/preferences_service.dart';
import '../../activity/providers/activity_feed_provider.dart';
import 'roadmap_models.dart';

final roadmapProvider = StateNotifierProvider<RoadmapController, RoadmapState>(
  (ref) => RoadmapController(
    ref.watch(preferencesServiceProvider),
    ref.read(activityFeedProvider.notifier),
  ),
);

class RoadmapState {
  const RoadmapState({
    required this.phases,
    required this.itemCompletions,
    required this.expandedPhaseIndex,
  });

  final List<Phase> phases;
  final Map<String, bool> itemCompletions;
  final int expandedPhaseIndex;

  double get overallCompletion {
    final items = phases.expand((phase) => phase.items).toList();
    if (items.isEmpty) {
      return 0;
    }
    return items.where((item) => item.completed).length / items.length;
  }

  RoadmapState copyWith({
    List<Phase>? phases,
    Map<String, bool>? itemCompletions,
    int? expandedPhaseIndex,
  }) {
    return RoadmapState(
      phases: phases ?? this.phases,
      itemCompletions: itemCompletions ?? this.itemCompletions,
      expandedPhaseIndex: expandedPhaseIndex ?? this.expandedPhaseIndex,
    );
  }
}

class RoadmapController extends StateNotifier<RoadmapState> {
  RoadmapController(this._prefs, this._activity)
    : super(
        RoadmapState(
          itemCompletions: _load(_prefs),
          phases: MockData.phases(_load(_prefs)),
          expandedPhaseIndex: _prefs.getRoadmapExpandedPhase(),
        ),
      );

  final PreferencesService _prefs;
  final ActivityFeedController _activity;

  static Map<String, bool> _load(PreferencesService prefs) {
    final raw = prefs.getRoadmapCompletions();
    if (raw == null) {
      return const {};
    }
    try {
      final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      return decoded.map((key, value) => MapEntry(key, value == true));
    } catch (_) {
      return const {};
    }
  }

  void toggleItemComplete(String phaseId, String itemId, bool value) {
    final completions = {...state.itemCompletions, itemId: value};
    state = state.copyWith(
      itemCompletions: completions,
      phases: MockData.phases(completions),
    );
    if (value) {
      final phase = state.phases.where((phase) => phase.id == phaseId).first;
      final item = phase.items.where((item) => item.id == itemId).first;
      _activity.add(
        icon: Icons.check_circle_rounded,
        description: 'Phase ${phase.title} item completed: ${item.description}',
        route: '/roadmap',
      );
    }
    unawaited(_prefs.setRoadmapCompletions(jsonEncode(completions)));
  }

  void expandPhase(int index) {
    state = state.copyWith(expandedPhaseIndex: index);
    unawaited(_prefs.setRoadmapExpandedPhase(index));
  }

  void reorderPhaseItem(String phaseId, int oldIndex, int newIndex) {
    state = state.copyWith(
      phases: [
        for (final phase in state.phases)
          if (phase.id == phaseId)
            phase.copyWith(items: _reordered(phase.items, oldIndex, newIndex))
          else
            phase,
      ],
    );
  }

  List<PhaseItem> _reordered(
    List<PhaseItem> items,
    int oldIndex,
    int newIndex,
  ) {
    final copy = [...items];
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final item = copy.removeAt(oldIndex);
    copy.insert(adjusted.clamp(0, copy.length).toInt(), item);
    return copy;
  }
}
