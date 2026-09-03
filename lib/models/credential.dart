/// A tamper-proof, issued proof (e.g. "Proof of Earnings — Aug 2026")
/// that the user can share with institutions.
class Credential {
  final String id;
  final String title;
  final String issuedFor;
  final String status; // 'verified' | 'pending' | 'expired'
  final DateTime? dateIssued;
  final String? verificationHash;

  const Credential({
    required this.id,
    required this.title,
    required this.issuedFor,
    required this.status,
    this.dateIssued,
    this.verificationHash,
  });

  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      id: json['id'] as String,
      title: json['title'] as String,
      issuedFor: json['issuedFor'] as String,
      status: json['status'] as String,
      dateIssued: json['dateIssued'] != null
          ? DateTime.tryParse(json['dateIssued'] as String)
          : null,
      verificationHash: json['verificationHash'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'issuedFor': issuedFor,
      'status': status,
      'dateIssued': dateIssued?.toIso8601String(),
      'verificationHash': verificationHash,
    };
  }
}
