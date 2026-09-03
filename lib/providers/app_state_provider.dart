import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

/// App-root state provider. Holds the data the Dashboard (and, later,
/// other feature screens) render. Wired via MultiProvider in main.dart so
/// additional feature-specific providers can be added alongside it without
/// touching this class.
///
/// For the hackathon build there is no live backend yet, so [loadAll] seeds
/// itself with representative demo data if the API call fails or returns
/// nothing — this keeps the restyled Dashboard fully functional out of the
/// box. Swap `_seedDemoData()` out once real endpoints are live.
class AppStateProvider extends ChangeNotifier {
  AppStateProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    _seedDemoData();
  }

  final ApiService _apiService;

  bool isLoading = false;
  String? errorMessage;

  String userName = 'Arjun Kumar';
  int reliabilityScore = 78;

  List<IncomeSource> incomeSources = [];
  List<Transaction> transactions = [];
  List<Obligation> obligations = [];
  List<Credential> credentials = [];
  List<ConsentGrant> consentGrants = [];
  List<InstitutionDecision> institutionDecisions = [];

  List<double> incomeTrend = const [];
  List<String> incomeTrendLabels = const [];

  double get totalMonthlyIncome =>
      incomeSources.fold(0.0, (sum, s) => sum + s.monthlyAmount);

  double get totalObligations =>
      obligations.fold(0.0, (sum, o) => sum + o.amount);

  /// Attempts to refresh state from the real API; falls back silently to
  /// the already-seeded demo data since there is no backend yet.
  Future<void> loadAll() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final sources = await _apiService.fetchIncomeSources();
      final obligationList = await _apiService.fetchObligations();
      final credentialList = await _apiService.fetchCredentials();

      if (sources.isNotEmpty) incomeSources = sources;
      if (obligationList.isNotEmpty) obligations = obligationList;
      if (credentialList.isNotEmpty) credentials = credentialList;
    } catch (_) {
      // No backend yet — keep demo data, surface nothing scary to the user.
      errorMessage = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _seedDemoData() {
    incomeSources = const [
      IncomeSource(id: 'src_swiggy', name: 'Swiggy', platformType: 'Gig platform', monthlyAmount: 14200, connected: true, verified: true, icon: '🛵'),
      IncomeSource(id: 'src_zomato', name: 'Zomato', platformType: 'Gig platform', monthlyAmount: 9800, connected: true, verified: true, icon: '🍔'),
      IncomeSource(id: 'src_uber', name: 'Uber', platformType: 'Gig platform', monthlyAmount: 11500, connected: true, verified: true, icon: '🚗'),
      IncomeSource(id: 'src_upwork', name: 'Freelance (Upwork)', platformType: 'Freelance', monthlyAmount: 6850, connected: true, verified: true, icon: '💻'),
      IncomeSource(id: 'src_hdfc', name: 'HDFC Savings A/C', platformType: 'Bank account', monthlyAmount: 0, connected: true, verified: true, icon: '🏦'),
      IncomeSource(id: 'src_fiverr', name: 'Fiverr', platformType: 'Freelance', monthlyAmount: 0, connected: false, verified: false, icon: '🎨'),
    ];

    obligations = [
      Obligation(id: 'ob_rent', name: 'Rent', type: 'rent', amount: 9500, dueDate: DateTime(2026, 9, 5), status: 'paid', recurring: true),
      Obligation(id: 'ob_emi', name: 'Two-wheeler EMI', type: 'emi', amount: 4300, dueDate: DateTime(2026, 9, 10), status: 'pending', recurring: true),
      Obligation(id: 'ob_util', name: 'Electricity & phone', type: 'utility', amount: 3000, dueDate: DateTime(2026, 9, 8), status: 'pending', recurring: true),
    ];

    credentials = [
      Credential(id: 'cr_1', title: 'Proof of Earnings — Aug 2026', issuedFor: 'Aggregated income, 4 sources', status: 'verified', dateIssued: DateTime(2026, 9, 1)),
      Credential(id: 'cr_2', title: 'Rent Payment History', issuedFor: 'Last 12 months', status: 'verified', dateIssued: DateTime(2026, 8, 28)),
      Credential(id: 'cr_3', title: 'Repayment Capacity Estimate', issuedFor: 'Q3 2026', status: 'verified', dateIssued: DateTime(2026, 8, 15)),
      const Credential(id: 'cr_4', title: 'Proof of Earnings — Sep 2026', issuedFor: 'Aggregated income, 4 sources', status: 'pending', dateIssued: null),
    ];

    consentGrants = [
      ConsentGrant(id: 'cg_1', institutionName: 'HDFC Bank', category: 'Bank', scope: const ['Income summary', 'Reliability score'], active: true, grantedOn: DateTime(2026, 7, 12)),
      ConsentGrant(id: 'cg_2', institutionName: 'Bajaj Finserv', category: 'NBFC', scope: const ['Full financial dashboard'], active: true, grantedOn: DateTime(2026, 6, 20)),
    ];

    institutionDecisions = [
      InstitutionDecision(
        id: 'dec_1',
        institutionName: 'Bajaj Finserv',
        applicantId: 'VF-10293',
        decision: 'approved',
        reliabilityScore: reliabilityScore,
        positiveReasons: const [
          'Income variance under 12% over 6 months',
          '4 of 4 income sources cryptographically verified',
          'Rent & utility payments on time for 11/12 months',
        ],
        negativeReasons: const [
          'Existing commitments use 40% of monthly income',
        ],
        decidedOn: DateTime(2026, 8, 30),
      ),
    ];

    incomeTrend = const [28000, 31500, 35000, 33200, 39800, 42350];
    incomeTrendLabels = const ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'];
  }
}
