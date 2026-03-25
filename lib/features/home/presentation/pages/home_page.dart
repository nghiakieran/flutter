import 'package:flutter/material.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/shared/widgets/error-empty/empty_state_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Ứng dụng'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EmptyStateWidget(
            icon: Icons.verified_user_outlined,
            title: 'Bạn đã đăng nhập',
            message:
                'Xem trước giao diện. Hãy kết nối logic JWT/phiên đăng nhập để thay thế màn Home mẫu này.',
            action: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
