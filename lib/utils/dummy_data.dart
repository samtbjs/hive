import '../models/models.dart';

/// All fake data lives here so screens stay clean. Swap this out for real
/// API calls later without touching the widgets.
class DummyData {
  static const userName = 'Arjun Kumar';
  static const reliabilityScore = 78;
  static const totalMonthlyIncome = 42350.0;
  static const totalObligations = 16800.0;

  // Last 6 months, for the income trend chart
  static const List<double> incomeTrend = [28000, 31500, 35000, 33200, 39800, 42350];
  static const List<String> incomeTrendLabels = ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'];

  static const incomeSources = <IncomeSource>[
    IncomeSource(name: 'Swiggy', type: 'Gig platform', monthlyAmount: 14200, connected: true, icon: '🛵'),
    IncomeSource(name: 'Zomato', type: 'Gig platform', monthlyAmount: 9800, connected: true, icon: '🍔'),
    IncomeSource(name: 'Uber', type: 'Gig platform', monthlyAmount: 11500, connected: true, icon: '🚗'),
    IncomeSource(name: 'Freelance (Upwork)', type: 'Freelance', monthlyAmount: 6850, connected: true, icon: '💻'),
    IncomeSource(name: 'HDFC Savings A/C', type: 'Bank account', monthlyAmount: 0, connected: true, icon: '🏦'),
    IncomeSource(name: 'Fiverr', type: 'Freelance', monthlyAmount: 0, connected: false, icon: '🎨'),
  ];

  static const credentials = <CredentialItem>[
    CredentialItem(title: 'Proof of Earnings — Aug 2026', issuedFor: 'Aggregated income, 4 sources', status: 'Verified', dateIssued: '01 Sep 2026'),
    CredentialItem(title: 'Rent Payment History', issuedFor: 'Last 12 months', status: 'Verified', dateIssued: '28 Aug 2026'),
    CredentialItem(title: 'Repayment Capacity Estimate', issuedFor: 'Q3 2026', status: 'Verified', dateIssued: '15 Aug 2026'),
    CredentialItem(title: 'Proof of Earnings — Sep 2026', issuedFor: 'Aggregated income, 4 sources', status: 'Pending', dateIssued: '—'),
  ];

  static List<InstitutionAccess> institutionAccess = [
    InstitutionAccess(name: 'HDFC Bank', category: 'Bank', hasAccess: true, scope: 'Income summary, reliability score'),
    InstitutionAccess(name: 'Bajaj Finserv', category: 'NBFC', hasAccess: true, scope: 'Full financial dashboard'),
    InstitutionAccess(name: 'ICICI Lombard', category: 'Insurer', hasAccess: false, scope: 'Income summary only'),
    InstitutionAccess(name: 'PM SVANidhi Scheme', category: 'Govt Programme', hasAccess: true, scope: 'Eligibility fields only'),
  ];

  static const decisionReasonsPositive = <DecisionReason>[
    DecisionReason(label: 'Stable income', isPositive: true, detail: 'Income variance under 12% over 6 months'),
    DecisionReason(label: 'Verified sources', isPositive: true, detail: '4 of 4 income sources cryptographically verified'),
    DecisionReason(label: 'On-time obligations', isPositive: true, detail: 'Rent & utility payments on time for 11/12 months'),
  ];

  static const decisionReasonsNegative = <DecisionReason>[
    DecisionReason(label: 'High obligations', isPositive: false, detail: 'Existing commitments use 40% of monthly income'),
    DecisionReason(label: 'Insufficient history', isPositive: false, detail: 'Only 6 months of verifiable earnings on file'),
  ];

  static const applicants = <ApplicantSummary>[
    ApplicantSummary(name: 'Arjun Kumar', id: 'VF-10293', reliabilityScore: 78, status: 'Approved', monthlyIncome: 42350),
    ApplicantSummary(name: 'Priya Sharma', id: 'VF-10318', reliabilityScore: 54, status: 'Review', monthlyIncome: 21500),
    ApplicantSummary(name: 'Ramesh Iyer', id: 'VF-10402', reliabilityScore: 39, status: 'Rejected', monthlyIncome: 15800),
    ApplicantSummary(name: 'Fatima Sheikh', id: 'VF-10455', reliabilityScore: 88, status: 'Approved', monthlyIncome: 51200),
  ];
}
