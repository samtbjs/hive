import 'package:flutter/foundation.dart';
import '../models/models.dart';

class InstitutionProvider extends ChangeNotifier {
  final List<InstitutionApplicant> _applicants = [
    const InstitutionApplicant(
      id: 'VF-10293', name: 'Arjun Kumar', shareStatus: 'Active share', trustScore: 824,
      averageMonthlyIncome: 38608, recurringObligations: 16800, repaymentCapacity: 21808,
      incomeConsistency: '84%', paymentConsistency: '92%',
      sharedCredentials: ['Monthly Earnings Proof · Aug 2026', 'Rent Payment History · 12 months', 'Repayment Capacity Snapshot · Q3 2026'],
    ),
    const InstitutionApplicant(
      id: 'VF-10841', name: 'Meena S', shareStatus: 'Active share', trustScore: 778,
      averageMonthlyIncome: 33200, recurringObligations: 12100, repaymentCapacity: 21100,
      incomeConsistency: '79%', paymentConsistency: '96%',
      sharedCredentials: ['Monthly Earnings Proof · Aug 2026', 'Utility Payment History · 9 months'],
    ),
    const InstitutionApplicant(
      id: 'VF-11107', name: 'Ravi Teja', shareStatus: 'Pending consent', trustScore: 641,
      averageMonthlyIncome: 28750, recurringObligations: 15400, repaymentCapacity: 13350,
      incomeConsistency: '68%', paymentConsistency: '75%',
      sharedCredentials: ['Monthly Earnings Proof · Jul 2026'],
    ),
    const InstitutionApplicant(
      id: 'VF-11352', name: 'Nisha Khan', shareStatus: 'Active share', trustScore: 851,
      averageMonthlyIncome: 46700, recurringObligations: 14200, repaymentCapacity: 32500,
      incomeConsistency: '91%', paymentConsistency: '100%',
      sharedCredentials: ['Monthly Earnings Proof · Aug 2026', 'Rent Payment History · 18 months', 'Bank Inflow Verification · 6 months'],
    ),
  ];

  List<InstitutionApplicant> get applicants => List.unmodifiable(_applicants);

  InstitutionApplicant? byId(String id) {
    for (final applicant in _applicants) {
      if (applicant.id == id) return applicant;
    }
    return null;
  }

  void decide(String id, String decision, DecisionReasonCategory reason) {
    final index = _applicants.indexWhere((item) => item.id == id);
    if (index < 0) return;
    _applicants[index] = _applicants[index].copyWith(
      decision: decision,
      decisionReason: reason.label,
    );
    notifyListeners();
  }
}
