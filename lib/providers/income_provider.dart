import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

enum IncomePeriod { week, month, custom }

class IncomeChartBucket {
  const IncomeChartBucket({
    required this.label,
    required this.valuesBySource,
  });

  final String label;
  final Map<String, double> valuesBySource;

  double get total =>
      valuesBySource.values.fold(0.0, (sum, value) => sum + value);
}

/// Dashboard-specific state for multi-source income aggregation.
///
/// The provider starts with realistic demo transactions so the Dashboard is
/// immediately usable. API responses replace that demo data as soon as the
/// income endpoint returns transactions. Polling is controlled by AppShell so
/// it only runs while the Dashboard tab is visible.
class IncomeProvider extends ChangeNotifier {
  IncomeProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    _seedDemoTransactions();
  }

  final ApiService _apiService;

  final List<Transaction> _transactions = [];
  Timer? _pollTimer;
  bool _dashboardVisible = false;
  bool _refreshInProgress = false;

  bool isLoading = false;
  bool isUsingDemoData = true;
  DateTime? lastUpdated;
  String? errorMessage;

  IncomePeriod selectedPeriod = IncomePeriod.month;
  DateTime? customStart;
  DateTime? customEnd;

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  DateTime get periodStart {
    final now = DateTime.now();
    switch (selectedPeriod) {
      case IncomePeriod.week:
        final today = DateTime(now.year, now.month, now.day);
        return today.subtract(Duration(days: today.weekday - 1));
      case IncomePeriod.month:
        return DateTime(now.year, now.month, 1);
      case IncomePeriod.custom:
        return _dateOnly(customStart ?? DateTime(now.year, now.month, 1));
    }
  }

  DateTime get periodEnd {
    final now = DateTime.now();
    switch (selectedPeriod) {
      case IncomePeriod.week:
        return periodStart.add(const Duration(days: 6));
      case IncomePeriod.month:
        return DateTime(now.year, now.month + 1, 0);
      case IncomePeriod.custom:
        return _dateOnly(customEnd ?? now);
    }
  }

  List<Transaction> get filteredTransactions {
    final start = periodStart;
    final endExclusive = periodEnd.add(const Duration(days: 1));
    final result = _transactions.where((transaction) {
      return transaction.isIncome &&
          !transaction.date.isBefore(start) &&
          transaction.date.isBefore(endExclusive);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  double get totalIncome => filteredTransactions
      .where((transaction) => transaction.isIncome)
      .fold(0.0, (sum, transaction) => sum + transaction.amount);

  Map<String, double> get sourceTotals {
    final totals = <String, double>{};
    for (final transaction in filteredTransactions) {
      if (!transaction.isIncome) continue;
      totals.update(
        transaction.source,
        (current) => current + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    return totals;
  }

  List<String> get sourcesInPeriod {
    final entries = sourceTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((entry) => entry.key).toList();
  }

  List<IncomeChartBucket> get chartBuckets {
    final start = periodStart;
    final end = periodEnd;
    final dayCount = end.difference(start).inDays + 1;
    final computedBucketSize = (dayCount / 6).ceil();
    final int bucketSize = dayCount <= 7
        ? 1
        : computedBucketSize < 1
            ? 1
            : computedBucketSize;
    final bucketCount = (dayCount / bucketSize).ceil();

    final buckets = List.generate(bucketCount, (index) {
      final bucketStart = start.add(Duration(days: index * bucketSize));
      final possibleEnd = bucketStart.add(Duration(days: bucketSize - 1));
      final bucketEnd = possibleEnd.isAfter(end) ? end : possibleEnd;
      return _MutableIncomeBucket(
        start: bucketStart,
        end: bucketEnd,
        valuesBySource: <String, double>{},
      );
    });

    for (final transaction in filteredTransactions) {
      if (!transaction.isIncome) continue;
      final date = _dateOnly(transaction.date);
      final index = date.difference(start).inDays ~/ bucketSize;
      if (index < 0 || index >= buckets.length) continue;
      buckets[index].valuesBySource.update(
        transaction.source,
        (current) => current + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    return buckets.map((bucket) {
      final label = bucketSize == 1
          ? _shortDayLabel(bucket.start, dayCount <= 7)
          : '${bucket.start.day}-${bucket.end.day}';
      return IncomeChartBucket(
        label: label,
        valuesBySource: Map.unmodifiable(bucket.valuesBySource),
      );
    }).toList();
  }

  String get periodLabel {
    switch (selectedPeriod) {
      case IncomePeriod.week:
        return 'This week';
      case IncomePeriod.month:
        return 'This month';
      case IncomePeriod.custom:
        return '${_formatDate(periodStart)} – ${_formatDate(periodEnd)}';
    }
  }

  void setPeriod(IncomePeriod period) {
    if (selectedPeriod == period) return;
    selectedPeriod = period;
    notifyListeners();
  }

  void setCustomRange(DateTime start, DateTime end) {
    customStart = _dateOnly(start);
    customEnd = _dateOnly(end);
    selectedPeriod = IncomePeriod.custom;
    notifyListeners();
  }

  Future<void> refreshIncome({bool silent = false}) async {
    if (_refreshInProgress) return;
    _refreshInProgress = true;

    if (!silent) {
      isLoading = true;
      notifyListeners();
    }

    try {
      final incoming = await _apiService.fetchTransactions();
      if (incoming.isNotEmpty) {
        _transactions
          ..clear()
          ..addAll(incoming);
        _transactions.sort((a, b) => b.date.compareTo(a.date));
        isUsingDemoData = false;
      }
      errorMessage = null;
      lastUpdated = DateTime.now();
    } catch (_) {
      // Keep the already-seeded demo ledger so the Dashboard remains usable
      // while the real income endpoint is offline/unavailable.
      errorMessage = null;
      lastUpdated ??= DateTime.now();
    } finally {
      _refreshInProgress = false;
      if (!silent) isLoading = false;
      notifyListeners();
    }
  }

  void setDashboardVisible(bool visible) {
    if (_dashboardVisible == visible) return;
    _dashboardVisible = visible;

    if (visible) {
      refreshIncome(silent: true);
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(seconds: 9), (_) {
        if (_dashboardVisible) refreshIncome(silent: true);
      });
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  void _seedDemoTransactions() {
    final now = DateTime.now();

    DateTime at(int daysAgo, int hour, int minute) =>
        DateTime(now.year, now.month, now.day, hour, minute)
            .subtract(Duration(days: daysAgo));

    _transactions
      ..clear()
      ..addAll([
        Transaction(id: 'demo_01', source: 'swiggy', amount: 860, type: 'credit', category: 'delivery', date: at(0, 13, 10), status: 'settled', description: 'Delivery earnings'),
        Transaction(id: 'demo_02', source: 'zomato', amount: 720, type: 'credit', category: 'delivery', date: at(0, 11, 35), status: 'settled', description: 'Delivery earnings'),
        Transaction(id: 'demo_03', source: 'uber', amount: 1180, type: 'credit', category: 'rides', date: at(1, 20, 15), status: 'settled', description: 'Ride earnings'),
        Transaction(id: 'demo_04', source: 'rapido', amount: 540, type: 'credit', category: 'rides', date: at(1, 16, 40), status: 'settled', description: 'Bike ride earnings'),
        Transaction(id: 'demo_05', source: 'upwork', amount: 6400, type: 'credit', category: 'freelance', date: at(2, 10, 20), status: 'completed', description: 'Mobile UI milestone'),
        Transaction(id: 'demo_06', source: 'bank', amount: 3200, type: 'credit', category: 'bank_transfer', date: at(3, 9, 5), status: 'completed', description: 'Client bank transfer'),
        Transaction(id: 'demo_07', source: 'swiggy', amount: 940, type: 'credit', category: 'delivery', date: at(4, 14, 50), status: 'settled', description: 'Delivery earnings'),
        Transaction(id: 'demo_08', source: 'zomato', amount: 810, type: 'credit', category: 'delivery', date: at(5, 19, 25), status: 'settled', description: 'Delivery earnings'),
        Transaction(id: 'demo_09', source: 'uber', amount: 1320, type: 'credit', category: 'rides', date: at(6, 21, 5), status: 'settled', description: 'Ride earnings'),
        Transaction(id: 'demo_10', source: 'fiverr', amount: 2850, type: 'credit', category: 'freelance', date: at(8, 12, 45), status: 'completed', description: 'Logo design payout'),
        Transaction(id: 'demo_11', source: 'swiggy', amount: 780, type: 'credit', category: 'delivery', date: at(10, 15, 35), status: 'settled', description: 'Delivery earnings'),
        Transaction(id: 'demo_12', source: 'bank', amount: 4500, type: 'credit', category: 'bank_transfer', date: at(12, 10, 10), status: 'completed', description: 'Merchant settlement'),
        Transaction(id: 'demo_13', source: 'zomato', amount: 690, type: 'credit', category: 'delivery', date: at(14, 18, 30), status: 'settled', description: 'Delivery earnings'),
        Transaction(id: 'demo_14', source: 'uber', amount: 1090, type: 'credit', category: 'rides', date: at(17, 22, 0), status: 'settled', description: 'Ride earnings'),
        Transaction(id: 'demo_15', source: 'upwork', amount: 5200, type: 'credit', category: 'freelance', date: at(20, 9, 30), status: 'completed', description: 'API integration milestone'),
        Transaction(id: 'demo_16', source: 'rapido', amount: 610, type: 'credit', category: 'rides', date: at(22, 17, 15), status: 'pending', description: 'Bike ride earnings'),
        Transaction(id: 'demo_17', source: 'swiggy', amount: 920, type: 'credit', category: 'delivery', date: at(25, 13, 45), status: 'settled', description: 'Delivery earnings'),
        Transaction(id: 'demo_18', source: 'bank', amount: 3750, type: 'credit', category: 'bank_transfer', date: at(27, 11, 0), status: 'completed', description: 'Client bank transfer'),
      ]);

    _transactions.sort((a, b) => b.date.compareTo(a.date));
    lastUpdated = DateTime.now();
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  String _shortDayLabel(DateTime date, bool weekdayOnly) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (weekdayOnly) return weekdays[date.weekday - 1];
    return '${date.day}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

class _MutableIncomeBucket {
  _MutableIncomeBucket({
    required this.start,
    required this.end,
    required this.valuesBySource,
  });

  final DateTime start;
  final DateTime end;
  final Map<String, double> valuesBySource;
}
