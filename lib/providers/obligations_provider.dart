import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

/// Dashboard state for recurring obligations and outstanding receivables.
///
/// The provider keeps realistic demo data available immediately. When the
/// backend endpoints return usable data, those values replace the fallback.
class ObligationsProvider extends ChangeNotifier {
  ObligationsProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    _seedDemoData();
  }

  final ApiService _apiService;

  final List<Obligation> _obligations = [];
  final List<Receivable> _receivables = [];

  bool isLoading = false;
  bool isUsingDemoData = true;
  String? errorMessage;

  // Demo payment history used until a real payment-history endpoint exists.
  int _trackedPayments = 12;
  int _onTimePayments = 11;

  List<Obligation> get obligations => List.unmodifiable(_obligations);
  List<Receivable> get receivables => List.unmodifiable(_receivables);

  double get monthlyRecurringObligations => _obligations
      .where((obligation) => obligation.recurring)
      .fold(0.0, (sum, obligation) => sum + obligation.amount);

  double get outstandingReceivables => _receivables
      .where((receivable) => receivable.status.toLowerCase() != 'paid')
      .fold(0.0, (sum, receivable) => sum + receivable.amount);

  double get onTimePaymentRate =>
      _trackedPayments == 0 ? 0.0 : _onTimePayments / _trackedPayments;

  int get overdueCount =>
      _obligations.where((item) => item.status.toLowerCase() == 'overdue').length +
      _receivables.where((item) => item.status.toLowerCase() == 'overdue').length;

  Future<void> loadObligations() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final liveObligations = await _apiService.fetchObligations();
      final liveReceivables = await _apiService.fetchReceivables();

      var replacedAny = false;
      if (liveObligations.isNotEmpty) {
        _obligations
          ..clear()
          ..addAll(liveObligations);
        replacedAny = true;
      }
      if (liveReceivables.isNotEmpty) {
        _receivables
          ..clear()
          ..addAll(liveReceivables);
        replacedAny = true;
      }

      if (replacedAny) isUsingDemoData = false;
    } catch (_) {
      // Keep the seeded fallback data while the endpoints are unavailable.
      errorMessage = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadObligations();

  void _seedDemoData() {
    final now = DateTime.now();
    DateTime thisMonth(int day) => DateTime(now.year, now.month, day);
    DateTime nextMonth(int day) => DateTime(now.year, now.month + 1, day);

    _obligations
      ..clear()
      ..addAll([
        Obligation(
          id: 'ob_rent',
          name: 'House rent',
          type: 'rent',
          amount: 9500,
          dueDate: thisMonth(5),
          status: 'paid',
          recurring: true,
        ),
        Obligation(
          id: 'ob_emi',
          name: 'Two-wheeler EMI',
          type: 'emi',
          amount: 4300,
          dueDate: thisMonth(10),
          status: 'pending',
          recurring: true,
        ),
        Obligation(
          id: 'ob_util',
          name: 'Electricity & phone',
          type: 'utility',
          amount: 3000,
          dueDate: thisMonth(8),
          status: 'pending',
          recurring: true,
        ),
      ]);

    _receivables
      ..clear()
      ..addAll([
        Receivable(
          id: 'rec_upwork',
          name: 'App UI milestone',
          source: 'Upwork',
          amount: 6800,
          dueDate: thisMonth(7),
          status: 'pending',
        ),
        Receivable(
          id: 'rec_client',
          name: 'Local merchant website',
          source: 'Direct client',
          amount: 4200,
          dueDate: thisMonth(2),
          status: 'overdue',
        ),
        Receivable(
          id: 'rec_design',
          name: 'Brand design balance',
          source: 'Fiverr',
          amount: 2750,
          dueDate: nextMonth(3),
          status: 'pending',
        ),
      ]);
  }
}
