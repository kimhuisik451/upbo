class RepaymentModel {
  final int id;
  final int debtId;
  final int amount;
  final DateTime repaymentDate;
  final String? memo;

  RepaymentModel({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.repaymentDate,
    this.memo,
  });

  factory RepaymentModel.fromJson(Map<String, dynamic> json) {
    return RepaymentModel(
      id: _parseInt(json['id']),
      debtId: _parseInt(json['debt_id']),
      amount: _parseInt(json['amount']),
      repaymentDate: DateTime.parse(json['repayment_date']),
      memo: json['memo'],
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return double.tryParse(value)?.toInt() ?? 0;
    return 0;
  }
}
