import 'dart:io';

import 'package:dio/dio.dart';

class CloudinaryUploadService {
  CloudinaryUploadService._();

  static const String _cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
  );
  static const String _uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
  );

  static bool get isConfigured =>
      _cloudName.trim().isNotEmpty && _uploadPreset.trim().isNotEmpty;

  static Future<String> uploadImage(File file) async {
    if (!isConfigured) {
      throw Exception(
        'Cloudinary chưa cấu hình. Thiếu CLOUDINARY_CLOUD_NAME hoặc CLOUDINARY_UPLOAD_PRESET.',
      );
    }
    final dio = Dio();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'upload_preset': _uploadPreset,
      'folder': 'admin_uploads',
    });
    final response = await dio.post<Map<String, dynamic>>(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      data: formData,
    );
    final secureUrl = response.data?['secure_url']?.toString();
    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Upload Cloudinary thất bại, không nhận được URL ảnh.');
    }
    return secureUrl;
  }
}
