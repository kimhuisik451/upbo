import 'package:flutter/material.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';
import '../theme/app_colors.dart';
import 'add_profile_screen.dart';
import 'profile_detail_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _profileRepository = ProfileRepository();
  List<ProfileModel> _profiles = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profiles = await _profileRepository.getProfiles();
      setState(() {
        _profiles = profiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          '친구',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined, color: AppColors.textPrimary),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProfileScreen()),
              );
              if (result == true) {
                _loadProfiles();
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('오류: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfiles,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            const Text(
              '등록된 친구가 없습니다',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProfileScreen()),
                );
                if (result == true) {
                  _loadProfiles();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('친구 추가'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfiles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _profiles.length,
        itemBuilder: (context, index) {
          final profile = _profiles[index];
          return _buildContactItem(context, profile);
        },
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, ProfileModel profile) {
    final totalDebt = profile.totalDebt;
    final isPositive = totalDebt >= 0;
    final hasTransactions = profile.totalLent > 0 || profile.totalBorrowed > 0;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileDetailScreen(
              profileId: profile.id,
              name: profile.name,
            ),
          ),
        );
        if (result == true) {
          _loadProfiles();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                profile.name[0],
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [profile.relation, profile.organization]
                        .where((e) => e != null && e.isNotEmpty)
                        .join(' · '),
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
                if (totalDebt != 0) ...[
                  Text(
                    '${isPositive ? '+' : ''}₩${_formatNumber(totalDebt.abs())}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isPositive ? AppColors.primary : AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isPositive ? '받을 돈' : '갚을 돈',
                    style: TextStyle(
                      fontSize: 11,
                      color: isPositive ? AppColors.primary : AppColors.error,
                    ),
                  ),
                ] else if (hasTransactions)
                  const Text(
                    '정산 완료',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  const Text(
                    '거래 없음',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
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
