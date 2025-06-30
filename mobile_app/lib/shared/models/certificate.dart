import 'package:json_annotation/json_annotation.dart';

part 'certificate.g.dart';

@JsonSerializable()
class Certificate {
  final String id;
  final String farmName;
  final String ownerName;
  final String status; // pending, approved, rejected, pre-approved, etc.
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final String? certificateUrl;
  final String? remark;
  final List<String>? attachedFiles;

  Certificate({
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

  factory Certificate.fromJson(Map<String, dynamic> json) =>
      _$CertificateFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateToJson(this);
}