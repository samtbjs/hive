enum DecisionReasonCategory {
  incomeInstability,
  highObligations,
  insufficientHistory,
  missingVerification,
}

extension DecisionReasonCategoryInfo on DecisionReasonCategory {
  String get label {
    switch (this) {
      case DecisionReasonCategory.incomeInstability: return 'Income instability';
      case DecisionReasonCategory.highObligations: return 'High obligations';
      case DecisionReasonCategory.insufficientHistory: return 'Insufficient history';
      case DecisionReasonCategory.missingVerification: return 'Missing verification';
    }
  }
}

class DecisionReason {
  final DecisionReasonCategory category;
  final String explanation;
  final String nextStep;

  const DecisionReason({required this.category, required this.explanation, required this.nextStep});
}

class InstitutionDecision {
  final String id;
  final String institutionName;
  final String applicantId;
  final String decision; // approved | rejected | conditional
  final int reliabilityScore;
  final List<String> positiveReasons;
  final List<String> negativeReasons;
  final DateTime decidedOn;
  final List<DecisionReason> reasons;
  final String? offerSummary;

  const InstitutionDecision({
    required this.id,
    required this.institutionName,
    required this.applicantId,
    required this.decision,
    required this.reliabilityScore,
    required this.positiveReasons,
    required this.negativeReasons,
    required this.decidedOn,
    this.reasons = const [],
    this.offerSummary,
  });

  factory InstitutionDecision.fromJson(Map<String, dynamic> json) {
    final negative = (json['negativeReasons'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    return InstitutionDecision(
      id: (json['id'] ?? '').toString(),
      institutionName: (json['institutionName'] ?? 'Institution').toString(),
      applicantId: (json['applicantId'] ?? '').toString(),
      decision: (json['decision'] ?? 'conditional').toString().toLowerCase(),
      reliabilityScore: (json['reliabilityScore'] as num?)?.toInt() ?? 0,
      positiveReasons: (json['positiveReasons'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      negativeReasons: negative,
      decidedOn: DateTime.tryParse((json['decidedOn'] ?? '').toString()) ?? DateTime.now(),
      reasons: negative.map((text) => DecisionReason(
        category: _categoryFromText(text),
        explanation: text,
        nextStep: _defaultNextStep(_categoryFromText(text)),
      )).toList(),
      offerSummary: json['offerSummary']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'institutionName': institutionName,
        'applicantId': applicantId,
        'decision': decision,
        'reliabilityScore': reliabilityScore,
        'positiveReasons': positiveReasons,
        'negativeReasons': negativeReasons,
        'decidedOn': decidedOn.toIso8601String(),
      };

  static DecisionReasonCategory _categoryFromText(String text) {
    final value = text.toLowerCase();
    if (value.contains('obligation') || value.contains('commitment')) return DecisionReasonCategory.highObligations;
    if (value.contains('history') || value.contains('month')) return DecisionReasonCategory.insufficientHistory;
    if (value.contains('verify') || value.contains('verification')) return DecisionReasonCategory.missingVerification;
    return DecisionReasonCategory.incomeInstability;
  }

  static String _defaultNextStep(DecisionReasonCategory category) {
    switch (category) {
      case DecisionReasonCategory.incomeInstability: return 'Keep more income sources connected for the next 8–12 weeks.';
      case DecisionReasonCategory.highObligations: return 'Reduce recurring commitments or clear one existing EMI before reapplying.';
      case DecisionReasonCategory.insufficientHistory: return 'Build at least 3 months of verified transaction history.';
      case DecisionReasonCategory.missingVerification: return 'Verify the missing income or payment source and refresh your profile.';
    }
  }
}
