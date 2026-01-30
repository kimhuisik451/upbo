import 'package:flutter/material.dart';
import '../../data/models/debt_model.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/debt_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../theme/app_colors.dart';
import 'debt_detail_screen.dart';
import 'edit_profile_screen.dart';

class ProfileDetailScreen extends StatefulWidget {
  final int profileId;
  final String name;

  const ProfileDetailScreen({
    super.key,
    required this.profileId,
    required this.name,
  });

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final _profileRepository = ProfileRepository();
  final _debtRepository = DebtRepository();
  ProfileModel? _profile;
  List<DebtModel> _debts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _profileRepository.getProfile(widget.profileId),
        _debtRepository.getDebts(profileId: widget.profileId),
      ]);
      setState(() {
        _profile = results[0] as ProfileModel;
        _debts = results[1] as List<DebtModel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProfile() async {
    await _loadData();
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 삭제'),
        content: Text('${_profile?.name ?? ''}님의 프로필을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _profileRepository.deleteProfile(widget.profileId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('프로필이 삭제되었습니다')),
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _profile?.name ?? widget.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
            onPressed: _profile != null
                ? () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(profile: _profile!),
                      ),
                    );
                    if (result == true) {
                      _loadProfile();
                    }
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: _profile != null ? _showDeleteDialog : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 16),
                  if (_profile?.memo != null && _profile!.memo!.isNotEmpty)
                    _buildMemoSection(),
                  _buildTransactionSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              (_profile?.name ?? widget.name)[0],
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _profile?.name ?? widget.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            [_profile?.relation, _profile?.organization]
                .where((e) => e != null && e.isNotEmpty)
                .join(' · '),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          if (_profile?.phone != null && _profile!.phone!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _profile!.phone!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  '받을 돈',
                  '₩${_formatNumber(_profile?.totalLent ?? 0)}',
                  AppColors.primary,
                ),
                Container(width: 1, height: 40, color: AppColors.border),
                _buildSummaryItem(
                  '갚을 돈',
                  '₩${_formatNumber(_profile?.totalBorrowed ?? 0)}',
                  AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoSection() {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '메모',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _profile!.memo!,
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSection() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '거래 내역',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (_debts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  '거래 내역이 없습니다',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ..._debts.map((debt) => _buildDebtItem(debt)),
        ],
      ),
    );
  }

  Widget _buildDebtItem(DebtModel debt) {
    final date = '${debt.transactionDate.year}.${debt.transactionDate.month.toString().padLeft(2, '0')}.${debt.transactionDate.day.toString().padLeft(2, '0')}';
    
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => DebtDetailScreen(debtId: debt.id)),
        );
        if (result == true) {
          _loadData();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
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
                      const SizedBox(width: 8),
                      Text(date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  if (debt.memo != null) ...[
                    const SizedBox(height: 4),
                    Text(debt.memo!, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${debt.isLent ? '+' : '-'}₩${_formatNumber(debt.remainingAmount > 0 ? debt.remainingAmount : debt.amount)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: debt.isLent ? AppColors.primary : AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: debt.isSettled ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    debt.isSettled ? '정산완료' : '미정산',
                    style: TextStyle(
                      fontSize: 10,
                      color: debt.isSettled ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(amount, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
