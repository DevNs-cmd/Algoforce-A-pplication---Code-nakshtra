enum CityTier { tier2, tier3 }

enum FeeType { paid, isa }

class Student {
  const Student({
    required this.id,
    required this.name,
    required this.college,
    required this.city,
    required this.tier,
    required this.feeType,
    required this.feeAmount,
    required this.weekProgress,
    required this.studioDeployed,
    required this.certified,
    required this.placed,
  });

  final String id;
  final String name;
  final String college;
  final String city;
  final CityTier tier;
  final FeeType feeType;
  final int feeAmount;
  final int weekProgress;
  final bool studioDeployed;
  final bool certified;
  final bool placed;

  Student copyWith({
    int? weekProgress,
    bool? studioDeployed,
    bool? certified,
    bool? placed,
  }) {
    return Student(
      id: id,
      name: name,
      college: college,
      city: city,
      tier: tier,
      feeType: feeType,
      feeAmount: feeAmount,
      weekProgress: weekProgress ?? this.weekProgress,
      studioDeployed: studioDeployed ?? this.studioDeployed,
      certified: certified ?? this.certified,
      placed: placed ?? this.placed,
    );
  }
}
