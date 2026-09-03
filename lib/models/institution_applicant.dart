class InstitutionApplicant {
  final String id;
  final String name;
  final String shareStatus;
  final int trustScore;
  final double averageMonthlyIncome;
  final double recurringObligations;
  final double repaymentCapacity;
  final String incomeConsistency;
  final String paymentConsistency;
  final List<String> sharedCredentials;
  final String? decision;
  final String? decisionReason;

  const InstitutionApplicant({
    required this.id,
    required this.name,
    required this.shareStatus,
    required this.trustScore,
    required this.averageMonthlyIncome,
    required this.recurringObligations,
    required this.repaymentCapacity,
    required this.incomeConsistency,
    required this.paymentConsistency,
    required this.sharedCredentials,
    this.decision,
    this.decisionReason,
  });

  InstitutionApplicant copyWith({
    String? shareStatus,
    String? decision,
    String? decisionReason,
  }) {
    return InstitutionApplicant(
      id: id,
      name: name,
      shareStatus: shareStatus ?? this.shareStatus,
      trustScore: trustScore,
      averageMonthlyIncome: averageMonthlyIncome,
      recurringObligations: recurringObligations,
      repaymentCapacity: repaymentCapacity,
      incomeConsistency: incomeConsistency,
      paymentConsistency: paymentConsistency,
      sharedCredentials: sharedCredentials,
      decision: decision ?? this.decision,
      decisionReason: decisionReason ?? this.decisionReason,
    );
  }
}
