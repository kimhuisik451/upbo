class DebtModel {
  final int id;
  final int profileId;
  final String? profileName;
  final int amount;
  final int remainingAmount;
  final DateTime transactionDate;
  final String? category;
  final String? memo;
  final String transactionType; // "lent" | "borrowed"
  final bool isSettled;

  DebtModel({
    required this.id,
    required this.profileId,
    this.profileName,
    required this.amount,
    required this.remainingAmount,
    required this.transactionDate,
    this.category,
    this.memo,
    required this.transactionType,
    this.isSettled = false,
  });

  bool get isLent => transactionType == 'lent';

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    final amount = _parseInt(json['amount']);
    return DebtModel(
      id: _parseInt(json['id']),
      profileId: _parseInt(json['profile_id']),
      profileName: json['profile_name'],
      amount: amount,
      remainingAmount: _parseInt(json['remaining_amount']),
      transactionDate: DateTime.parse(json['transaction_date']),
      category: json['category'],
      memo: json['memo'],
      transactionType: json['transaction_type'] ?? 'lent',
      isSettled: json['is_settled'] ?? false,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }
}
