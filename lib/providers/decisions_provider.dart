import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class DecisionsProvider extends ChangeNotifier {
  DecisionsProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService() {
    _seedMock();
  }

  final ApiService _apiService;
  final List<InstitutionDecision> _decisions = [];
  bool isLoading = false;
  bool isUsingDemoData = true;

  List<InstitutionDecision> get decisions => List.unmodifiable(_decisions);

  Future<void> loadDecisions() async {
    isLoading = true;
    notifyListeners();
    try {
      final live = await _apiService.fetchInstitutionDecisions();
      if (live.isNotEmpty) {
        _decisions
          ..clear()
          ..addAll(live);
        isUsingDemoData = false;
      }
    } catch (_) {
      // Keep mock history.
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _seedMock() {
    _decisions
      ..clear()
      ..addAll([
        InstitutionDecision(
          id: 'dec_1', institutionName: 'HDFC Bank', applicantId: 'VF-10293',
          decision: 'conditional', reliabilityScore: 824, decidedOn: DateTime(2026, 9, 3),
          positiveReasons: const ['Strong payment consistency', 'Five verified income sources'],
          negativeReasons: const ['Only 2 months of complete bank-linked history'],
          offerSummary: 'Conditionally eligible up to ₹75,000 after one more month of verified history.',
          reasons: const [
            DecisionReason(
              category: DecisionReasonCategory.insufficientHistory,
              explanation: 'Only 2 months of your profile currently has complete linked-source history.',
              nextStep: 'Keep the same income sources connected for 1 more month to reach 3 months of history.',
            ),
          ],
        ),
        InstitutionDecision(
          id: 'dec_2', institutionName: 'Bajaj Finserv', applicantId: 'VF-10293',
          decision: 'approved', reliabilityScore: 812, decidedOn: DateTime(2026, 8, 30),
          positiveReasons: const ['11 of 12 recurring payments were on time', 'Income consistency above 80%'],
          negativeReasons: const [],
          offerSummary: 'Approved for a small-ticket working-capital offer.',
          reasons: const [],
        ),
        InstitutionDecision(
          id: 'dec_3', institutionName: 'QuickCredit NBFC', applicantId: 'VF-10293',
          decision: 'rejected', reliabilityScore: 672, decidedOn: DateTime(2026, 6, 18),
          positiveReasons: const ['Rent payments verified'],
          negativeReasons: const ['Income instability', 'High obligations'],
          reasons: const [
            DecisionReason(
              category: DecisionReasonCategory.incomeInstability,
              explanation: 'Weekly income changed by more than 35% across the assessed period.',
              nextStep: 'Link 2 more regular income sources and maintain them for the next 8–12 weeks.',
            ),
            DecisionReason(
              category: DecisionReasonCategory.highObligations,
              explanation: 'Recurring commitments were above 50% of the average verified monthly income.',
              nextStep: 'Clear or reduce one recurring EMI before applying again.',
            ),
          ],
        ),
      ]);
  }
}
