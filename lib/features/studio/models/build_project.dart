enum DealType { cash, equity, hybrid }

enum BuildStatus { discovery, sprint, qa, live, retainer }

class BuildProject {
  const BuildProject({
    required this.id,
    required this.founderName,
    required this.startupName,
    required this.description,
    required this.dealType,
    required this.cashAmount,
    required this.equityPercent,
    required this.status,
    required this.startDate,
    required this.techStack,
    required this.builderCount,
    required this.weeklyProgress,
    required this.retainerMonthly,
  });

  final String id;
  final String founderName;
  final String startupName;
  final String description;
  final DealType dealType;
  final int cashAmount;
  final double equityPercent;
  final BuildStatus status;
  final DateTime startDate;
  final List<String> techStack;
  final int builderCount;
  final int weeklyProgress;
  final int retainerMonthly;

  DateTime get expectedLaunchDate => startDate.add(const Duration(days: 70));

  BuildProject copyWith({BuildStatus? status, int? weeklyProgress}) {
    return BuildProject(
      id: id,
      founderName: founderName,
      startupName: startupName,
      description: description,
      dealType: dealType,
      cashAmount: cashAmount,
      equityPercent: equityPercent,
      status: status ?? this.status,
      startDate: startDate,
      techStack: techStack,
      builderCount: builderCount,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      retainerMonthly: retainerMonthly,
    );
  }
}
