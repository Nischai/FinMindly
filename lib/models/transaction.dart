enum TransactionType { income, expense }

class Transaction {
  final String id;
  final DateTime date;
  final double amount;
  final TransactionType type;
  final String description;
  final String category;
  final List<String> tags;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.description,
    this.category = 'Others',
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'description': description,
      'category': category,
      'tags': tags,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      date: DateTime.parse(json['date']),
      amount: json['amount'].toDouble(),
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      description: json['description'],
      category: json['category'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : <String>[],
    );
  }

  // Create a copy of this transaction with updated fields
  Transaction copyWith({
    String? id,
    DateTime? date,
    double? amount,
    TransactionType? type,
    String? description,
    String? category,
    List<String>? tags,
  }) {
    return Transaction(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      category: category ?? this.category,
      tags: tags ?? this.tags,
    );
  }
}
