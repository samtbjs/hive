import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Time range shown in the reliability cash-flow graph.
enum ReliabilityPeriod { weekly, monthly }

class CashFlowPoint {
  const CashFlowPoint({
    required this.label,
    required this.income,
    required this.outflow,
  });

  final String label;
  final double income;
  final double outflow;
}

/// Derived Dashboard state for repayment capacity and the explainable
/// alternative-credit Trust Score.
class FinancialReliabilityProvider extends ChangeNotifier {
  ReliabilityPeriod selectedPeriod = ReliabilityPeriod.monthly;

  double _incomeConsistency = 0.84;
  double _paymentConsistency = 11 / 12;
  double _averageRecurringObligations = 16800;
  bool _usingDemoIncome = true;

  final List<CashFlowPoint> _monthlyDemo = const [
    CashFlowPoint(label: 'Apr', income: 34200, outflow: 15800),
    CashFlowPoint(label: 'May', income: 36500, outflow: 16200),
    CashFlowPoint(label: 'Jun', income: 38100, outflow: 16400),
    CashFlowPoint(label: 'Jul', income: 37400, outflow: 16100),
    CashFlowPoint(label: 'Aug', income: 42100, outflow: 16800),
    CashFlowPoint(label: 'Sep', income: 42350, outflow: 16800),
  ];

  final List<CashFlowPoint> _weeklyDemo = const [
    CashFlowPoint(label: 'W1', income: 9100, outflow: 3900),
    CashFlowPoint(label: 'W2', income: 10400, outflow: 4300),
    CashFlowPoint(label: 'W3', income: 9800, outflow: 4100),
    CashFlowPoint(label: 'W4', income: 11700, outflow: 4500),
    CashFlowPoint(label: 'W5', income: 10900, outflow: 4200),
    CashFlowPoint(label: 'W6', income: 12100, outflow: 4600),
  ];

  List<CashFlowPoint> get cashFlowPoints =>
      selectedPeriod == ReliabilityPeriod.weekly ? _weeklyDemo : _monthlyDemo;

  double get incomeConsistency => _incomeConsistency;
  double get paymentConsistency => _paymentConsistency;

  double get averageMonthlyIncome {
    final points = _monthlyDemo;
    if (points.isEmpty) return 0;
    return points.fold(0.0, (sum, point) => sum + point.income) / points.length;
  }

  double get averageRecurringObligations => _averageRecurringObligations;

  double get repaymentCapacity =>
      math.max(0.0, averageMonthlyIncome - averageRecurringObligations);

  /// CIBIL-like presentation range: 300–900.
  /// 60% = on-time payment behaviour, 40% = income consistency.
  int get trustScore {
    final weighted = (_paymentConsistency * 0.60) + (_incomeConsistency * 0.40);
    return (300 + (weighted.clamp(0.0, 1.0) * 600)).round();
  }

  String get trustLabel {
    if (trustScore >= 780) return 'Strong';
    if (trustScore >= 650) return 'Reliable';
    return 'Building';
  }

  List<String> get trustFactors => [
        'Rent & utility payments: ${(_paymentConsistency * 100).round()}% on time',
        '${(_incomeConsistency * 100).round()}% income consistency across recent months',
        'Recurring obligations use ${obligationLoadPercent.round()}% of average monthly income',
      ];

  double get obligationLoadPercent {
    if (averageMonthlyIncome <= 0) return 0;
    return (_averageRecurringObligations / averageMonthlyIncome * 100)
        .clamp(0.0, 100.0)
        .toDouble();
  }

  void setPeriod(ReliabilityPeriod period) {
    if (selectedPeriod == period) return;
    selectedPeriod = period;
    notifyListeners();
  }

  /// Receives the current feature-provider data through ProxyProvider.
  /// Demo cash-flow values stay stable until the income endpoint is live.
  void updateInputs({
    required List<Transaction> transactions,
    required double recurringObligations,
    required double onTimePaymentRate,
    required bool usingDemoIncome,
  }) {
    var changed = false;

    if ((_averageRecurringObligations - recurringObligations).abs() > 0.01) {
      _averageRecurringObligations = recurringObligations;
      changed = true;
    }

    final paymentRate = onTimePaymentRate.clamp(0.0, 1.0).toDouble();
    if ((_paymentConsistency - paymentRate).abs() > 0.001) {
      _paymentConsistency = paymentRate;
      changed = true;
    }

    if (_usingDemoIncome != usingDemoIncome) {
      _usingDemoIncome = usingDemoIncome;
      changed = true;
    }

    if (!usingDemoIncome && transactions.isNotEmpty) {
      final liveConsistency = _calculateIncomeConsistency(transactions);
      if ((_incomeConsistency - liveConsistency).abs() > 0.001) {
        _incomeConsistency = liveConsistency;
        changed = true;
      }
    }

    if (changed) notifyListeners();
  }

  double _calculateIncomeConsistency(List<Transaction> transactions) {
    final monthlyTotals = <String, double>{};

    for (final transaction in transactions.where((item) => item.isIncome)) {
      final key = '${transaction.date.year}-${transaction.date.month}';
      monthlyTotals.update(
        key,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final values = monthlyTotals.values.where((value) => value > 0).toList();
    if (values.length < 2) return _incomeConsistency;

    final mean = values.reduce((a, b) => a + b) / values.length;
    if (mean <= 0) return 0;

    final variance = values
            .map((value) => math.pow(value - mean, 2).toDouble())
            .reduce((a, b) => a + b) /
        values.length;
    final coefficientOfVariation = math.sqrt(variance) / mean;

    return (1 - coefficientOfVariation).clamp(0.0, 1.0).toDouble();
  }
}
