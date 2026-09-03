/// A connected platform / account that contributes to the user's
/// aggregated income picture (gig platform, freelance marketplace,
/// bank account, etc).
class IncomeSource {
  final String id;
  final String name;
  final String platformType; // e.g. 'Gig platform', 'Freelance', 'Bank'
  final double monthlyAmount;
  final bool connected;
  final bool verified;
  final String icon; // icon/emoji identifier for the source's logo

  const IncomeSource({
    required this.id,
    required this.name,
    required this.platformType,
    required this.monthlyAmount,
    required this.connected,
    required this.verified,
    required this.icon,
  });

  factory IncomeSource.fromJson(Map<String, dynamic> json) {
    return IncomeSource(
      id: json['id'] as String,
      name: json['name'] as String,
      platformType: json['platformType'] as String,
      monthlyAmount: (json['monthlyAmount'] as num).toDouble(),
      connected: json['connected'] as bool,
      verified: json['verified'] as bool? ?? false,
      icon: json['icon'] as String? ?? '💼',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'platformType': platformType,
      'monthlyAmount': monthlyAmount,
      'connected': connected,
      'verified': verified,
      'icon': icon,
    };
  }
}
