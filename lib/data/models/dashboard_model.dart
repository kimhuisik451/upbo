import 'debt_model.dart';

class DashboardModel {
  final int totalLent;
  final int totalBorrowed;
  final int lentRemaining;
  final int borrowedRemaining;
  final List<DebtModel> recentTransactions;

  DashboardModel({
    required this.totalLent,
    required this.totalBorrowed,
    required this.lentRemaining,
    required this.borrowedRemaining,
    required this.recentTransactions,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final transactions = (json['recent_transactions'] as List<dynamic>?)
        ?.map((e) => DebtModel.fromJson(e))
        .toList() ?? [];
    
    return DashboardModel(
      totalLent: _parseInt(json['total_lent']),
      totalBorrowed: _parseInt(json['total_borrowed']),
      lentRemaining: _parseInt(json['lent_remaining']),
      borrowedRemaining: _parseInt(json['borrowed_remaining']),
      recentTransactions: transactions,
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
