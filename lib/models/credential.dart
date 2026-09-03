/// API-generated financial proof. It represents data already sourced from
/// connected income/payment systems; it is not a user-uploaded document.
class Credential {
  final String id;
  final String title;
  final String issuedFor;
  final String status;
  final DateTime? dateIssued;
  final String? verificationHash;
  final String? credentialType;
  final String? coveredPeriod;
  final Map<String, String> dataSummary;

  const Credential({
    required this.id,
    required this.title,
    required this.issuedFor,
    required this.status,
    this.dateIssued,
    this.verificationHash,
    this.credentialType,
    this.coveredPeriod,
    this.dataSummary = const {},
  });

  String get displayType => credentialType ?? title;
  String get displayPeriod => coveredPeriod ?? issuedFor;
  DateTime? get generatedAt => dateIssued;

  factory Credential.fromJson(Map<String, dynamic> json) {
    final rawSummary = json['dataSummary'] ?? json['data_summary'];
    final summary = <String, String>{};
    if (rawSummary is Map) {
      for (final entry in rawSummary.entries) {
        summary[entry.key.toString()] = entry.value.toString();
      }
    }

    return Credential(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['credentialType'] ?? 'Financial credential').toString(),
      issuedFor: (json['issuedFor'] ?? json['coveredPeriod'] ?? 'Financial profile').toString(),
      status: (json['status'] ?? 'verified').toString(),
      dateIssued: _parseDate(json['dateIssued'] ?? json['generatedAt']),
      verificationHash: (json['verificationHash'] ?? json['hash'])?.toString(),
      credentialType: json['credentialType']?.toString(),
      coveredPeriod: json['coveredPeriod']?.toString(),
      dataSummary: summary,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'issuedFor': issuedFor,
        'status': status,
        'dateIssued': dateIssued?.toIso8601String(),
        'verificationHash': verificationHash,
        'credentialType': credentialType,
        'coveredPeriod': coveredPeriod,
        'dataSummary': dataSummary,
      };

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
