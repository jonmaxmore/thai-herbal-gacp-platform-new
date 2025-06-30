import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final certificateServiceProvider = Provider<CertificateService>((ref) {
  return CertificateService._();
});

final certificateStatusProvider = FutureProvider<List<CertificateStatus>>((ref) async {
  final service = ref.read(certificateServiceProvider);
  return service.getCertificateStatus();
});

class CertificateService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com', // เปลี่ยนเป็น production endpoint จริง
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  CertificateService._();

  Future<CertificateApplyResult> applyCertificate({
    required String farmName,
    required String ownerName,
    required String location,
    List<String>? attachedFiles,
    String? remark,
  }) async {
    try {
      final response = await _dio.post(
        '/certificates/apply',
        data: {
          'farm_name': farmName,
          'owner_name': ownerName,
          'location': location,
          if (attachedFiles != null) 'attached_files': attachedFiles,
          if (remark != null) 'remark': remark,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        return CertificateApplyResult(isSuccess: true, message: data['message']);
      }
      return CertificateApplyResult(isSuccess: false, message: data['message'] ?? 'เกิดข้อผิดพลาด');
    } catch (e) {
      return CertificateApplyResult(isSuccess: false, message: 'เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  Future<List<CertificateStatus>> getCertificateStatus() async {
    try {
      final response = await _dio.get('/certificates/status');
      final data = response.data;
      if (data is List) {
        return data.map((e) => CertificateStatus.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<CertificateDetail?> getCertificateDetail(String certificateId) async {
    try {
      final response = await _dio.get('/certificates/$certificateId');
      if (response.data is Map<String, dynamic>) {
        return CertificateDetail.fromJson(response.data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

class CertificateApplyResult {
  final bool isSuccess;
  final String? message;
  CertificateApplyResult({required this.isSuccess, this.message});
}

class CertificateStatus {
  final String id;
  final String farmName;
  final String status;
  final String statusTh;
  final DateTime updatedAt;

  CertificateStatus({
    required this.id,
    required this.farmName,
    required this.status,
    required this.statusTh,
    required this.updatedAt,
  });

  factory CertificateStatus.fromJson(Map<String, dynamic> json) {
    return CertificateStatus(
      id: json['id'] ?? '',
      farmName: json['farm_name'] ?? '',
      status: json['status'] ?? '',
      statusTh: _statusTh(json['status']),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  static String _statusTh(String? status) {
    switch (status) {
      case 'approved':
        return 'อนุมัติแล้ว';
      case 'pending':
        return 'รอดำเนินการ';
      case 'rejected':
        return 'ไม่อนุมัติ';
      case 'pre-approved':
        return 'ผ่านการประเมินเบื้องต้น';
      default:
        return 'ไม่ทราบสถานะ';
    }
  }

  String get updatedAtString =>
      '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
}

class CertificateDetail {
  final String id;
  final String farmName;
  final String ownerName;
  final String status;
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final String? certificateUrl;
  final String? remark;
  final List<String>? attachedFiles;

  CertificateDetail({
    required this.id,
    required this.farmName,
    required this.ownerName,
    required this.status,
    required this.requestedAt,
    this.approvedAt,
    this.certificateUrl,
    this.remark,
    this.attachedFiles,
  });

  factory CertificateDetail.fromJson(Map<String, dynamic> json) {
    return CertificateDetail(
      id: json['id'] ?? '',
      farmName: json['farm_name'] ?? '',
      ownerName: json['owner_name'] ?? '',
      status: json['status'] ?? '',
      requestedAt: DateTime.tryParse(json['requested_at'] ?? '') ?? DateTime.now(),
      approvedAt: json['approved_at'] != null ? DateTime.tryParse(json['approved_at']) : null,
      certificateUrl: json['certificate_url'],
      remark: json['remark'],
      attachedFiles: (json['attached_files'] as List?)?.map((e) => e.toString()).toList(),
    );
  }