import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/app_constants.dart';
import '../../core/services/secure_storage_service.dart';
import 'auth_models.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService._(ref.read);
});

class AuthService {
  final Reader _read;
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  AuthService._(this._read);

  /// Login with email and password
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: jsonEncode({'email': email, 'password': password}),
      );
      final data = response.data is String ? jsonDecode(response.data) : response.data;
      final token = data['token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      if (token != null) {
        await _read(secureStorageServiceProvider).writeToken(token);
        if (refreshToken != null) {
          await _read(secureStorageServiceProvider).writeRefreshToken(refreshToken);
        }
        AppLogger.info('Login success');
        return AuthResult.success(token: token);
      }
      final message = data['message'] as String? ?? 'Token not found';
      return AuthResult.failure(message: message);
    } catch (e, s) {
      AppLogger.error('Login failed', e, s);
      return AuthResult.failure(message: 'เข้าสู่ระบบล้มเหลว (${e.runtimeType})');
    }
  }

  /// Register new user
  Future<AuthResult> register(String email, String password, String name) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: jsonEncode({'email': email, 'password': password, 'name': name}),
      );
      final data = response.data is String ? jsonDecode(response.data) : response.data;
      final token = data['token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      if (token != null && token.isNotEmpty) {
        await _read(secureStorageServiceProvider).writeToken(token);
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await _read(secureStorageServiceProvider).writeRefreshToken(refreshToken);
        }
        AppLogger.info('Register success');
        return AuthResult.success(token: token);
      }
      final message = data['message'] as String? ?? 'ไม่พบ token';
      return AuthResult.failure(message: message);
    } catch (e, s) {
      AppLogger.error('Register failed', e, s);
      return AuthResult.failure(message: 'สมัครสมาชิกล้มเหลว (${e.runtimeType})');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _read(secureStorageServiceProvider).deleteToken();
      await _read(secureStorageServiceProvider).deleteRefreshToken();
      AppLogger.info('Logout success');
    } catch (e, s) {
      AppLogger.error('Logout failed', e, s);
    }
  }

  /// Get current user profile
  Future<UserProfile?> getProfile() async {
    try {
      final token = await _read(secureStorageServiceProvider).readToken();
      if (token == null) return null;
      final response = await _dio.get(
        '/auth/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data is Map<String, dynamic>) {
        return UserProfile.fromJson(response.data);
      }
      return null;
    } catch (e, s) {
      AppLogger.error('Get profile failed', e, s);
      return null;
    }
  }

  /// Forgot password - ส่งอีเมลสำหรับรีเซ็ตรหัสผ่าน
  Future<AuthResult> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: jsonEncode({'email': email}),
      );
      final data = response.data is String ? jsonDecode(response.data) : response.data;
      final message = data['message'] as String? ?? 'กรุณาตรวจสอบอีเมลของคุณ';
      AppLogger.info('Forgot password: $message');
      return AuthResult.success(token: null, message: message);
    } on DioException catch (e, s) {
      final msg = e.response?.data['message'] ?? 'ไม่สามารถส่งอีเมลรีเซ็ตรหัสผ่าน';
      AppLogger.error('Forgot password failed', e, s);
      return AuthResult.failure(message: msg);
    } catch (e, s) {
      AppLogger.error('Forgot password failed', e, s);
      return AuthResult.failure(message: 'เกิดข้อผิดพลาด');
    }
  }

  /// Verify email - ยืนยันอีเมลด้วยโค้ด
  Future<AuthResult> verifyEmail({required String email, required String code}) async {
    try {
      final response = await _dio.post(
        '/auth/verify-email',
        data: jsonEncode({'email': email, 'code': code}),
      );
      final data = response.data is String ? jsonDecode(response.data) : response.data;
      final message = data['message'] as String? ?? 'ยืนยันอีเมลสำเร็จ';
      AppLogger.info('Verify email: $message');
      return AuthResult.success(token: null, message: message);
    } on DioException catch (e, s) {
      final msg = e.response?.data['message'] ?? 'ไม่สามารถยืนยันอีเมล';
      AppLogger.error('Verify email failed', e, s);
      return AuthResult.failure(message: msg);
    } catch (e, s) {
      AppLogger.error('Verify email failed', e, s);
      return AuthResult.failure(message: 'เกิดข้อผิดพลาด');
    }
  }

  /// Refresh token - ขอ access token ใหม่ด้วย refresh token
  Future<AuthResult> refreshToken() async {
    try {
      final refreshToken = await _read(secureStorageServiceProvider).readRefreshToken();
      if (refreshToken == null) {
        return AuthResult.failure(message: 'ไม่พบ refresh token');
      }
      final response = await _dio.post(
        '/auth/refresh-token',
        data: jsonEncode({'refresh_token': refreshToken}),
      );
      final data = response.data is String ? jsonDecode(response.data) : response.data;
      final newToken = data['token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;
      if (newToken != null && newToken.isNotEmpty) {
        await _read(secureStorageServiceProvider).writeToken(newToken);
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await _read(secureStorageServiceProvider).writeRefreshToken(newRefreshToken);
        }
        AppLogger.info('Refresh token success');
        return AuthResult.success(token: newToken);
      }
      final message = data['message'] as String? ?? 'Refresh token failed';
      return AuthResult.failure(message: message);
    } on DioException catch (e, s) {
      final msg = e.response?.data['message'] ?? 'ไม่สามารถรีเฟรช token';
      AppLogger.error('Refresh token failed', e, s);
      return AuthResult.failure(message: msg);
    } catch (e, s) {
      AppLogger.error('Refresh token failed', e, s);
      return AuthResult.failure(message: 'เกิดข้อผิดพลาด');
    }
  }
}

/// AuthResult model
class AuthResult {
  final bool isSuccess;
  final String? token;
  final String? message;

  AuthResult._(this.isSuccess, {this.token, this.message});

  factory AuthResult.success({String? token, String? message}) =>
      AuthResult._(true, token: token, message: message);

  factory AuthResult.failure({required String message}) =>
      AuthResult._(false, message: message);
}