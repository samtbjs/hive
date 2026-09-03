/// Consent record with category-level sharing controls.
class ConsentGrant {
  final String id;
  final String institutionName;
  final String category;
  final List<String> scope;
  final bool active;
  final DateTime grantedOn;
  final DateTime? expiresOn;
  final String status; // active | pending | revoked
  final String accessLevel;

  const ConsentGrant({
    required this.id,
    required this.institutionName,
    required this.category,
    required this.scope,
    required this.active,
    required this.grantedOn,
    this.expiresOn,
    this.status = 'active',
    this.accessLevel = 'Selected financial data',
  });

  bool hasScope(String value) =>
      scope.map((e) => e.toLowerCase()).contains(value.toLowerCase());

  ConsentGrant copyWith({
    List<String>? scope,
    bool? active,
    String? status,
    String? accessLevel,
  }) => ConsentGrant(
        id: id,
        institutionName: institutionName,
        category: category,
        scope: scope ?? this.scope,
        active: active ?? this.active,
        grantedOn: grantedOn,
        expiresOn: expiresOn,
        status: status ?? this.status,
        accessLevel: accessLevel ?? this.accessLevel,
      );

  factory ConsentGrant.fromJson(Map<String, dynamic> json) {
    final active = json['active'] as bool? ?? (json['status']?.toString().toLowerCase() == 'active');
    return ConsentGrant(
      id: (json['id'] ?? '').toString(),
      institutionName: (json['institutionName'] ?? 'Institution').toString(),
      category: (json['category'] ?? 'Institution').toString(),
      scope: (json['scope'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      active: active,
      grantedOn: DateTime.tryParse((json['grantedOn'] ?? '').toString()) ?? DateTime.now(),
      expiresOn: json['expiresOn'] != null ? DateTime.tryParse(json['expiresOn'].toString()) : null,
      status: (json['status'] ?? (active ? 'active' : 'revoked')).toString().toLowerCase(),
      accessLevel: (json['accessLevel'] ?? 'Selected financial data').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'institutionName': institutionName,
        'category': category,
        'scope': scope,
        'active': active,
        'grantedOn': grantedOn.toIso8601String(),
        'expiresOn': expiresOn?.toIso8601String(),
        'status': status,
        'accessLevel': accessLevel,
      };
}
