/// Represents a data-sharing consent the user has granted (or revoked)
/// to an institution/lender, including the exact scope of data shared.
class ConsentGrant {
  final String id;
  final String institutionName;
  final String category; // 'Bank' | 'NBFC' | 'Insurer' | 'Govt Programme' ...
  final List<String> scope;
  final bool active;
  final DateTime grantedOn;
  final DateTime? expiresOn;

  const ConsentGrant({
    required this.id,
    required this.institutionName,
    required this.category,
    required this.scope,
    required this.active,
    required this.grantedOn,
    this.expiresOn,
  });

  factory ConsentGrant.fromJson(Map<String, dynamic> json) {
    return ConsentGrant(
      id: json['id'] as String,
      institutionName: json['institutionName'] as String,
      category: json['category'] as String,
      scope: (json['scope'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      active: json['active'] as bool,
      grantedOn: DateTime.parse(json['grantedOn'] as String),
      expiresOn: json['expiresOn'] != null
          ? DateTime.tryParse(json['expiresOn'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institutionName': institutionName,
      'category': category,
      'scope': scope,
      'active': active,
      'grantedOn': grantedOn.toIso8601String(),
      'expiresOn': expiresOn?.toIso8601String(),
    };
  }
}
