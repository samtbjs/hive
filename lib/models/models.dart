/// Plain data classes for the UI mock-up. No persistence, no networking.

class IncomeSource {
  final String name;
  final String type; // e.g. "Gig platform", "Freelance", "Bank"
  final double monthlyAmount;
  final bool connected;
  final String icon; // emoji placeholder for a logo

  const IncomeSource({
    required this.name,
    required this.type,
    required this.monthlyAmount,
    required this.connected,
    required this.icon,
  });
}

class CredentialItem {
  final String title;
  final String issuedFor; // e.g. "September 2026 earnings"
  final String status; // Verified, Pending, Expired
  final String dateIssued;

  const CredentialItem({
    required this.title,
    required this.issuedFor,
    required this.status,
    required this.dateIssued,
  });
}

class InstitutionAccess {
  final String name;
  final String category; // Bank, NBFC, Insurer, Employer, Govt Programme
  bool hasAccess;
  final String scope; // what data is shared

  InstitutionAccess({
    required this.name,
    required this.category,
    required this.hasAccess,
    required this.scope,
  });
}

class DecisionReason {
  final String label;
  final bool isPositive;
  final String detail;

  const DecisionReason({
    required this.label,
    required this.isPositive,
    required this.detail,
  });
}

class ApplicantSummary {
  final String name;
  final String id;
  final int reliabilityScore; // 0-100
  final String status; // Approved, Rejected, Review
  final double monthlyIncome;

  const ApplicantSummary({
    required this.name,
    required this.id,
    required this.reliabilityScore,
    required this.status,
    required this.monthlyIncome,
  });
}
