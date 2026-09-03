/// A single inflow/outflow event pulled from a connected income source
/// or bank account.
///
/// [source] is the canonical source identifier supplied by the ingestion
/// pipeline (for example: "swiggy", "zomato", "uber", "rapido", "bank").
/// UI grouping must use this field directly rather than trying to infer the
/// source from names, descriptions, categories, or account metadata.
class Transaction {
  final String id;
  final String source;
  final String sourceId;
  final String sourceName;
  final double amount;
  final String type; // 'credit' | 'debit'
  final String category;
  final DateTime date;
  final String status;
  final String? description;

  const Transaction({
    required this.id,
    required this.source,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.sourceId = '',
    this.sourceName = '',
    this.status = 'completed',
    this.description,
  });

  bool get isIncome => type.toLowerCase() != 'debit' && amount > 0;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'] ?? json['timestamp'] ?? json['createdAt'];

    return Transaction(
      id: (json['id'] ?? '').toString(),
      source: (json['source'] ?? 'unknown').toString().toLowerCase(),
      sourceId: (json['sourceId'] ?? '').toString(),
      sourceName: (json['sourceName'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      type: (json['type'] ?? 'credit').toString().toLowerCase(),
      category: (json['category'] ?? 'income').toString(),
      date: rawDate == null
          ? DateTime.now()
          : DateTime.tryParse(rawDate.toString()) ?? DateTime.now(),
      status: (json['status'] ?? 'completed').toString().toLowerCase(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'sourceId': sourceId,
      'sourceName': sourceName,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'status': status,
      'description': description,
    };
  }
}
