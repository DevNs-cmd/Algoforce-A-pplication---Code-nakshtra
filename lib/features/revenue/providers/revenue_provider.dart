import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/mock_data.dart';
import '../../../core/services/preferences_service.dart';
import 'revenue_models.dart';

final revenueProvider = StateNotifierProvider<RevenueController, RevenueState>(
  (ref) => RevenueController(ref.watch(preferencesServiceProvider)),
);

class RevenueState {
  const RevenueState({
    required this.selectedYear,
    required this.scenario,
    required this.streams,
    required this.chartData,
    required this.targetBarsVisible,
    required this.inputs,
  });

  final int selectedYear;
  final ProjectionScenario scenario;
  final List<RevenueStream> streams;
  final List<FlSpot> chartData;
  final bool targetBarsVisible;
  final RevenueProjectionInputs inputs;

  RevenueState copyWith({
    int? selectedYear,
    ProjectionScenario? scenario,
    List<RevenueStream>? streams,
    List<FlSpot>? chartData,
    bool? targetBarsVisible,
    RevenueProjectionInputs? inputs,
  }) {
    return RevenueState(
      selectedYear: selectedYear ?? this.selectedYear,
      scenario: scenario ?? this.scenario,
      streams: streams ?? this.streams,
      chartData: chartData ?? this.chartData,
      targetBarsVisible: targetBarsVisible ?? this.targetBarsVisible,
      inputs: inputs ?? this.inputs,
    );
  }
}

class RevenueController extends StateNotifier<RevenueState> {
  RevenueController(this._prefs)
    : super(
        RevenueState(
          selectedYear: 1,
          scenario: _scenarioFromString(_prefs.getRevenueScenario()),
          streams: MockData.revenueStreams(),
          chartData: _buildChart(
            _scenarioFromString(_prefs.getRevenueScenario()),
            MockData.revenueStreams(),
          ),
          targetBarsVisible: false,
          inputs: _loadInputs(_prefs),
        ),
      );

  final PreferencesService _prefs;

  void setScenario(ProjectionScenario scenario) {
    state = state.copyWith(
      scenario: scenario,
      chartData: _buildChart(scenario, state.streams),
    );
    unawaited(_prefs.setRevenueScenario(scenario.name));
  }

  void toggleStream(int index, bool active) {
    final streams = [...state.streams];
    if (streams[index].critical && !active) {
      return;
    }
    streams[index] = streams[index].copyWith(active: active);
    state = state.copyWith(
      streams: streams,
      chartData: _buildChart(state.scenario, streams),
    );
  }

  void updateInputs(RevenueProjectionInputs inputs) {
    state = state.copyWith(inputs: inputs);
    unawaited(_prefs.setRevenueSliderValues(jsonEncode(inputs.toJson())));
  }

  void setTargetsVisible() {
    if (!state.targetBarsVisible) {
      state = state.copyWith(targetBarsVisible: true);
    }
  }

  static ProjectionScenario _scenarioFromString(String raw) {
    return ProjectionScenario.values.firstWhere(
      (scenario) => scenario.name == raw,
      orElse: () => ProjectionScenario.base,
    );
  }

  static RevenueProjectionInputs _loadInputs(PreferencesService prefs) {
    final raw = prefs.getRevenueSliderValues();
    if (raw == null) {
      return const RevenueProjectionInputs();
    }
    try {
      return RevenueProjectionInputs.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return const RevenueProjectionInputs();
    }
  }

  static List<FlSpot> _buildChart(
    ProjectionScenario scenario,
    List<RevenueStream> streams,
  ) {
    final activeFactor =
        streams.where((stream) => stream.active).length / streams.length;
    final start = switch (scenario) {
      ProjectionScenario.conservative => 3.0,
      ProjectionScenario.base => 4.0,
      ProjectionScenario.optimistic => 5.0,
    };
    final end = switch (scenario) {
      ProjectionScenario.conservative => 12.0,
      ProjectionScenario.base => 18.0,
      ProjectionScenario.optimistic => 28.0,
    };
    return [
      for (var month = 1; month <= 12; month++)
        FlSpot(
          month.toDouble(),
          ((start + ((end - start) / 11) * (month - 1)) *
                  activeFactor.clamp(.35, 1.2))
              .toDouble(),
        ),
    ];
  }
}
