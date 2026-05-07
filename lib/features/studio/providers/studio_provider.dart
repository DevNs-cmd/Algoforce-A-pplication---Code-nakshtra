import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/mock_data.dart';
import '../../../core/services/preferences_service.dart';
import '../../activity/providers/activity_feed_provider.dart';
import '../models/build_project.dart';
import '../models/deal.dart';

final studioProvider = StateNotifierProvider<StudioController, StudioState>(
  (ref) => StudioController(
    ref.watch(preferencesServiceProvider),
    ref.read(activityFeedProvider.notifier),
  ),
);

class DealCalculatorState {
  const DealCalculatorState({
    this.cashAmount = 300000,
    this.equityPercent = 7.5,
    this.exitValuation = 100000000,
    this.successProbability = 35,
    this.costBase = 180000,
  });

  final double cashAmount;
  final double equityPercent;
  final double exitValuation;
  final double successProbability;
  final double costBase;

  double get expectedEquityValue =>
      (equityPercent / 100) * exitValuation * (successProbability / 100);
  double get totalDealValue => cashAmount + expectedEquityValue;
  double get marginPercent =>
      cashAmount <= 0 ? 0 : ((cashAmount - costBase) / cashAmount) * 100;
  double get breakEvenCohortEquivalents => cashAmount / 25000;

  DealCalculatorState copyWith({
    double? cashAmount,
    double? equityPercent,
    double? exitValuation,
    double? successProbability,
  }) {
    return DealCalculatorState(
      cashAmount: cashAmount ?? this.cashAmount,
      equityPercent: equityPercent ?? this.equityPercent,
      exitValuation: exitValuation ?? this.exitValuation,
      successProbability: successProbability ?? this.successProbability,
      costBase: costBase,
    );
  }
}

class StudioState {
  const StudioState({
    required this.projects,
    required this.deals,
    required this.calculator,
    required this.valuations,
    required this.stages,
  });

  final List<BuildProject> projects;
  final List<Deal> deals;
  final DealCalculatorState calculator;
  final Map<String, double> valuations;
  final Map<String, String> stages;

  StudioState copyWith({
    List<BuildProject>? projects,
    List<Deal>? deals,
    DealCalculatorState? calculator,
    Map<String, double>? valuations,
    Map<String, String>? stages,
  }) {
    return StudioState(
      projects: projects ?? this.projects,
      deals: deals ?? this.deals,
      calculator: calculator ?? this.calculator,
      valuations: valuations ?? this.valuations,
      stages: stages ?? this.stages,
    );
  }

  BuildProject? projectById(String id) {
    for (final project in projects) {
      if (project.id == id) {
        return project;
      }
    }
    return null;
  }
}

class StudioController extends StateNotifier<StudioState> {
  StudioController(this._prefs, this._activity)
    : super(
        StudioState(
          projects: _loadProjectOrder(_prefs, MockData.buildProjects()),
          deals: MockData.deals(),
          calculator: const DealCalculatorState(),
          valuations: _loadValuations(_prefs),
          stages: _loadStages(_prefs),
        ),
      );

  final PreferencesService _prefs;
  final ActivityFeedController _activity;

  void moveProject(String id, BuildStatus status) {
    final project = state.projectById(id);
    state = state.copyWith(
      projects: [
        for (final project in state.projects)
          if (project.id == id) project.copyWith(status: status) else project,
      ],
    );
    _activity.add(
      icon: Icons.view_kanban_rounded,
      description:
          'Build ${project?.startupName ?? id} moved to ${_statusLabel(status)}',
      route: '/studio/$id',
    );
    unawaited(_persistKanban());
  }

  void updateCalculator({
    double? cashAmount,
    double? equityPercent,
    double? exitValuation,
    double? successProbability,
  }) {
    state = state.copyWith(
      calculator: state.calculator.copyWith(
        cashAmount: cashAmount,
        equityPercent: equityPercent,
        exitValuation: exitValuation,
        successProbability: successProbability,
      ),
    );
  }

  void saveDeal() {
    final calculator = state.calculator;
    final type = calculator.cashAmount > 0 && calculator.equityPercent > 0
        ? DealType.hybrid
        : (calculator.cashAmount > 0 ? DealType.cash : DealType.equity);
    final deal = Deal(
      id: 'deal-${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      cashAmount: calculator.cashAmount.round(),
      equityPercent: calculator.equityPercent,
      founderName: 'New Studio Founder',
      signedDate: DateTime.now(),
      status: 'Modeled',
    );
    state = state.copyWith(deals: [deal, ...state.deals]);
    _activity.add(
      icon: Icons.payments_rounded,
      description: 'Studio deal saved for ${deal.founderName}',
      route: '/studio',
    );
  }

  void addQuickProject(BuildStatus status, String startupName) {
    final project = BuildProject(
      id: 'p-${DateTime.now().microsecondsSinceEpoch}',
      founderName: 'Quick-add founder',
      startupName: startupName.trim().isEmpty
          ? 'New Studio Build'
          : startupName.trim(),
      description:
          'Quick-added Studio project ready for discovery notes, builders, and deal modeling.',
      dealType: DealType.cash,
      cashAmount: 250000,
      equityPercent: 0,
      status: status,
      startDate: DateTime.now(),
      techStack: const ['Flutter', 'Nexus AI'],
      builderCount: 2,
      weeklyProgress: 1,
      retainerMonthly: 0,
    );
    state = state.copyWith(projects: [project, ...state.projects]);
    _activity.add(
      icon: Icons.add_circle_rounded,
      description: 'New Studio build: ${project.startupName}',
      route: '/studio/${project.id}',
    );
    unawaited(_persistKanban());
  }

  void updateValuation(String projectId, double value) {
    final valuations = {...state.valuations, projectId: value};
    state = state.copyWith(valuations: valuations);
    unawaited(_persistPortfolio());
  }

  void updateStage(String projectId, String stage) {
    final stages = {...state.stages, projectId: stage};
    state = state.copyWith(stages: stages);
    unawaited(_persistPortfolio());
  }

  static List<BuildProject> _loadProjectOrder(
    PreferencesService prefs,
    List<BuildProject> projects,
  ) {
    final raw = prefs.getStudioKanbanOrder();
    if (raw == null) {
      return projects;
    }
    try {
      final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final order = <String>[];
      for (final value in decoded.values) {
        if (value is List) {
          order.addAll(value.whereType<String>());
        }
      }
      final byId = {for (final project in projects) project.id: project};
      final ordered = [
        for (final id in order)
          if (byId[id] != null) byId[id]!,
      ];
      final rest = projects.where((project) => !order.contains(project.id));
      return [...ordered, ...rest];
    } catch (_) {
      return projects;
    }
  }

  static Map<String, double> _loadValuations(PreferencesService prefs) {
    final raw = prefs.getString('studio_portfolio_valuations');
    if (raw == null) {
      return const {};
    }
    try {
      final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      return decoded.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    } catch (_) {
      return const {};
    }
  }

  static Map<String, String> _loadStages(PreferencesService prefs) {
    final raw = prefs.getString('studio_portfolio_stages');
    if (raw == null) {
      return const {};
    }
    try {
      final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {
      return const {};
    }
  }

  Future<void> _persistKanban() async {
    final columns = <String, List<String>>{};
    for (final status in BuildStatus.values) {
      columns[status.name] = [
        for (final project in state.projects.where(
          (project) => project.status == status,
        ))
          project.id,
      ];
    }
    await _prefs.setStudioKanbanOrder(jsonEncode(columns));
  }

  Future<void> _persistPortfolio() async {
    await _prefs.setString(
      'studio_portfolio_valuations',
      jsonEncode(state.valuations),
    );
    await _prefs.setString('studio_portfolio_stages', jsonEncode(state.stages));
  }

  String _statusLabel(BuildStatus status) {
    return switch (status) {
      BuildStatus.discovery => 'Discovery',
      BuildStatus.sprint => 'Sprint',
      BuildStatus.qa => 'QA',
      BuildStatus.live => 'Live',
      BuildStatus.retainer => 'Retainer',
    };
  }
}
