import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import '../models/models.dart';

/// Thin wrapper around the REST backend. Every method here is a clean stub:
/// it calls the placeholder endpoint in [ApiConfig], parses the expected
/// shape, and surfaces errors — but there is no real backend behind it yet.
///
/// Swap the TODOs in api_config.dart for real endpoints and these methods
/// should keep working unchanged.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        // TODO: attach real auth token, e.g. 'Authorization': 'Bearer ...'
      };

  // ---- Income sync --------------------------------------------------------

  /// GET the user's connected income sources.
  Future<List<IncomeSource>> fetchIncomeSources() async {
    // TODO: replace with real endpoint call once backend is live
    final uri = ApiConfig.buildUri(ApiConfig.incomeSources);
    final response = await _client.get(uri, headers: _headers);
    final body = _decodeList(response.body);
    return body.map((e) => IncomeSource.fromJson(e)).toList();
  }

  /// POST to trigger a fresh sync of income across connected platforms.
  Future<void> syncIncome() async {
    // TODO: replace with real endpoint call once backend is live
    final uri = ApiConfig.buildUri(ApiConfig.incomeSync);
    await _client.post(uri, headers: _headers);
  }

  /// GET recent transactions across all connected sources.
  Future<List<Transaction>> fetchTransactions() async {
    // TODO: replace with real endpoint call once backend is live
    final uri = ApiConfig.buildUri(ApiConfig.incomeTransactions);
    final response = await _client.get(uri, headers: _headers);
    final body = _decodeTransactionList(response.body);
    return body.map((e) => Transaction.fromJson(e)).toList();
  }

  // ---- Obligations ----------------------------------------------------------

  /// GET the user's tracked obligations (rent, EMIs, utilities, ...).
  Future<List<Obligation>> fetchObligations() async {
    // TODO: replace with real endpoint call once backend is live
    final uri = ApiConfig.buildUri(ApiConfig.obligations);
    final response = await _client.get(uri, headers: _headers);
    final body = _decodeList(response.body);
    return body.map((e) => Obligation.fromJson(e)).toList();
  }

  // ---- Credentials / proofs ---------------------------------------------------

  /// GET all issued credentials/proofs for the user.
  Future<List<Credential>> fetchCredentials() async {
    // TODO: replace with real endpoint call once backend is live
    final uri = ApiConfig.buildUri(ApiConfig.credentials);
    final response = await _client.get(uri, headers: _headers);
    final body = _decodeList(response.body);
    return body.map((e) => Credential.fromJson(e)).toList();
  }

  /// POST to request a new tamper-proof credential be issued.
  Future<Credential> issueCredential(Map<String, dynamic> request) async {
    // TODO: replace with real endpoint call once backend is live
    final uri = ApiConfig.buildUri(ApiConfig.credentialIssue);
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode(request),
    );
    return Credential.fromJson(_decodeMap(response.body));
  }

  // ---- Consent / sharing -----------------------------------------------------

  /// GET all active/past consent grants the user has made.
  Future<List<ConsentGrant>> fetchConsentGrants() async {
    // TODO: replace with real endpoint call once backend is live
    final uri = ApiConfig.buildUri(ApiConfig.consentGrants);
    final response = await _client.get(uri, headers: _headers);
    final body = _decodeList(response.body);
    return body.map((e) => ConsentGrant.fromJson(e)).toList();
  }

  /// POST to grant a new institution access to a defined data scope.
  Future<ConsentGrant> grantConsent(Map<String, dynamic> request) async {
    // TODO: replace with real endpoint call once backend is live
    final uri = ApiConfig.buildUri(ApiConfig.consentGrant);
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode(request),
    );
    return ConsentGrant.fromJson(_decodeMap(response.body));
  }

  /// POST to revoke a previously granted consent by id.
  Future<void> revokeConsent(String id) async {
    // TODO: replace with real endpoint call once backend is live
    final uri = ApiConfig.buildUri(ApiConfig.consentRevoke, id: id);
    await _client.post(uri, headers: _headers);
  }

  // ---- Institution decisions ---------------------------------------------------

  /// GET decisions institutions have made on the user's applications,
  /// including explainability reasons (for the "Why" tab).
  Future<List<InstitutionDecision>> fetchInstitutionDecisions() async {
    // TODO: replace with real endpoint call once backend is live
    final uri = ApiConfig.buildUri(ApiConfig.institutionDecisions);
    final response = await _client.get(uri, headers: _headers);
    final body = _decodeList(response.body);
    return body.map((e) => InstitutionDecision.fromJson(e)).toList();
  }

  // ---- helpers --------------------------------------------------------------


  List<Map<String, dynamic>> _decodeTransactionList(String body) {
    if (body.isEmpty) return [];
    final decoded = jsonDecode(body);
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }
    if (decoded is Map<String, dynamic>) {
      final transactions = decoded['transactions'];
      if (transactions is List) {
        return transactions.cast<Map<String, dynamic>>();
      }
      final data = decoded['data'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      if (data is Map<String, dynamic> && data['transactions'] is List) {
        return (data['transactions'] as List).cast<Map<String, dynamic>>();
      }
    }
    return [];
  }

  List<Map<String, dynamic>> _decodeList(String body) {
    if (body.isEmpty) return [];
    final decoded = jsonDecode(body);
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Map<String, dynamic> _decodeMap(String body) {
    if (body.isEmpty) return {};
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {};
  }
}
