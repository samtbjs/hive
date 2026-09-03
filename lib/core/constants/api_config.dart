/// Single source of truth for API base URL and endpoint paths.
///
/// Every URL below is a placeholder for the hackathon build — swap them
/// for real backend endpoints before shipping.
class ApiConfig {
  ApiConfig._();

  // TODO: replace with real endpoint
  static const String baseUrl = 'https://api.example-vfid.dev';

  // ---- Income sync -------------------------------------------------------
  // TODO: replace with real endpoint
  static const String incomeSources = '/v1/income/sources';
  // TODO: replace with real endpoint
  static const String incomeSync = '/v1/income/sync';
  // TODO: replace with real endpoint
  static const String incomeTransactions = '/v1/income/transactions';

  // ---- Obligations --------------------------------------------------------
  // TODO: replace with real endpoint
  static const String obligations = '/v1/obligations';
  // TODO: replace with real endpoint
  static const String obligationById = '/v1/obligations/{id}';
  // TODO: replace with real endpoint
  static const String receivables = '/v1/receivables';

  // ---- Credentials / proofs -----------------------------------------------
  // TODO: replace with real endpoint
  static const String credentials = '/v1/credentials';
  // TODO: replace with real endpoint
  static const String credentialIssue = '/v1/credentials/issue';
  // TODO: replace with real endpoint
  static const String credentialVerify = '/v1/credentials/{id}/verify';

  // ---- Consent / sharing ---------------------------------------------------
  // TODO: replace with real endpoint
  static const String consentGrants = '/v1/consent/grants';
  // TODO: replace with real endpoint
  static const String consentGrant = '/v1/consent/grant';
  // TODO: replace with real endpoint
  static const String consentRevoke = '/v1/consent/{id}/revoke';

  // ---- Institution decisions -----------------------------------------------
  // TODO: replace with real endpoint
  static const String institutionDecisions = '/v1/institution/decisions';
  // TODO: replace with real endpoint
  static const String institutionDecisionById =
      '/v1/institution/decisions/{id}';

  /// Helper to build a full URL from a path, substituting `{id}` when given.
  static Uri buildUri(String path, {String? id}) {
    final resolvedPath = id != null ? path.replaceAll('{id}', id) : path;
    return Uri.parse('$baseUrl$resolvedPath');
  }
}
