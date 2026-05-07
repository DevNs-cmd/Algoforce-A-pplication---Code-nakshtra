import 'dart:math';

import '../domain/venture_object.dart';

class VentureFactory {
  static VentureObject create({
    required VentureDraft draft,
    required String founderId,
  }) {
    final now = DateTime.now();
    final idea = draft.idea.trim();
    final ventureName = _nameFromIdea(idea, draft.industry);
    final mvpScope = MvpScopeDefinition(
      coreFeatures: const [
        'Authenticated founder workspace',
        'Venture Object creation flow',
        'Execution state machine API',
        'Equity ledger with milestone unlocks',
        'Realtime execution updates',
      ],
      excludedFeatures: const [
        'Investor marketplace',
        'Multi-company portfolio operations',
      ],
      expectedWeeks: 8,
      architectureOutputs: const [],
      scopeReducedByGenome: false,
    );
    final businessModel = BusinessModelStructure(
      model: draft.businessModel,
      pricePoint: draft.pricing,
      channels: const ['Founder referrals', 'Startup studio partnerships'],
      grossMarginPercent: draft.businessModel == 'Services + equity' ? 62 : 82,
    );
    final capital = FinancialModelingEngine.requirements(draft, mvpScope);
    final genome = StartupGenomeEngine.compute(
      draft: draft,
      mvpScope: mvpScope,
      capital: capital,
    );
    final equity = EquityEngine.calculate(
      genome: genome,
      launchBudget: draft.launchBudget,
    );
    final financialModel = FinancialModelingEngine.project(
      businessModel: businessModel,
      capital: capital,
      genome: genome,
    );
    final network = NetworkEffectEngine.map(
      draft: draft,
      genome: genome,
      team: const TeamStructure(
        founderRole: 'Venture owner',
        requiredRoles: [
          'Product architect',
          'Flutter engineer',
          'Spring Boot engineer',
          'Growth operator',
        ],
        assignedRoles: ['Founder', 'AlgoForce Core Engine'],
      ),
    );

    return VentureObject(
      id: 'venture-${now.microsecondsSinceEpoch}',
      name: ventureName,
      founderId: founderId,
      ideaMetadata: IdeaMetadata(
        idea: idea,
        industry: draft.industry,
        targetCustomer: draft.targetCustomer.trim(),
        problem: draft.problem.trim(),
        createdAt: now,
      ),
      marketHypothesis: MarketHypothesis(
        customerSegment: draft.targetCustomer.trim(),
        problemSeverity: 'High if users already pay for slow manual execution',
        alternatives: const [
          'Freelance build shops',
          'Accelerators',
          'Internal no-code prototypes',
        ],
        whyNow: 'AI-native execution can compress validation and MVP delivery.',
      ),
      businessModel: businessModel,
      mvpScope: mvpScope,
      executionState: VentureState.ideaCaptured,
      teamStructure: const TeamStructure(
        founderRole: 'Venture owner',
        requiredRoles: [
          'Product architect',
          'Flutter engineer',
          'Spring Boot engineer',
          'Growth operator',
        ],
        assignedRoles: ['Founder', 'AlgoForce Core Engine'],
      ),
      capitalRequirement: capital,
      equityStructure: equity,
      riskScore: RiskScoreModel(
        overallRisk: genome.riskFailureProbability,
        blockers: _initialBlockers(draft, genome),
        transitionAllowed: false,
      ),
      milestoneEngine: MilestoneEngine(
        milestones: _milestones(),
        validationFailures: const [],
      ),
      genome: genome,
      financialModel: financialModel,
      networkEffect: network,
      executionTasks: ExecutionEngine.initialPipeline(),
      mvpArtifacts: const [],
      events: [
        CapitalEvent(
          name: 'VentureCreatedEvent',
          message: 'Venture Object created as financial execution unit.',
          timestamp: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }

  static String _nameFromIdea(String idea, String industry) {
    final words = idea
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 2)
        .take(2)
        .join(' ');
    return words.isEmpty ? '$industry Venture' : words;
  }

  static List<String> _initialBlockers(
    VentureDraft draft,
    StartupGenome genome,
  ) {
    final blockers = <String>[];
    if (draft.problem.trim().length < 18) {
      blockers.add('Problem evidence is too thin for validation.');
    }
    if (genome.marketSaturationIndex > 72) {
      blockers.add('Market saturation requires sharper wedge.');
    }
    if (draft.launchBudget < 25000) {
      blockers.add('Capital requirement below realistic MVP threshold.');
    }
    return blockers;
  }

  static List<Milestone> _milestones() {
    return const [
      Milestone(
        id: 'validate',
        title: 'Market hypothesis validated',
        requiredState: VentureState.ideaCaptured,
        status: MilestoneStatus.ready,
        requiredEvidence: ['Problem statement', 'Target customer', 'Budget'],
      ),
      Milestone(
        id: 'blueprint',
        title: 'Blueprint generated',
        requiredState: VentureState.validated,
        status: MilestoneStatus.locked,
        requiredEvidence: ['Genome score', 'MVP scope', 'Capital model'],
      ),
      Milestone(
        id: 'mvp',
        title: 'MVP completed',
        requiredState: VentureState.mvpInBuild,
        status: MilestoneStatus.locked,
        requiredEvidence: ['All execution tasks completed'],
      ),
      Milestone(
        id: 'launch',
        title: 'Launch evidence accepted',
        requiredState: VentureState.mvpCompleted,
        status: MilestoneStatus.locked,
        requiredEvidence: ['Pilot users', 'Production release'],
      ),
      Milestone(
        id: 'traction',
        title: 'Traction evidence accepted',
        requiredState: VentureState.launched,
        status: MilestoneStatus.locked,
        requiredEvidence: ['User acquisition', 'Revenue event'],
      ),
    ];
  }
}

class StartupGenomeEngine {
  static StartupGenome compute({
    required VentureDraft draft,
    required MvpScopeDefinition mvpScope,
    required CapitalRequirementModel capital,
  }) {
    final seed =
        draft.idea.length +
        draft.problem.length * 2 +
        draft.targetCustomer.length +
        draft.businessModel.length * 3;
    final marketSaturation = _clamp(36 + seed % 52);
    final complexity = _clamp(
      38 +
          mvpScope.coreFeatures.length * 7 +
          (capital.buildBudget < 40000 ? 12 : 0),
    );
    final timeToMvp = max(4, mvpScope.expectedWeeks + complexity ~/ 20);
    final viability = _clamp(
      76 + draft.problem.length ~/ 8 - marketSaturation ~/ 4 - complexity ~/ 6,
    );
    final funding = _clamp(
      42 + viability ~/ 2 - marketSaturation ~/ 7 + capital.runwayMonths,
    );
    final failure = _clamp(100 - viability + complexity ~/ 4);
    final directive = failure > 58 || complexity > 68
        ? 'Reduce MVP to one monetizable wedge before build starts.'
        : 'Proceed with full MVP scope after evidence gates.';

    return StartupGenome(
      ventureViability: viability,
      marketSaturationIndex: marketSaturation,
      executionComplexityIndex: complexity,
      fundingProbability: funding,
      expectedTimeToMvpWeeks: timeToMvp,
      riskFailureProbability: failure,
      scopeDirective: directive,
    );
  }

  static int _clamp(int value) => value.clamp(0, 100);
}

class EquityEngine {
  static EquityStructure calculate({
    required StartupGenome genome,
    required double launchBudget,
  }) {
    final recommended = genome.executionComplexityIndex > 70
        ? 12.0
        : genome.riskFailureProbability > 55
        ? 10.0
        : launchBudget > 120000
        ? 5.0
        : 8.0;
    return EquityStructure(
      founderEquity: 100 - recommended,
      algoForceEquity: recommended,
      vestingMonths: 24,
      cliffMonths: 6,
      elapsedMonths: 0,
      unlockedAlgoForceEquity: 0,
      unlockRules: [
        EquityUnlockRule(
          key: 'mvp_complete',
          trigger: 'MVP complete',
          percent: recommended * 0.40,
          requiredState: VentureState.mvpCompleted,
          unlocked: false,
          failureReason: null,
        ),
        EquityUnlockRule(
          key: 'users_acquired',
          trigger: 'User acquisition milestone',
          percent: recommended * 0.30,
          requiredState: VentureState.tractionActive,
          unlocked: false,
          failureReason: null,
        ),
        EquityUnlockRule(
          key: 'revenue_validated',
          trigger: 'Revenue milestone',
          percent: recommended * 0.30,
          requiredState: VentureState.fundraisingReady,
          unlocked: false,
          failureReason: null,
        ),
      ],
    );
  }

  static EquityStructure processUnlocks(VentureObject venture) {
    final equity = venture.equityStructure;
    var unlockedTotal = equity.unlockedAlgoForceEquity;
    final nextRules = equity.unlockRules.map((rule) {
      if (rule.unlocked) {
        return rule;
      }
      if (equity.elapsedMonths < equity.cliffMonths) {
        return rule.copyWith(failureReason: '6-month cliff not reached.');
      }
      if (venture.executionState.index < rule.requiredState.index) {
        return rule.copyWith(
          failureReason: 'Requires ${rule.requiredState.label}.',
        );
      }
      unlockedTotal += rule.percent;
      return rule.copyWith(unlocked: true, failureReason: null);
    }).toList();

    return equity.copyWith(
      unlockedAlgoForceEquity: min(equity.algoForceEquity, unlockedTotal),
      unlockRules: nextRules,
    );
  }
}

class ExecutionEngine {
  static List<ExecutionTask> initialPipeline() {
    return const [
      ExecutionTask(
        id: 'spring-auth',
        title: 'Generate Spring Boot auth boundary',
        ownerLogic: 'Backend generation logic',
        status: ExecutionTaskStatus.blocked,
        requiredEvidence: ['JWT contract', 'user entity', 'gateway route'],
        evidence: [],
      ),
      ExecutionTask(
        id: 'venture-api',
        title: 'Create Venture API and state transition endpoint',
        ownerLogic: 'Venture Service',
        status: ExecutionTaskStatus.blocked,
        requiredEvidence: ['venture schema', 'transition guard', 'event emit'],
        evidence: [],
      ),
      ExecutionTask(
        id: 'equity-ledger',
        title: 'Attach equity ledger and cliff policy',
        ownerLogic: 'Equity Service',
        status: ExecutionTaskStatus.blocked,
        requiredEvidence: ['vesting rules', 'ledger append', 'unlock guard'],
        evidence: [],
      ),
      ExecutionTask(
        id: 'mobile-flow',
        title: 'Render state-driven Flutter venture flow',
        ownerLogic: 'Mobile build logic',
        status: ExecutionTaskStatus.blocked,
        requiredEvidence: ['creation', 'execution', 'finance', 'intelligence'],
        evidence: [],
      ),
    ];
  }

  static List<ExecutionTask> startBuild(List<ExecutionTask> tasks) {
    return tasks
        .map(
          (task) => task.id == 'spring-auth'
              ? task.copyWith(status: ExecutionTaskStatus.ready)
              : task,
        )
        .toList();
  }

  static List<ExecutionTask> submitEvidence({
    required List<ExecutionTask> tasks,
    required String taskId,
    required String evidence,
  }) {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      return tasks;
    }

    final next = [...tasks];
    final task = next[index];
    final mergedEvidence = {
      ...task.evidence,
      evidence.trim(),
    }.where((item) => item.isNotEmpty).toList();
    final complete = mergedEvidence.length >= task.requiredEvidence.length;
    next[index] = task.copyWith(
      evidence: mergedEvidence,
      status: complete
          ? ExecutionTaskStatus.completed
          : ExecutionTaskStatus.inProgress,
    );

    if (complete && index + 1 < next.length) {
      final following = next[index + 1];
      if (following.status == ExecutionTaskStatus.blocked) {
        next[index + 1] = following.copyWith(status: ExecutionTaskStatus.ready);
      }
    }
    return next;
  }

  static bool allComplete(List<ExecutionTask> tasks) {
    return tasks.every((task) => task.status == ExecutionTaskStatus.completed);
  }
}

class MvpBuildEngine {
  static List<MvpBuildArtifact> generateArtifacts(VentureObject venture) {
    return [
      const MvpBuildArtifact(
        layer: 'Java Spring Boot',
        outputs: [
          'Auth Service',
          'Venture Service',
          'Execution Service',
          'Equity Service',
          'Financial Modeling Service',
        ],
        apiContracts: [
          'POST /ventures',
          'POST /ventures/{id}/transition',
          'POST /execution/{id}/evidence',
          'GET /equity/{id}',
        ],
      ),
      MvpBuildArtifact(
        layer: 'Flutter Mobile',
        outputs: [
          'Login and sign-in gate',
          'Venture Creation Screen',
          'Venture Execution Screen',
          'Equity & Finance Screen',
          'Intelligence Engine Screen',
          '${venture.name} dynamic rendering',
        ],
        apiContracts: const [
          'GET /ventures/{id}',
          'PATCH /ventures/{id}/state',
          'WS /execution/{id}',
        ],
      ),
      const MvpBuildArtifact(
        layer: 'Event System',
        outputs: [
          'VentureCreatedEvent',
          'MVPBuildStartedEvent',
          'MilestoneCompletedEvent',
          'EquityUpdatedEvent',
        ],
        apiContracts: [
          'Kafka topic capitalos.venture',
          'Kafka topic capitalos.execution',
        ],
      ),
    ];
  }
}

class FinancialModelingEngine {
  static CapitalRequirementModel requirements(
    VentureDraft draft,
    MvpScopeDefinition scope,
  ) {
    final monthlyBurn = 14000 + scope.coreFeatures.length * 2200;
    final runway = draft.launchBudget < 40000 ? 4 : 6;
    return CapitalRequirementModel(
      buildBudget: draft.launchBudget,
      monthlyBurn: monthlyBurn.toDouble(),
      runwayMonths: runway,
      fundingRequired: draft.launchBudget + monthlyBurn * runway,
    );
  }

  static FinancialModel project({
    required BusinessModelStructure businessModel,
    required CapitalRequirementModel capital,
    required StartupGenome genome,
  }) {
    final revenue =
        businessModel.pricePoint * max(30, genome.fundingProbability);
    final valuation = max(
      500000,
      revenue * 12 * 5 * (genome.ventureViability / 100),
    ).toDouble();
    final breakEven = max(
      3,
      (capital.monthlyBurn /
              max(1, revenue * businessModel.grossMarginPercent / 100))
          .ceil(),
    );
    return FinancialModel(
      projectedMonthlyRevenue: revenue.toDouble(),
      monthlyBurn: capital.monthlyBurn,
      breakEvenMonth: breakEven,
      fundingRequirement: capital.fundingRequired,
      valuationEstimate: valuation,
    );
  }
}

class NetworkEffectEngine {
  static NetworkEffectModel map({
    required VentureDraft draft,
    required StartupGenome genome,
    required TeamStructure team,
  }) {
    final investorScore =
        (genome.fundingProbability + genome.ventureViability) ~/ 2;
    final talentScore = max(
      30,
      100 - genome.executionComplexityIndex + team.requiredRoles.length * 4,
    );
    final similarityScore = min(
      100,
      draft.industry.length * 7 + draft.targetCustomer.length,
    );
    return NetworkEffectModel(
      investorMappingScore: investorScore,
      talentMatchScore: talentScore,
      similarityGraphScore: similarityScore,
      recommendedInvestorProfiles: [
        '${draft.industry} seed funds',
        'Operator angels with ${draft.businessModel.toLowerCase()} experience',
      ],
      requiredTalentSignals: team.requiredRoles,
    );
  }
}

class CapitalStateMachine {
  static VentureTransitionResult validate(VentureObject venture) {
    final failures = <String>[
      if (venture.ideaMetadata.idea.length < 12)
        'Idea needs a sharper venture thesis.',
      if (venture.ideaMetadata.problem.length < 18)
        'Problem evidence must be more specific.',
      if (venture.capitalRequirement.buildBudget < 25000)
        'MVP budget below execution floor.',
      if (venture.genome.ventureViability < 45)
        'Genome viability is below validation threshold.',
    ];
    if (failures.isNotEmpty) {
      return VentureTransitionResult.blocked(failures);
    }
    return const VentureTransitionResult.allowed(VentureState.validated);
  }

  static VentureTransitionResult blueprint(VentureObject venture) {
    if (venture.executionState != VentureState.validated) {
      return const VentureTransitionResult.blocked([
        'Venture must be VALIDATED before blueprint generation.',
      ]);
    }
    return const VentureTransitionResult.allowed(
      VentureState.blueprintGenerated,
    );
  }

  static VentureTransitionResult startMvp(VentureObject venture) {
    if (venture.executionState != VentureState.blueprintGenerated) {
      return const VentureTransitionResult.blocked([
        'Blueprint must exist before MVP build can start.',
      ]);
    }
    if (venture.riskScore.overallRisk > 72) {
      return const VentureTransitionResult.blocked([
        'Risk exceeds build threshold. Apply scope reduction first.',
      ]);
    }
    return const VentureTransitionResult.allowed(VentureState.mvpInBuild);
  }

  static VentureTransitionResult completeMvp(VentureObject venture) {
    if (!ExecutionEngine.allComplete(venture.executionTasks)) {
      return const VentureTransitionResult.blocked([
        'All MVP execution tasks require evidence before MVP completion.',
      ]);
    }
    return const VentureTransitionResult.allowed(VentureState.mvpCompleted);
  }

  static VentureTransitionResult launch(VentureObject venture) {
    if (venture.executionState != VentureState.mvpCompleted) {
      return const VentureTransitionResult.blocked([
        'MVP must be completed before launch.',
      ]);
    }
    return const VentureTransitionResult.allowed(VentureState.launched);
  }

  static VentureTransitionResult traction(VentureObject venture) {
    if (venture.executionState != VentureState.launched) {
      return const VentureTransitionResult.blocked([
        'Launch state required before traction activation.',
      ]);
    }
    if (venture.networkEffect.investorMappingScore < 45) {
      return const VentureTransitionResult.blocked([
        'Network mapping is too weak. Improve founder-investor fit.',
      ]);
    }
    return const VentureTransitionResult.allowed(VentureState.tractionActive);
  }

  static VentureTransitionResult fundraising(VentureObject venture) {
    if (venture.executionState != VentureState.tractionActive) {
      return const VentureTransitionResult.blocked([
        'Traction evidence required before fundraising readiness.',
      ]);
    }
    if (venture.genome.fundingProbability < 55) {
      return const VentureTransitionResult.blocked([
        'Funding probability is below readiness threshold.',
      ]);
    }
    return const VentureTransitionResult.allowed(VentureState.fundraisingReady);
  }
}

class VentureTransitionResult {
  const VentureTransitionResult({
    required this.allowed,
    required this.failures,
    this.nextState,
  });

  const VentureTransitionResult.allowed(VentureState state)
    : allowed = true,
      nextState = state,
      failures = const [];

  const VentureTransitionResult.blocked(List<String> reasons)
    : allowed = false,
      nextState = null,
      failures = reasons;

  final bool allowed;
  final VentureState? nextState;
  final List<String> failures;
}
