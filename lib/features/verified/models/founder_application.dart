class FounderApplication {
  const FounderApplication({
    required this.id,
    required this.founderName,
    required this.startupName,
    required this.submittedDate,
    required this.currentLayer,
    required this.layerStatuses,
    required this.totalFeesPaid,
  });

  final String id;
  final String founderName;
  final String startupName;
  final DateTime submittedDate;
  final int currentLayer;
  final List<String> layerStatuses;
  final int totalFeesPaid;
}
