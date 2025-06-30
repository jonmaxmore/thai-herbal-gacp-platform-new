import 'package:dio/dio.dart';

/// AuthService สำหรับ certificate module (standalone, ไม่ config กับไฟล์อื่น)
class CertificateAuthService {
  final Dio _dio;

  CertificateAuthService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.example.com', // เปลี่ยนเป็น production endpoint จริง
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  /// Login สำหรับ certificate module
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/certificate/auth/login',
        data: {'username': username, 'password': password},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['token'] != null) {
        return AuthResult.success(token: data['token']);
      }
      return AuthResult.failure(message: data['message'] ?? 'ไม่สามารถเข้าสู่ระบบ');
    } catch (e) {
      return AuthResult.failure(message: 'เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  /// ตรวจสอบ token
  Future<bool> validateToken(String token) async {
    try {
      final response = await _dio.get(
        '/certificate/auth/validate',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['valid'] == true;
    } catch (_) {
      return false;
    }
  }

  /// ออกจากระบบ
  Future<void> logout(String token) async {
    try {
      await _dio.post(
        '/certificate/auth/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (_) {
      // ignore error
    }
  }
}

/// ผลลัพธ์การเข้าสู่ระบบ
class AuthResult {
  final bool isSuccess;
  final String? token;
  final String? message;

  AuthResult._(this.isSuccess, {this.token, this.message});

  factory AuthResult.success({required String token}) =>
      AuthResult._(true, token: token);

  factory AuthResult.failure({required String message}) =>
      AuthResult._(false, message: message);
}
