import 'package:flutter/material.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/features/admin/shared/presentation/widgets/admin_page_app_bar.dart';
import 'package:app_manager/features/auth/data/repositories/auth_repository.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _isLoading = true;
  String? _error;
  String _name = '';
  String _email = '';
  String _role = 'ADMIN';
  String _verified = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await getIt<IAuthRepository>().getCurrentUser();
      if (!mounted) {
        return;
      }
      if (res.success && res.user != null) {
        setState(() {
          _name = res.user!.name;
          _email = res.user!.email;
          _role = res.user!.role;
          _verified = res.user!.isVerified ? 'Đã xác thực' : 'Chưa xác thực';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = res.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Không thể tải hồ sơ quản trị.';
        _isLoading = false;
      });
    }
  }

  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AdminPageAppBar(
        title: 'Hồ sơ quản trị',
        subtitle: 'Thông tin tài khoản và quyền truy cập',
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isLoading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ] else ...[
              _infoTile('Họ tên', _name),
              _infoTile('Email', _email),
              _infoTile('Vai trò', _role),
              _infoTile('Trạng thái', _verified),
            ],
          ],
        ),
      ),
    );
  }
}
