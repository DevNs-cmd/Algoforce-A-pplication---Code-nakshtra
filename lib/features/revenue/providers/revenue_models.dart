import 'package:flutter/material.dart';

enum ProjectionScenario { conservative, base, optimistic }

class RevenueStream {
  const RevenueStream({
    required this.name,
    required this.scale,
    required this.when,
    required this.perUnit,
    required this.marginPercent,
    required this.color,
    required this.active,
    this.critical = false,
  });

  final String name;
  final String scale;
  final String when;
  final String perUnit;
  final int marginPercent;
  final Color color;
  final bool active;
  final bool critical;

  RevenueStream copyWith({bool? active}) {
    return RevenueStream(
      name: name,
      scale: scale,
      when: when,
      perUnit: perUnit,
      marginPercent: marginPercent,
      color: color,
      active: active ?? this.active,
      critical: critical,
    );
  }
}

class RevenueProjectionInputs {
  const RevenueProjectionInputs({
    this.academyCohortsPerYear = 4,
    this.studentsPerCohort = 50,
    this.averageCohortFee = 25000,
    this.studioBuildsPerMonth = 4,
    this.averageBuildValue = 500000,
    this.verifiedCertsPerMonth = 20,
    this.certFee = 30000,
  });

  final double academyCohortsPerYear;
  final double studentsPerCohort;
  final double averageCohortFee;
  final double studioBuildsPerMonth;
  final double averageBuildValue;
  final double verifiedCertsPerMonth;
  final double certFee;

  double get year1Revenue {
    final academy =
        academyCohortsPerYear * studentsPerCohort * averageCohortFee;
    final studio = studioBuildsPerMonth * 12 * averageBuildValue;
    final verified = verifiedCertsPerMonth * 12 * certFee;
    return academy + studio + verified;
  }

  double get year2Revenue => year1Revenue * 1.8;
  double get year3Revenue => year2Revenue * 2.0;
  double get monthlyRunRate => year1Revenue / 12;

  RevenueProjectionInputs copyWith({
    double? academyCohortsPerYear,
    double? studentsPerCohort,
    double? averageCohortFee,
    double? studioBuildsPerMonth,
    double? averageBuildValue,
    double? verifiedCertsPerMonth,
    double? certFee,
  }) {
    return RevenueProjectionInputs(
      academyCohortsPerYear:
          academyCohortsPerYear ?? this.academyCohortsPerYear,
      studentsPerCohort: studentsPerCohort ?? this.studentsPerCohort,
      averageCohortFee: averageCohortFee ?? this.averageCohortFee,
      studioBuildsPerMonth: studioBuildsPerMonth ?? this.studioBuildsPerMonth,
      averageBuildValue: averageBuildValue ?? this.averageBuildValue,
      verifiedCertsPerMonth:
          verifiedCertsPerMonth ?? this.verifiedCertsPerMonth,
      certFee: certFee ?? this.certFee,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'academyCohortsPerYear': academyCohortsPerYear,
      'studentsPerCohort': studentsPerCohort,
      'averageCohortFee': averageCohortFee,
      'studioBuildsPerMonth': studioBuildsPerMonth,
      'averageBuildValue': averageBuildValue,
      'verifiedCertsPerMonth': verifiedCertsPerMonth,
      'certFee': certFee,
    };
  }

  factory RevenueProjectionInputs.fromJson(Map<String, dynamic> json) {
    double read(String key, double fallback) =>
        (json[key] as num?)?.toDouble() ?? fallback;
    return RevenueProjectionInputs(
      academyCohortsPerYear: read('academyCohortsPerYear', 4),
      studentsPerCohort: read('studentsPerCohort', 50),
      averageCohortFee: read('averageCohortFee', 25000),
      studioBuildsPerMonth: read('studioBuildsPerMonth', 4),
      averageBuildValue: read('averageBuildValue', 500000),
      verifiedCertsPerMonth: read('verifiedCertsPerMonth', 20),
      certFee: read('certFee', 30000),
    );
  }
}
