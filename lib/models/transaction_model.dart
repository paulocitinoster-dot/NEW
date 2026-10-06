class TransactionModel {
  final String id;
  final String familyId;
  final String userId;
  final String categoryId;
  final String description;
  final double amount;
  final String type; // 'income' or 'expense'
  final String paymentMethod;
  final DateTime transactionDate;
  final String status;
  final String? notes;

  TransactionModel({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.categoryId,
    required this.description,
    required this.amount,
    required this.type,
    required this.paymentMethod,
    required this.transactionDate,
    required this.status,
    this.notes,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      familyId: json['family_id'],
      userId: json['user_id'],
      categoryId: json['category_id'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
      type: json['type'] ?? 'expense',
      paymentMethod: json['payment_method'] ?? 'Pix',
      transactionDate: DateTime.parse(json['transaction_date']),
      status: json['status'] ?? 'paid',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'family_id': familyId,
      'user_id': userId,
      'category_id': categoryId,
      'description': description,
      'amount': amount,
      'type': type,
      'payment_method': paymentMethod,
      'transaction_date': transactionDate.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }
}
