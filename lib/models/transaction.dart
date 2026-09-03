/// A single inflow/outflow event pulled from a connected income source
/// or bank account.
class Transaction {
  final String id;
  final String sourceId;
  final String sourceName;
  final double amount;
  final String type; // 'credit' | 'debit'
  final String category;
  final DateTime date;
  final String? description;

  const Transaction({
    required this.id,
    required this.sourceId,
    required this.sourceName,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      sourceId: json['sourceId'] as String,
      sourceName: json['sourceName'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceId': sourceId,
      'sourceName': sourceName,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
