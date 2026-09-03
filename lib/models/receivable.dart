/// Money expected from a client/customer but not collected yet.
class Receivable {
  final String id;
  final String name;
  final String source;
  final double amount;
  final DateTime dueDate;
  final String status; // 'paid' | 'pending' | 'overdue'

  const Receivable({
    required this.id,
    required this.name,
    required this.source,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  factory Receivable.fromJson(Map<String, dynamic> json) {
    return Receivable(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['description'] ?? 'Receivable').toString(),
      source: (json['source'] ?? 'other').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      dueDate: DateTime.tryParse(
            (json['dueDate'] ?? json['due_date'] ?? '').toString(),
          ) ??
          DateTime.now(),
      status: (json['status'] ?? 'pending').toString().toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'source': source,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
    };
  }
}
