import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class CredentialsProvider extends ChangeNotifier {
  CredentialsProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService() {
    _seedMock();
  }

  final ApiService _apiService;
  final List<Credential> _credentials = [];
  bool isLoading = false;
  bool isUsingDemoData = true;
  String? errorMessage;

  String? activeShareCredentialId;
  String? qrPayload;
  DateTime? qrExpiresAt;
  int remainingSeconds = 0;
  bool qrRevoked = false;
  Timer? _timer;

  List<Credential> get credentials => List.unmodifiable(_credentials);

  Future<void> loadCredentials() async {
    isLoading = true;
    notifyListeners();
    try {
      final live = await _apiService.fetchCredentials();
      if (live.isNotEmpty) {
        _credentials
          ..clear()
          ..addAll(live);
        isUsingDemoData = false;
      }
      errorMessage = null;
    } catch (_) {
      errorMessage = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Credential> generateEarningsCredential() async {
    final now = DateTime.now();
    try {
      final issued = await _apiService.issueCredential({
        'type': 'monthly_earnings_proof',
        'period': '${now.year}-${now.month.toString().padLeft(2, '0')}',
      });
      if (issued.id.isNotEmpty) {
        _credentials.insert(0, issued);
        isUsingDemoData = false;
        notifyListeners();
        return issued;
      }
    } catch (_) {
      // Demo fallback below.
    }

    final demo = Credential(
      id: 'cr_${now.microsecondsSinceEpoch}',
      title: 'Monthly Earnings Proof',
      credentialType: 'Monthly Earnings Proof',
      issuedFor: 'Current month',
      coveredPeriod: '${_monthName(now.month)} ${now.year}',
      status: 'verified',
      dateIssued: now,
      verificationHash: 'vf:${now.microsecondsSinceEpoch.toRadixString(16)}:a91c7e2f',
      dataSummary: const {
        'Verified income': '₹42,350',
        'Connected sources': '5',
        'Transactions checked': '28',
        'Income consistency': '84%',
      },
    );
    _credentials.insert(0, demo);
    notifyListeners();
    return demo;
  }

  void generateShareQr(Credential credential) {
    _timer?.cancel();
    final now = DateTime.now();
    final expires = now.add(const Duration(minutes: 10));
    final payload = {
      'type': 'VFID_VERIFIABLE_SNAPSHOT',
      'credentialId': credential.id,
      'credentialType': credential.displayType,
      'period': credential.displayPeriod,
      'issuedAt': now.toUtc().toIso8601String(),
      'expiresAt': expires.toUtc().toIso8601String(),
      'verification': credential.verificationHash ?? 'vf:demo:verified',
      'earningsSnapshot': {
        'verifiedMonthlyIncome': 42350,
        'incomeConsistency': 84,
        'onTimePaymentRate': 92,
        'trustScore': 824,
      },
    };
    activeShareCredentialId = credential.id;
    qrPayload = jsonEncode(payload);
    qrExpiresAt = expires;
    qrRevoked = false;
    remainingSeconds = 600;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (qrExpiresAt == null) return;
      final seconds = qrExpiresAt!.difference(DateTime.now()).inSeconds;
      remainingSeconds = seconds.clamp(0, 600).toInt();
      if (remainingSeconds <= 0) _timer?.cancel();
      notifyListeners();
    });
    notifyListeners();
  }

  void revokeQr() {
    _timer?.cancel();
    qrRevoked = true;
    remainingSeconds = 0;
    notifyListeners();
  }

  void regenerateQr(Credential credential) => generateShareQr(credential);

  String get countdownLabel {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _seedMock() {
    final now = DateTime.now();
    _credentials
      ..clear()
      ..addAll([
        Credential(
          id: 'cr_aug_income',
          title: 'Monthly Earnings Proof',
          credentialType: 'Monthly Earnings Proof',
          issuedFor: 'Aggregated earnings',
          coveredPeriod: 'August 2026',
          status: 'verified',
          dateIssued: DateTime(2026, 9, 1, 8, 42),
          verificationHash: 'vf:8f21:a91c7e2f:44bd',
          dataSummary: const {
            'Verified income': '₹42,100',
            'Connected sources': '5',
            'Transactions checked': '31',
            'Largest source': 'Swiggy · ₹14,200',
          },
        ),
        Credential(
          id: 'cr_rent_12m',
          title: 'Rent Payment History',
          credentialType: 'Rent Payment History',
          issuedFor: 'Recurring housing payments',
          coveredPeriod: 'Sep 2025 – Aug 2026',
          status: 'verified',
          dateIssued: DateTime(2026, 8, 28, 17, 10),
          verificationHash: 'vf:22bd:18c2f301:901e',
          dataSummary: const {
            'Payments tracked': '12 months',
            'Paid on time': '11 / 12',
            'Monthly rent': '₹9,500',
            'Late payments': '1',
          },
        ),
        Credential(
          id: 'cr_capacity_q3',
          title: 'Repayment Capacity Snapshot',
          credentialType: 'Repayment Capacity Snapshot',
          issuedFor: 'Income minus recurring obligations',
          coveredPeriod: 'Q3 2026',
          status: 'verified',
          dateIssued: DateTime(2026, 8, 15, 12, 5),
          verificationHash: 'vf:60c8:77a2d14b:19fe',
          dataSummary: const {
            'Average monthly income': '₹38,608',
            'Recurring obligations': '₹16,800',
            'Estimated capacity': '₹21,808',
            'Trust Score': '824 · Strong',
          },
        ),
      ]);
    if (now.year < 2026) return;
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
