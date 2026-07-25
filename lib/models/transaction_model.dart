class TransactionModel {
  final String id;
  final String type;
  final String category;
  final double amount;
  final String description;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      type: json['type'],
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }
}
