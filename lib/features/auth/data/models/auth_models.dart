enum AccountType { personal, garage }

class AuthUser {
  final int id;
  final String name;
  final String email;
  final bool isVerified;
  final String role;
  final String? createdAt;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.isVerified,
    required this.role,
    this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      isVerified: json['isVerified'] as bool,
      role: json['role'] as String,
      createdAt: json['createdAt'] as String?,
    );
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final String? resetToken;
  final AuthUser? user;
  final String? email;
  final String? code;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.resetToken,
    this.user,
    this.email,
    this.code,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      token: json['token'] as String?,
      resetToken: json['resetToken'] as String?,
      user: json['user'] != null ? AuthUser.fromJson(json['user']) : null,
      email: json['email'] as String?,
      code: json['code'] as String?,
    );
  }
}

class RegisterFormData {
  const RegisterFormData({
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.name = '',
    this.role = 'ADMIN',
  });

  final String email;
  final String password;
  final String confirmPassword;
  final String name;
  final String role;
}
