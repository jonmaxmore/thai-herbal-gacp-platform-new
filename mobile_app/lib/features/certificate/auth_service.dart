import 'package:dio/dio.dart';
import 'package:gacp_core/core/utils/logger.dart';

/// Production-ready AuthService for certificate module
class CertificateAuthService {
  final Dio _dio;

  CertificateAuthService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.gacp-platform.com', // Production endpoint
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Content-Type': 'application/json'},
            )) {
    // Add interceptors for production
    _dio.interceptors.add(LogInterceptor(
      request: true,
      responseBody: true,
      requestBody: true,
      error: true,
    ));
  }

  /// Login for certificate module
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/certificate/auth/login',
        data: {'username': username, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      if (data['token'] != null) {
        AppLogger.info('User $username logged in successfully');
        return AuthResult.success(token: data['token']);
      }
      return AuthResult.failure(
          message: data['message'] ?? 'ไม่สามารถเข้าสู่ระบบได้');
    } on DioException catch (e) {
      AppLogger.error('Login failed for $username', e);
      return AuthResult.failure(
          message: _handleDioError(e) ?? 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ');
    } catch (e) {
      AppLogger.error('Unexpected login error', e);
      return AuthResult.failure(message: 'เกิดข้อผิดพลาดที่ไม่คาดคิด');
    }
  }

  /// Validate token
  Future<bool> validateToken(String token) async {
    try {
      final response = await _dio.get(
        '/api/certificate/auth/validate',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['valid'] == true;
    } on DioException catch (e) {
      AppLogger.warning('Token validation failed', e);
      return false;
    }
  }

  /// Logout
  Future<bool> logout(String token) async {
    try {
      await _dio.post(
        '/api/certificate/auth/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      AppLogger.info('User logged out successfully');
      return true;
    } on DioException catch (e) {
      AppLogger.error('Logout failed', e);
      return false;
    }
  }

  /// Handle Dio errors
  String? _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data as Map<String, dynamic>?;
      return data?['message'] as String?;
    }
    return 'เชื่อมต่อเซิร์ฟเวอร์ล้มเหลว';
  }
}

/// Authentication result model
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