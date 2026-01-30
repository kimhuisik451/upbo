import 'package:flutter/material.dart';
import '../../data/models/debt_model.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/debt_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../theme/app_colors.dart';
import 'debt_detail_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _debtRepository = DebtRepository();
  final _profileRepository = ProfileRepository();
  List<DebtModel> _debts = [];
  Map<int, String> _profileNames = {};
  bool _isLoading = true;
  
  // 필터 상태
  String? _transactionTypeFilter; // null: 전체, 'lent': 빌려준, 'borrowed': 빌린
  bool? _isSettledFilter; // null: 전체, true: 정산완료, false: 미정산

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _debtRepository.getDebts(
          transactionType: _transactionTypeFilter,
          isSettled: _isSettledFilter,
        ),
        _profileRepository.getProfiles(),
      ]);
      
      final debts = results[0] as List<DebtModel>;
      final profiles = results[1] as List<ProfileModel>;
      
      setState(() {
        _debts = debts;
        _profileNames = {for (var p in profiles) p.id: p.name};
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로드 실패: $e')),
        );
      }
    }
  }

  String _getProfileName(DebtModel debt) {
    return debt.profileName ?? _profileNames[debt.profileId] ?? '알 수 없음';
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('필터', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('거래 유형', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('전체', _transactionTypeFilter == null, () {
                    setModalState(() => _transactionTypeFilter = null);
                  }),
                  _buildFilterChip('빌려준', _transactionTypeFilter == 'lent', () {
                    setModalState(() => _transactionTypeFilter = 'lent');
                  }),
                  _buildFilterChip('빌린', _transactionTypeFilter == 'borrowed', () {
                    setModalState(() => _transactionTypeFilter = 'borrowed');
                  }),
                ],
              ),
              const SizedBox(height: 16),
              const Text('정산 상태', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('전체', _isSettledFilter == null, () {
                    setModalState(() => _isSettledFilter = null);
                  }),
                  _buildFilterChip('미정산', _isSettledFilter == false, () {
                    setModalState(() => _isSettledFilter = false);
                  }),
                  _buildFilterChip('정산완료', _isSettledFilter == true, () {
                    setModalState(() => _isSettledFilter = true);
                  }),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {});
                    _loadData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('적용', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          '거래내역',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _debts.isEmpty
              ? const Center(
                  child: Text(
                    '거래 내역이 없습니다',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _debts.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DebtDetailScreen(debtId: _debts[index].id),
                          ),
                        );
                        if (result == true) {
                          _loadData();
                        }
                      },
                      child: _buildTransactionItem(_debts[index]),
                    ),
                  ),
                ),
    );
  }

  Widget _buildTransactionItem(DebtModel debt) {
    final name = _getProfileName(debt);
    final date = '${debt.transactionDate.year}.${debt.transactionDate.month.toString().padLeft(2, '0')}.${debt.transactionDate.day.toString().padLeft(2, '0')}';
    final displayAmount = debt.remainingAmount > 0 ? debt.remainingAmount : debt.amount;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              name[0],
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: debt.isLent ? AppColors.primary.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        debt.isLent ? '빌려줌' : '빌림',
                        style: TextStyle(
                          fontSize: 10,
                          color: debt.isLent ? AppColors.primary : AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$date${debt.memo != null ? ' · ${debt.memo}' : ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${debt.isLent ? '+' : '-'}₩${_formatNumber(displayAmount)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: debt.isLent ? AppColors.primary : AppColors.error,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: debt.isSettled ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  debt.isSettled ? '정산완료' : '미정산',
                  style: TextStyle(
                    fontSize: 11,
                    color: debt.isSettled ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
