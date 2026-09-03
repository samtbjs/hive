import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class ConsentProvider extends ChangeNotifier {
  ConsentProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService() {
    _seedMock();
  }

  static const dataCategories = ['income', 'obligations', 'credentials'];
  final ApiService _apiService;
  final List<ConsentGrant> _institutions = [];

  bool isLoading = false;
  bool isUsingDemoData = true;
  String? errorMessage;

  List<ConsentGrant> get institutions => List.unmodifiable(_institutions);

  Future<void> loadConsents() async {
    isLoading = true;
    notifyListeners();
    try {
      final live = await _apiService.fetchConsentGrants();
      if (live.isNotEmpty) {
        _institutions
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

  Future<void> setCategoryAccess(String id, String category, bool allowed) async {
    final index = _institutions.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final current = _institutions[index];
    final scope = current.scope.map((e) => e.toLowerCase()).toSet();
    if (allowed) {
      scope.add(category.toLowerCase());
    } else {
      scope.remove(category.toLowerCase());
    }
    final updated = current.copyWith(
      scope: scope.toList(),
      active: scope.isNotEmpty,
      status: scope.isEmpty ? 'revoked' : 'active',
      accessLevel: scope.length == 3 ? 'Full selected profile' : '${scope.length} data ${scope.length == 1 ? 'category' : 'categories'}',
    );
    _institutions[index] = updated;
    notifyListeners();

    try {
      await _apiService.grantConsent(updated.toJson());
    } catch (_) {
      // Keep optimistic demo UI. Real production code can retry/rollback.
    }
  }

  Future<void> revokeAccess(String id) async {
    final index = _institutions.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final current = _institutions[index];
    _institutions[index] = current.copyWith(
      scope: const [],
      active: false,
      status: 'revoked',
      accessLevel: 'No access',
    );
    notifyListeners();
    try {
      await _apiService.revokeConsent(id);
    } catch (_) {
      // Optimistic UI intentionally remains updated for the offline demo.
    }
  }

  void _seedMock() {
    _institutions
      ..clear()
      ..addAll([
        ConsentGrant(
          id: 'cg_hdfc', institutionName: 'HDFC Bank', category: 'Bank',
          scope: const ['income', 'obligations', 'credentials'], active: true,
          grantedOn: DateTime(2026, 8, 28), status: 'active', accessLevel: 'Full selected profile',
        ),
        ConsentGrant(
          id: 'cg_bajaj', institutionName: 'Bajaj Finserv', category: 'NBFC',
          scope: const ['income', 'credentials'], active: true,
          grantedOn: DateTime(2026, 8, 30), status: 'active', accessLevel: '2 data categories',
        ),
        ConsentGrant(
          id: 'cg_digit', institutionName: 'Digit Insurance', category: 'Insurer',
          scope: const [], active: false,
          grantedOn: DateTime(2026, 9, 2), status: 'pending', accessLevel: 'Request pending',
        ),
        ConsentGrant(
          id: 'cg_urban', institutionName: 'Urban Company', category: 'Employer / platform',
          scope: const [], active: false,
          grantedOn: DateTime(2026, 7, 12), status: 'revoked', accessLevel: 'No access',
        ),
      ]);
  }
}
