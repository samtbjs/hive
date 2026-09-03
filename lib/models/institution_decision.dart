/// The outcome (and explainability reasons) of an institution's decision
/// on an applicant, surfaced back to the earner on the "Why" tab.
class InstitutionDecision {
  final String id;
  final String institutionName;
  final String applicantId;
  final String decision; // 'approved' | 'rejected' | 'review'
  final int reliabilityScore;
  final List<String> positiveReasons;
  final List<String> negativeReasons;
  final DateTime decidedOn;

  const InstitutionDecision({
    required this.id,
    required this.institutionName,
    required this.applicantId,
    required this.decision,
    required this.reliabilityScore,
    required this.positiveReasons,
    required this.negativeReasons,
    required this.decidedOn,
  });

  factory InstitutionDecision.fromJson(Map<String, dynamic> json) {
    return InstitutionDecision(
      id: json['id'] as String,
      institutionName: json['institutionName'] as String,
      applicantId: json['applicantId'] as String,
      decision: json['decision'] as String,
      reliabilityScore: json['reliabilityScore'] as int,
      positiveReasons: (json['positiveReasons'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      negativeReasons: (json['negativeReasons'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      decidedOn: DateTime.parse(json['decidedOn'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institutionName': institutionName,
      'applicantId': applicantId,
      'decision': decision,
      'reliabilityScore': reliabilityScore,
      'positiveReasons': positiveReasons,
      'negativeReasons': negativeReasons,
      'decidedOn': decidedOn.toIso8601String(),
    };
  }
}
