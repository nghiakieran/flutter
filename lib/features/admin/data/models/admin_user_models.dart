class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isVerified,
    this.phone,
    this.createdAt,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final bool isVerified;
  final String? phone;
  final DateTime? createdAt;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'USER',
      isVerified: json['isVerified'] == true,
      phone: json['phone']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class AdminUserPage {
  const AdminUserPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<AdminUser> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
}
