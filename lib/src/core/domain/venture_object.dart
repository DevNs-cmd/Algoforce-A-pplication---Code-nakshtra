enum VentureState {
  ideaCaptured,
  validated,
  blueprintGenerated,
  mvpInBuild,
  mvpCompleted,
  launched,
  tractionActive,
  fundraisingReady,
  scaling,
}

enum ExecutionTaskStatus { blocked, ready, inProgress, completed }

enum MilestoneStatus { locked, ready, completed }

extension VentureStateText on VentureState {
  String get label => switch (this) {
    VentureState.ideaCaptured => 'IDEA_CAPTURED',
    VentureState.validated => 'VALIDATED',
    VentureState.blueprintGenerated => 'BLUEPRINT_GENERATED',
    VentureState.mvpInBuild => 'MVP_IN_BUILD',
    VentureState.mvpCompleted => 'MVP_COMPLETED',
    VentureState.launched => 'LAUNCHED',
    VentureState.tractionActive => 'TRACTION_ACTIVE',
    VentureState.fundraisingReady => 'FUNDRAISING_READY',
    VentureState.scaling => 'SCALING',
  };
}

extension ExecutionTaskStatusText on ExecutionTaskStatus {
  String get label => switch (this) {
    ExecutionTaskStatus.blocked => 'Blocked',
    ExecutionTaskStatus.ready => 'Ready',
    ExecutionTaskStatus.inProgress => 'In progress',
    ExecutionTaskStatus.completed => 'Completed',
  };
}

class VentureDraft {
  const VentureDraft({
    this.idea = '',
    this.industry = 'AI SaaS',
    this.targetCustomer = '',
    this.problem = '',
    this.businessModel = 'Subscription',
    this.pricing = 99,
    this.launchBudget = 50000,
  });

  final String idea;
  final String industry;
  final String targetCustomer;
  final String problem;
  final String businessModel;
  final double pricing;
  final double launchBudget;

  VentureDraft copyWith({
    String? idea,
    String? industry,
    String? targetCustomer,
    String? problem,
    String? businessModel,
    double? pricing,
    double? launchBudget,
  }) {
    return VentureDraft(
      idea: idea ?? this.idea,
      industry: industry ?? this.industry,
      targetCustomer: targetCustomer ?? this.targetCustomer,
      problem: problem ?? this.problem,
      businessModel: businessModel ?? this.businessModel,
      pricing: pricing ?? this.pricing,
      launchBudget: launchBudget ?? this.launchBudget,
    );
  }
}

class IdeaMetadata {
  const IdeaMetadata({
    required this.idea,
    required this.industry,
    required this.targetCustomer,
    required this.problem,
    required this.createdAt,
  });

  final String idea;
  final String industry;
  final String targetCustomer;
  final String problem;
  final DateTime createdAt;
}

class MarketHypothesis {
  const MarketHypothesis({
    required this.customerSegment,
    required this.problemSeverity,
    required this.alternatives,
    required this.whyNow,
  });

  final String customerSegment;
  final String problemSeverity;
  final List<String> alternatives;
  final String whyNow;
}

class BusinessModelStructure {
  const BusinessModelStructure({
    required this.model,
    required this.pricePoint,
    required this.channels,
    required this.grossMarginPercent,
  });

  final String model;
  final double pricePoint;
  final List<String> channels;
  final double grossMarginPercent;
}

class MvpScopeDefinition {
  const MvpScopeDefinition({
    required this.coreFeatures,
    required this.excludedFeatures,
    required this.expectedWeeks,
    required this.architectureOutputs,
    required this.scopeReducedByGenome,
  });

  final List<String> coreFeatures;
  final List<String> excludedFeatures;
  final int expectedWeeks;
  final List<String> architectureOutputs;
  final bool scopeReducedByGenome;

  MvpScopeDefinition copyWith({
    List<String>? coreFeatures,
    List<String>? excludedFeatures,
    int? expectedWeeks,
    List<String>? architectureOutputs,
    bool? scopeReducedByGenome,
  }) {
    return MvpScopeDefinition(
      coreFeatures: coreFeatures ?? this.coreFeatures,
      excludedFeatures: excludedFeatures ?? this.excludedFeatures,
      expectedWeeks: expectedWeeks ?? this.expectedWeeks,
      architectureOutputs: architectureOutputs ?? this.architectureOutputs,
      scopeReducedByGenome: scopeReducedByGenome ?? this.scopeReducedByGenome,
    );
  }
}

class TeamStructure {
  const TeamStructure({
    required this.founderRole,
    required this.requiredRoles,
    required this.assignedRoles,
  });

  final String founderRole;
  final List<String> requiredRoles;
  final List<String> assignedRoles;
}

class CapitalRequirementModel {
  const CapitalRequirementModel({
    required this.buildBudget,
    required this.monthlyBurn,
    required this.runwayMonths,
    required this.fundingRequired,
  });

  final double buildBudget;
  final double monthlyBurn;
  final int runwayMonths;
  final double fundingRequired;
}

class EquityUnlockRule {
  const EquityUnlockRule({
    required this.key,
    required this.trigger,
    required this.percent,
    required this.requiredState,
    required this.unlocked,
    required this.failureReason,
  });

  final String key;
  final String trigger;
  final double percent;
  final VentureState requiredState;
  final bool unlocked;
  final String? failureReason;

  EquityUnlockRule copyWith({bool? unlocked, String? failureReason}) {
    return EquityUnlockRule(
      key: key,
      trigger: trigger,
      percent: percent,
      requiredState: requiredState,
      unlocked: unlocked ?? this.unlocked,
      failureReason: failureReason,
    );
  }
}

class EquityStructure {
  const EquityStructure({
    required this.founderEquity,
    required this.algoForceEquity,
    required this.vestingMonths,
    required this.cliffMonths,
    required this.elapsedMonths,
    required this.unlockedAlgoForceEquity,
    required this.unlockRules,
  });

  final double founderEquity;
  final double algoForceEquity;
  final int vestingMonths;
  final int cliffMonths;
  final int elapsedMonths;
  final double unlockedAlgoForceEquity;
  final List<EquityUnlockRule> unlockRules;

  EquityStructure copyWith({
    int? elapsedMonths,
    double? unlockedAlgoForceEquity,
    List<EquityUnlockRule>? unlockRules,
  }) {
    return EquityStructure(
      founderEquity: founderEquity,
      algoForceEquity: algoForceEquity,
      vestingMonths: vestingMonths,
      cliffMonths: cliffMonths,
      elapsedMonths: elapsedMonths ?? this.elapsedMonths,
      unlockedAlgoForceEquity:
          unlockedAlgoForceEquity ?? this.unlockedAlgoForceEquity,
      unlockRules: unlockRules ?? this.unlockRules,
    );
  }
}

class StartupGenome {
  const StartupGenome({
    required this.ventureViability,
    required this.marketSaturationIndex,
    required this.executionComplexityIndex,
    required this.fundingProbability,
    required this.expectedTimeToMvpWeeks,
    required this.riskFailureProbability,
    required this.scopeDirective,
  });

  final int ventureViability;
  final int marketSaturationIndex;
  final int executionComplexityIndex;
  final int fundingProbability;
  final int expectedTimeToMvpWeeks;
  final int riskFailureProbability;
  final String scopeDirective;
}

class RiskScoreModel {
  const RiskScoreModel({
    required this.overallRisk,
    required this.blockers,
    required this.transitionAllowed,
  });

  final int overallRisk;
  final List<String> blockers;
  final bool transitionAllowed;
}

class FinancialModel {
  const FinancialModel({
    required this.projectedMonthlyRevenue,
    required this.monthlyBurn,
    required this.breakEvenMonth,
    required this.fundingRequirement,
    required this.valuationEstimate,
  });

  final double projectedMonthlyRevenue;
  final double monthlyBurn;
  final int breakEvenMonth;
  final double fundingRequirement;
  final double valuationEstimate;

  FinancialModel copyWith({
    double? projectedMonthlyRevenue,
    double? valuationEstimate,
  }) {
    return FinancialModel(
      projectedMonthlyRevenue:
          projectedMonthlyRevenue ?? this.projectedMonthlyRevenue,
      monthlyBurn: monthlyBurn,
      breakEvenMonth: breakEvenMonth,
      fundingRequirement: fundingRequirement,
      valuationEstimate: valuationEstimate ?? this.valuationEstimate,
    );
  }
}

class NetworkEffectModel {
  const NetworkEffectModel({
    required this.investorMappingScore,
    required this.talentMatchScore,
    required this.similarityGraphScore,
    required this.recommendedInvestorProfiles,
    required this.requiredTalentSignals,
  });

  final int investorMappingScore;
  final int talentMatchScore;
  final int similarityGraphScore;
  final List<String> recommendedInvestorProfiles;
  final List<String> requiredTalentSignals;
}

class ExecutionTask {
  const ExecutionTask({
    required this.id,
    required this.title,
    required this.ownerLogic,
    required this.status,
    required this.requiredEvidence,
    required this.evidence,
  });

  final String id;
  final String title;
  final String ownerLogic;
  final ExecutionTaskStatus status;
  final List<String> requiredEvidence;
  final List<String> evidence;

  ExecutionTask copyWith({
    ExecutionTaskStatus? status,
    List<String>? evidence,
  }) {
    return ExecutionTask(
      id: id,
      title: title,
      ownerLogic: ownerLogic,
      status: status ?? this.status,
      requiredEvidence: requiredEvidence,
      evidence: evidence ?? this.evidence,
    );
  }
}

class Milestone {
  const Milestone({
    required this.id,
    required this.title,
    required this.requiredState,
    required this.status,
    required this.requiredEvidence,
  });

  final String id;
  final String title;
  final VentureState requiredState;
  final MilestoneStatus status;
  final List<String> requiredEvidence;

  Milestone copyWith({MilestoneStatus? status}) {
    return Milestone(
      id: id,
      title: title,
      requiredState: requiredState,
      status: status ?? this.status,
      requiredEvidence: requiredEvidence,
    );
  }
}

class MilestoneEngine {
  const MilestoneEngine({
    required this.milestones,
    required this.validationFailures,
  });

  final List<Milestone> milestones;
  final List<String> validationFailures;

  MilestoneEngine copyWith({
    List<Milestone>? milestones,
    List<String>? validationFailures,
  }) {
    return MilestoneEngine(
      milestones: milestones ?? this.milestones,
      validationFailures: validationFailures ?? this.validationFailures,
    );
  }
}

class MvpBuildArtifact {
  const MvpBuildArtifact({
    required this.layer,
    required this.outputs,
    required this.apiContracts,
  });

  final String layer;
  final List<String> outputs;
  final List<String> apiContracts;
}

class CapitalEvent {
  const CapitalEvent({
    required this.name,
    required this.message,
    required this.timestamp,
  });

  final String name;
  final String message;
  final DateTime timestamp;
}

class VentureObject {
  const VentureObject({
    required this.id,
    required this.name,
    required this.founderId,
    required this.ideaMetadata,
    required this.marketHypothesis,
    required this.businessModel,
    required this.mvpScope,
    required this.executionState,
    required this.teamStructure,
    required this.capitalRequirement,
    required this.equityStructure,
    required this.riskScore,
    required this.milestoneEngine,
    required this.genome,
    required this.financialModel,
    required this.networkEffect,
    required this.executionTasks,
    required this.mvpArtifacts,
    required this.events,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String founderId;
  final IdeaMetadata ideaMetadata;
  final MarketHypothesis marketHypothesis;
  final BusinessModelStructure businessModel;
  final MvpScopeDefinition mvpScope;
  final VentureState executionState;
  final TeamStructure teamStructure;
  final CapitalRequirementModel capitalRequirement;
  final EquityStructure equityStructure;
  final RiskScoreModel riskScore;
  final MilestoneEngine milestoneEngine;
  final StartupGenome genome;
  final FinancialModel financialModel;
  final NetworkEffectModel networkEffect;
  final List<ExecutionTask> executionTasks;
  final List<MvpBuildArtifact> mvpArtifacts;
  final List<CapitalEvent> events;
  final DateTime createdAt;
  final DateTime updatedAt;

  VentureObject copyWith({
    String? name,
    MvpScopeDefinition? mvpScope,
    VentureState? executionState,
    CapitalRequirementModel? capitalRequirement,
    EquityStructure? equityStructure,
    RiskScoreModel? riskScore,
    MilestoneEngine? milestoneEngine,
    StartupGenome? genome,
    FinancialModel? financialModel,
    NetworkEffectModel? networkEffect,
    List<ExecutionTask>? executionTasks,
    List<MvpBuildArtifact>? mvpArtifacts,
    List<CapitalEvent>? events,
  }) {
    return VentureObject(
      id: id,
      name: name ?? this.name,
      founderId: founderId,
      ideaMetadata: ideaMetadata,
      marketHypothesis: marketHypothesis,
      businessModel: businessModel,
      mvpScope: mvpScope ?? this.mvpScope,
      executionState: executionState ?? this.executionState,
      teamStructure: teamStructure,
      capitalRequirement: capitalRequirement ?? this.capitalRequirement,
      equityStructure: equityStructure ?? this.equityStructure,
      riskScore: riskScore ?? this.riskScore,
      milestoneEngine: milestoneEngine ?? this.milestoneEngine,
      genome: genome ?? this.genome,
      financialModel: financialModel ?? this.financialModel,
      networkEffect: networkEffect ?? this.networkEffect,
      executionTasks: executionTasks ?? this.executionTasks,
      mvpArtifacts: mvpArtifacts ?? this.mvpArtifacts,
      events: events ?? this.events,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
