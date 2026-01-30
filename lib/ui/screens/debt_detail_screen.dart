import 'package:flutter/material.dart';
import '../../data/models/debt_model.dart';
import '../../data/models/repayment_model.dart';
import '../../data/repositories/debt_repository.dart';
import '../../data/repositories/repayment_repository.dart';
import '../theme/app_colors.dart';
import 'add_repayment_screen.dart';

class DebtDetailScreen extends StatefulWidget {
  final int debtId;

  const DebtDetailScreen({super.key, required this.debtId});

  @override
  State<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends State<DebtDetailScreen> {
  final _debtRepository = DebtRepository();
  final _repaymentRepository = RepaymentRepository();
  DebtModel? _debt;
  List<RepaymentModel> _repayments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _debtRepository.getDebt(widget.debtId),
        _repaymentRepository.getRepayments(debtId: widget.debtId),
      ]);
      setState(() {
        _debt = results[0] as DebtModel;
        _repayments = results[1] as List<RepaymentModel>;
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

  Future<void> _loadDebt() async {
    try {
      final results = await Future.wait([
        _debtRepository.getDebt(widget.debtId),
        _repaymentRepository.getRepayments(debtId: widget.debtId),
      ]);
      setState(() {
        _debt = results[0] as DebtModel;
        _repayments = results[1] as List<RepaymentModel>;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로드 실패: $e')),
        );
      }
    }
  }

  bool _hasChanges = false;

  Future<void> _toggleSettled() async {
    if (_debt == null) return;
    try {
      final updated = await _debtRepository.updateDebt(
        debtId: _debt!.id,
        isSettled: !_debt!.isSettled,
      );
      setState(() {
        _debt = updated;
        _hasChanges = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(updated.isSettled ? '정산 완료 처리되었습니다' : '미정산 처리되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('상태 변경 실패: $e')),
        );
      }
    }
  }

  void _showEditDialog() {
    if (_debt == null) return;
    final categoryController = TextEditingController(text: _debt!.category ?? '');
    final memoController = TextEditingController(text: _debt!.memo ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('채무 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: '카테고리',
                hintText: '예: 저녁값, 교통비',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: memoController,
              decoration: const InputDecoration(
                labelText: '메모',
                hintText: '메모를 입력하세요',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateDebt(
                category: categoryController.text.isEmpty ? null : categoryController.text,
                memo: memoController.text.isEmpty ? null : memoController.text,
              );
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDebt({String? category, String? memo}) async {
    try {
      final updated = await _debtRepository.updateDebt(
        debtId: _debt!.id,
        category: category,
        memo: memo,
      );
      setState(() {
        _debt = updated;
        _hasChanges = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수정되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 실패: $e')),
        );
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('채무 삭제'),
        content: const Text('이 거래를 삭제하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteDebt();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDebt() async {
    try {
      await _debtRepository.deleteDebt(widget.debtId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제되었습니다')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, _hasChanges),
        ),
        title: const Text(
          '거래 상세',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.textPrimary),
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _debt == null
              ? const Center(child: Text('데이터를 불러올 수 없습니다'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildDetailSection(),
                      if (_repayments.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildRepaymentSection(),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    final debt = _debt!;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: debt.isLent
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              debt.isLent ? '빌려줌' : '빌림',
              style: TextStyle(
                color: debt.isLent ? AppColors.primary : AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${debt.isLent ? '+' : '-'}₩${_formatNumber(debt.remainingAmount > 0 ? debt.remainingAmount : debt.amount)}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: debt.isLent ? AppColors.primary : AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: debt.isSettled
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              debt.isSettled ? '정산완료' : '미정산',
              style: TextStyle(
                fontSize: 13,
                color: debt.isSettled ? AppColors.success : AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection() {
    final debt = _debt!;
    final date = '${debt.transactionDate.year}.${debt.transactionDate.month.toString().padLeft(2, '0')}.${debt.transactionDate.day.toString().padLeft(2, '0')}';

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '상세 정보',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('상대방', debt.profileName ?? '알 수 없음'),
          _buildDetailRow('거래일', date),
          if (debt.category != null) _buildDetailRow('카테고리', debt.category!),
          if (debt.memo != null) _buildDetailRow('메모', debt.memo!),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _toggleSettled,
              style: ElevatedButton.styleFrom(
                backgroundColor: debt.isSettled ? AppColors.warning : AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                debt.isSettled ? '미정산으로 변경' : '정산 완료 처리',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          if (!debt.isSettled) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddRepaymentScreen(
                        debtId: debt.id,
                        profileName: debt.profileName ?? '알 수 없음',
                        remainingAmount: debt.remainingAmount > 0 ? debt.remainingAmount : debt.amount,
                      ),
                    ),
                  );
                  if (result == true) {
                    _hasChanges = true;
                    _loadDebt();
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Text(
                  '상환 등록',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
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

  Widget _buildRepaymentSection() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '상환 내역',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '총 ${_repayments.length}건',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._repayments.map((r) => _buildRepaymentItem(r)),
        ],
      ),
    );
  }

  Widget _buildRepaymentItem(RepaymentModel repayment) {
    final date = '${repayment.repaymentDate.year}.${repayment.repaymentDate.month.toString().padLeft(2, '0')}.${repayment.repaymentDate.day.toString().padLeft(2, '0')}';
    
    return GestureDetector(
      onLongPress: () => _showDeleteRepaymentDialog(repayment),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.payments_outlined, color: AppColors.success, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (repayment.memo != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      repayment.memo!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '-₩${_formatNumber(repayment.amount)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteRepaymentDialog(RepaymentModel repayment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('상환 삭제'),
        content: Text('₩${_formatNumber(repayment.amount)} 상환 내역을 삭제하시겠습니까?\n삭제 시 채무 금액이 복원됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRepayment(repayment.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRepayment(int repaymentId) async {
    try {
      await _repaymentRepository.deleteRepayment(repaymentId);
      _hasChanges = true;
      _loadDebt();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('상환 내역이 삭제되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }
}
