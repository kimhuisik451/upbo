import 'package:flutter/material.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';
import '../theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _relationController;
  late final TextEditingController _organizationController;
  late final TextEditingController _phoneController;
  late final TextEditingController _memoController;
  final _profileRepository = ProfileRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _relationController = TextEditingController(text: widget.profile.relation ?? '');
    _organizationController = TextEditingController(text: widget.profile.organization ?? '');
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _memoController = TextEditingController(text: widget.profile.memo ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    _organizationController.dispose();
    _phoneController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _profileRepository.updateProfile(
        widget.profile.id,
        name: _nameController.text.trim(),
        relation: _relationController.text.trim().isEmpty ? null : _relationController.text.trim(),
        organization: _organizationController.text.trim().isEmpty ? null : _organizationController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        memo: _memoController.text.trim().isEmpty ? null : _memoController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 수정되었습니다')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '프로필 수정',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    widget.profile.name[0],
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              _buildLabel('이름 *'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hintText: '이름을 입력하세요',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) return '이름을 입력해주세요';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              _buildLabel('관계'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _relationController,
                hintText: '친구, 동료, 가족 등',
                icon: Icons.people_outline,
              ),
              const SizedBox(height: 24),

              _buildLabel('학교/직장'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _organizationController,
                hintText: '학교 또는 직장명',
                icon: Icons.business_outlined,
              ),
              const SizedBox(height: 24),

              _buildLabel('전화번호'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _phoneController,
                hintText: '010-1234-5678',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              _buildLabel('메모'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _memoController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '간단한 메모를 입력하세요',
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _updateProfile,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle, size: 20),
                  label: Text(
                    _isLoading ? '저장 중...' : '저장하기',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: Icon(icon, color: AppColors.textHint),
      ),
    );
  }
}
