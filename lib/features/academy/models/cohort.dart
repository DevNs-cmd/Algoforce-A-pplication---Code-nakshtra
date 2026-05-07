import 'student.dart';

enum CohortStatus { active, upcoming, completed }

class Cohort {
  const Cohort({
    required this.id,
    required this.name,
    required this.studentsEnrolled,
    required this.capacity,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.feeRange,
    required this.grossMarginPercent,
    required this.students,
  });

  final String id;
  final String name;
  final int studentsEnrolled;
  final int capacity;
  final DateTime startDate;
  final DateTime endDate;
  final CohortStatus status;
  final String feeRange;
  final int grossMarginPercent;
  final List<Student> students;

  double get fillRate => capacity == 0 ? 0 : studentsEnrolled / capacity;
}
