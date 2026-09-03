/// A recurring or one-off financial commitment (rent, EMI, utility bill).
class Obligation {
  final String id;
  final String name;
  final String type; // 'rent' | 'emi' | 'utility' | 'loan' | 'other'
  final double amount;
  final DateTime dueDate;
  final String status; // 'paid' | 'pending' | 'overdue'
  final bool recurring;

  const Obligation({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.recurring,
  });

  factory Obligation.fromJson(Map<String, dynamic> json) {
    return Obligation(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: json['status'] as String,
      recurring: json['recurring'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'recurring': recurring,
    };
  }
}
