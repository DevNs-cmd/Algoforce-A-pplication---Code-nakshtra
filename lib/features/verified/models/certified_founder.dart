enum BadgeStatus { active, expired, revoked }

class CertifiedFounder {
  const CertifiedFounder({
    required this.id,
    required this.founderName,
    required this.startupName,
    required this.sector,
    required this.certDate,
    required this.indexScore,
    required this.badgeStatus,
    required this.annualRenewalDue,
    required this.investorIntroCount,
    required this.roundRaisedAmount,
  });

  final String id;
  final String founderName;
  final String startupName;
  final String sector;
  final DateTime certDate;
  final int indexScore;
  final BadgeStatus badgeStatus;
  final DateTime annualRenewalDue;
  final int investorIntroCount;
  final int roundRaisedAmount;
}
