import 'package:app_manager/core/network/api_client.dart';
import 'package:app_manager/core/network/api_endpoints.dart';
import 'package:app_manager/features/auth/data/models/auth_models.dart';

abstract class IAuthRepository {
  Future<AuthResponse> login(String email, String password, String role);
  Future<AuthResponse> register(
    String name,
    String email,
    String password,
    String role,
  );
  Future<AuthResponse> verifyOtp(
    String email,
    String otp,
    String purpose,
    String role,
  );
  Future<AuthResponse> resendOtp(String email, String purpose);
  Future<AuthResponse> forgotPassword(String email);
  Future<AuthResponse> resetPassword(String resetToken, String newPassword);
  Future<AuthResponse> getCurrentUser();
}

class AuthRepository implements IAuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  @override
  Future<AuthResponse> login(String email, String password, String role) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password, 'role': role},
    );
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<AuthResponse> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.register,
      data: {'name': name, 'email': email, 'password': password, 'role': role},
    );
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<AuthResponse> verifyOtp(
    String email,
    String otp,
    String purpose,
    String role,
  ) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.verifyOtp,
      data: {'email': email, 'otp': otp, 'purpose': purpose, 'role': role},
    );
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<AuthResponse> resendOtp(String email, String purpose) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.resendOtp,
      data: {'email': email, 'purpose': purpose},
    );
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<AuthResponse> forgotPassword(String email) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<AuthResponse> resetPassword(
    String resetToken,
    String newPassword,
  ) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.resetPassword,
      data: {'resetToken': resetToken, 'newPassword': newPassword},
    );
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<AuthResponse> getCurrentUser() async {
    final response = await _apiClient.dio.get(ApiEndpoints.me);
    return AuthResponse.fromJson(response.data);
  }
}
