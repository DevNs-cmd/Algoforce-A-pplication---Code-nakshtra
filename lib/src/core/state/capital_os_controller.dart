import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/venture_object.dart';
import '../engines/capital_os_engines.dart';

final capitalOsControllerProvider =
    StateNotifierProvider<CapitalOsController, CapitalOsState>(
      (ref) => CapitalOsController(),
    );

class AuthSession {
  const AuthSession({
    required this.userId,
    required this.email,
    required this.displayName,
  });

  final String userId;
  final String email;
  final String displayName;
}

class CapitalOsState {
  const CapitalOsState({
    this.session,
    this.draft = const VentureDraft(),
    this.venture,
    this.activeIndex = 0,
    this.authIsCreatingAccount = false,
    this.lastMessage,
  });

  final AuthSession? session;
  final VentureDraft draft;
  final VentureObject? venture;
  final int activeIndex;
  final bool authIsCreatingAccount;
  final String? lastMessage;

  bool get isAuthenticated => session != null;

  CapitalOsState copyWith({
    AuthSession? session,
    bool clearSession = false,
    VentureDraft? draft,
    VentureObject? venture,
    int? activeIndex,
    bool? authIsCreatingAccount,
    String? lastMessage,
  }) {
    return CapitalOsState(
      session: clearSession ? null : session ?? this.session,
      draft: draft ?? this.draft,
      venture: venture ?? this.venture,
      activeIndex: activeIndex ?? this.activeIndex,
      authIsCreatingAccount:
          authIsCreatingAccount ?? this.authIsCreatingAccount,
      lastMessage: lastMessage,
    );
  }
}

class CapitalOsController extends StateNotifier<CapitalOsState> {
  CapitalOsController() : super(const CapitalOsState());

  void toggleAuthMode() {
    state = state.copyWith(
      authIsCreatingAccount: !state.authIsCreatingAccount,
      lastMessage: null,
    );
  }

  void signIn({required String email, required String displayName}) {
    final normalizedEmail = email.trim().isEmpty
        ? 'founder@algoforce.ai'
        : email.trim();
    final name = displayName.trim().isEmpty ? 'Founder' : displayName.trim();
    state = state.copyWith(
      session: AuthSession(
        userId: 'founder-${normalizedEmail.hashCode.abs()}',
        email: normalizedEmail,
        displayName: name,
      ),
      lastMessage: 'Session established for $name.',
    );
  }

  void signOut() {
    state = const CapitalOsState();
  }

  void updateDraft(VentureDraft draft) {
    state = state.copyWith(draft: draft, lastMessage: null);
  }

  void createVentureObject() {
    final session = state.session;
    if (session == null) {
      state = state.copyWith(
        lastMessage: 'Login required before venture creation.',
      );
      return;
    }
    final venture = VentureFactory.create(
      draft: state.draft,
      founderId: session.userId,
    );
    state = state.copyWith(
      venture: venture,
      activeIndex: 0,
      lastMessage: 'VentureCreatedEvent emitted for ${venture.name}.',
    );
  }

  void validateVenture() {
    final venture = state.venture;
    if (venture == null) {
      state = state.copyWith(lastMessage: 'Create a Venture Object first.');
      return;
    }
    final result = CapitalStateMachine.validate(venture);
    _applyTransition(
      result: result,
      successEvent: 'VentureValidatedEvent',
      successMessage:
          'Validation passed. Blueprint generation is now unlocked.',
    );
  }

  void generateBlueprint() {
    final venture = state.venture;
    if (venture == null) {
      state = state.copyWith(lastMessage: 'Create a Venture Object first.');
      return;
    }
    final result = CapitalStateMachine.blueprint(venture);
    if (!result.allowed) {
      _block(result.failures);
      return;
    }

    final artifacts = MvpBuildEngine.generateArtifacts(venture);
    final scoped = venture.mvpScope.copyWith(
      architectureOutputs: artifacts
          .expand(
            (artifact) =>
                artifact.outputs.map((item) => '${artifact.layer}: $item'),
          )
          .toList(),
    );
    _replaceVenture(
      venture.copyWith(
        executionState: result.nextState,
        mvpScope: scoped,
        mvpArtifacts: artifacts,
        milestoneEngine: _markMilestone(venture, 'blueprint'),
        events: _event(
          venture,
          'BlueprintGeneratedEvent',
          'MVP architecture and financial execution structure generated.',
        ),
      ),
      'BlueprintGeneratedEvent emitted. MVP build can now be requested.',
    );
  }

  void requestMvpBuild() {
    final venture = state.venture;
    if (venture == null) {
      state = state.copyWith(lastMessage: 'Create a Venture Object first.');
      return;
    }
    final result = CapitalStateMachine.startMvp(venture);
    if (!result.allowed) {
      _block(result.failures);
      return;
    }
    _replaceVenture(
      venture.copyWith(
        executionState: result.nextState,
        executionTasks: ExecutionEngine.startBuild(venture.executionTasks),
        milestoneEngine: _unlockMilestone(venture, 'mvp'),
        events: _event(
          venture,
          'MVPBuildStartedEvent',
          'Execution pipeline generated and first build task unblocked.',
        ),
      ),
      'MVPBuildStartedEvent emitted. Evidence is now required per task.',
      activeIndex: 1,
    );
  }

  void submitTaskEvidence({required String taskId, required String evidence}) {
    final venture = state.venture;
    if (venture == null) {
      return;
    }
    if (venture.executionState != VentureState.mvpInBuild) {
      _block([
        'MVP build must be active before task evidence can be accepted.',
      ]);
      return;
    }
    final tasks = ExecutionEngine.submitEvidence(
      tasks: venture.executionTasks,
      taskId: taskId,
      evidence: evidence,
    );
    var nextVenture = venture.copyWith(
      executionTasks: tasks,
      events: _event(
        venture,
        'MilestoneEvidenceEvent',
        'Evidence added to $taskId.',
      ),
    );
    if (ExecutionEngine.allComplete(tasks)) {
      final result = CapitalStateMachine.completeMvp(nextVenture);
      if (result.allowed) {
        nextVenture = nextVenture.copyWith(
          executionState: result.nextState,
          milestoneEngine: _markMilestone(nextVenture, 'mvp'),
          events: _event(
            nextVenture,
            'MilestoneCompletedEvent',
            'MVP completion accepted after all task evidence passed.',
          ),
        );
      }
    }
    _replaceVenture(nextVenture, 'Execution evidence processed.');
  }

  void launchVenture() {
    final venture = state.venture;
    if (venture == null) {
      return;
    }
    _applyTransition(
      result: CapitalStateMachine.launch(venture),
      successEvent: 'VentureLaunchedEvent',
      successMessage: 'Launch evidence accepted. Traction activation is next.',
    );
  }

  void activateTraction() {
    final venture = state.venture;
    if (venture == null) {
      return;
    }
    _applyTransition(
      result: CapitalStateMachine.traction(venture),
      successEvent: 'TractionActivatedEvent',
      successMessage: 'Traction evidence accepted and equity rules rechecked.',
      processEquity: true,
    );
  }

  void markFundraisingReady() {
    final venture = state.venture;
    if (venture == null) {
      return;
    }
    _applyTransition(
      result: CapitalStateMachine.fundraising(venture),
      successEvent: 'FundraisingReadyEvent',
      successMessage: 'Funding readiness accepted and equity rules rechecked.',
      processEquity: true,
    );
  }

  void simulateCliffReached() {
    final venture = state.venture;
    if (venture == null) {
      return;
    }
    final withCliff = venture.copyWith(
      equityStructure: venture.equityStructure.copyWith(
        elapsedMonths: max(
          venture.equityStructure.elapsedMonths,
          venture.equityStructure.cliffMonths,
        ),
      ),
    );
    _replaceVenture(
      withCliff.copyWith(
        equityStructure: EquityEngine.processUnlocks(withCliff),
        events: _event(
          withCliff,
          'EquityUpdatedEvent',
          'Cliff condition reached and unlock rules processed.',
        ),
      ),
      'EquityUpdatedEvent emitted after cliff simulation.',
    );
  }

  void updateValuation(double valuation) {
    final venture = state.venture;
    if (venture == null) {
      return;
    }
    _replaceVenture(
      venture.copyWith(
        financialModel: venture.financialModel.copyWith(
          valuationEstimate: valuation,
        ),
        events: _event(
          venture,
          'FinancialModelUpdatedEvent',
          'Valuation simulation changed capital model.',
        ),
      ),
      'Valuation simulation updated the Venture Object.',
    );
  }

  void recomputeGenome() {
    final venture = state.venture;
    if (venture == null) {
      return;
    }
    final draft = state.draft;
    final genome = StartupGenomeEngine.compute(
      draft: draft,
      mvpScope: venture.mvpScope,
      capital: venture.capitalRequirement,
    );
    final equity = EquityEngine.calculate(
      genome: genome,
      launchBudget: venture.capitalRequirement.buildBudget,
    );
    _replaceVenture(
      venture.copyWith(
        genome: genome,
        equityStructure: equity,
        riskScore: RiskScoreModel(
          overallRisk: genome.riskFailureProbability,
          blockers: genome.riskFailureProbability > 58
              ? ['Genome recommends MVP scope reduction.']
              : const [],
          transitionAllowed: genome.riskFailureProbability <= 72,
        ),
        events: _event(
          venture,
          'IntelligenceRecomputedEvent',
          'Startup Genome recomputed risk, equity, and funding probability.',
        ),
      ),
      'Startup Genome recomputed and equity recommendation refreshed.',
    );
  }

  void applyScopeReduction() {
    final venture = state.venture;
    if (venture == null) {
      return;
    }
    final reducedScope = venture.mvpScope.copyWith(
      coreFeatures: venture.mvpScope.coreFeatures.take(3).toList(),
      excludedFeatures: [
        ...venture.mvpScope.excludedFeatures,
        'Realtime chat until launch proof',
        'Advanced investor graph until traction',
      ],
      expectedWeeks: max(4, venture.mvpScope.expectedWeeks - 2),
      scopeReducedByGenome: true,
    );
    final capital = CapitalRequirementModel(
      buildBudget: venture.capitalRequirement.buildBudget * 0.82,
      monthlyBurn: venture.capitalRequirement.monthlyBurn * 0.84,
      runwayMonths: venture.capitalRequirement.runwayMonths,
      fundingRequired: venture.capitalRequirement.fundingRequired * 0.84,
    );
    final genome = StartupGenome(
      ventureViability: min(100, venture.genome.ventureViability + 7),
      marketSaturationIndex: venture.genome.marketSaturationIndex,
      executionComplexityIndex: max(
        0,
        venture.genome.executionComplexityIndex - 16,
      ),
      fundingProbability: min(100, venture.genome.fundingProbability + 6),
      expectedTimeToMvpWeeks: max(4, venture.genome.expectedTimeToMvpWeeks - 2),
      riskFailureProbability: max(
        0,
        venture.genome.riskFailureProbability - 13,
      ),
      scopeDirective: 'Reduced MVP accepted. Build threshold improved.',
    );
    _replaceVenture(
      venture.copyWith(
        mvpScope: reducedScope,
        capitalRequirement: capital,
        genome: genome,
        riskScore: RiskScoreModel(
          overallRisk: genome.riskFailureProbability,
          blockers: const [],
          transitionAllowed: true,
        ),
        events: _event(
          venture,
          'MvpScopeReducedEvent',
          'Genome directive reduced complexity and funding risk.',
        ),
      ),
      'Scope reduction applied to Venture Object.',
    );
  }

  void setActiveIndex(int index) {
    state = state.copyWith(activeIndex: index);
  }

  void _applyTransition({
    required VentureTransitionResult result,
    required String successEvent,
    required String successMessage,
    bool processEquity = false,
  }) {
    final venture = state.venture;
    if (venture == null) {
      return;
    }
    if (!result.allowed) {
      _block(result.failures);
      return;
    }
    var nextVenture = venture.copyWith(
      executionState: result.nextState,
      milestoneEngine: _markMilestoneByState(venture, result.nextState!),
      events: _event(venture, successEvent, successMessage),
    );
    if (processEquity) {
      nextVenture = nextVenture.copyWith(
        equityStructure: EquityEngine.processUnlocks(nextVenture),
      );
    }
    _replaceVenture(nextVenture, successMessage);
  }

  void _replaceVenture(
    VentureObject venture,
    String message, {
    int? activeIndex,
  }) {
    state = state.copyWith(
      venture: venture,
      activeIndex: activeIndex,
      lastMessage: message,
    );
  }

  void _block(List<String> failures) {
    final venture = state.venture;
    if (venture == null) {
      state = state.copyWith(lastMessage: failures.join(' '));
      return;
    }
    state = state.copyWith(
      venture: venture.copyWith(
        milestoneEngine: venture.milestoneEngine.copyWith(
          validationFailures: failures,
        ),
        riskScore: RiskScoreModel(
          overallRisk: min(100, venture.riskScore.overallRisk + 3),
          blockers: failures,
          transitionAllowed: false,
        ),
        events: _event(venture, 'TransitionBlockedEvent', failures.join(' ')),
      ),
      lastMessage: failures.join(' '),
    );
  }

  MilestoneEngine _markMilestone(VentureObject venture, String milestoneId) {
    return venture.milestoneEngine.copyWith(
      milestones: venture.milestoneEngine.milestones.map((milestone) {
        if (milestone.id == milestoneId) {
          return milestone.copyWith(status: MilestoneStatus.completed);
        }
        if (milestone.status == MilestoneStatus.locked) {
          return milestone.copyWith(status: MilestoneStatus.ready);
        }
        return milestone;
      }).toList(),
      validationFailures: const [],
    );
  }

  MilestoneEngine _unlockMilestone(VentureObject venture, String milestoneId) {
    return venture.milestoneEngine.copyWith(
      milestones: venture.milestoneEngine.milestones
          .map(
            (milestone) => milestone.id == milestoneId
                ? milestone.copyWith(status: MilestoneStatus.ready)
                : milestone,
          )
          .toList(),
      validationFailures: const [],
    );
  }

  MilestoneEngine _markMilestoneByState(
    VentureObject venture,
    VentureState state,
  ) {
    final milestoneId = switch (state) {
      VentureState.validated => 'validate',
      VentureState.mvpCompleted => 'mvp',
      VentureState.launched => 'launch',
      VentureState.tractionActive => 'traction',
      _ => '',
    };
    return milestoneId.isEmpty
        ? venture.milestoneEngine.copyWith(validationFailures: const [])
        : _markMilestone(venture, milestoneId);
  }

  List<CapitalEvent> _event(
    VentureObject venture,
    String name,
    String message,
  ) {
    return [
      CapitalEvent(name: name, message: message, timestamp: DateTime.now()),
      ...venture.events,
    ];
  }
}
