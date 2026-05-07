import 'build_project.dart';

class Deal {
  const Deal({
    required this.id,
    required this.type,
    required this.cashAmount,
    required this.equityPercent,
    required this.founderName,
    required this.signedDate,
    required this.status,
  });

  final String id;
  final DealType type;
  final int cashAmount;
  final double equityPercent;
  final String founderName;
  final DateTime signedDate;
  final String status;
}
