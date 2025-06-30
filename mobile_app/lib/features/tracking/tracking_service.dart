import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final trackingServiceProvider = Provider<TrackingService>((ref) {
  return TrackingService._();
});

final trackingTimelineProvider = FutureProvider.family<List<TrackingEvent>, String>((ref, trackingId) async {
  final service = ref.read(trackingServiceProvider);
  return service.getTimeline(trackingId);
});

class TrackingService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com', // เปลี่ยนเป็น API จริง
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  TrackingService._();

  Future<List<TrackingEvent>> getTimeline(String trackingId) async {
    try {
      final response = await _dio.get('/tracking/$trackingId/timeline');
      final data = response.data;
      if (data is List) {
        return data.map((e) => TrackingEvent.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<TrackingEvent?> getTrackingByQr(String qrCode) async {
    try {
      final response = await _dio.get('/tracking/qr/$qrCode');
      if (response.data is Map<String, dynamic>) {
        return TrackingEvent.fromJson(response.data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

class TrackingEvent {
  final String id;
  final String stage;
  final String description;
  final DateTime timestamp;
  final String? location;
  final String? imageUrl;
  final String? signatureUrl;
  final double? latitude;
  final double? longitude;

  TrackingEvent({
    required this.id,
    required this.stage,
    required this.description,
    required this.timestamp,
    this.location,
    this.imageUrl,
    this.signatureUrl,
    this.latitude,
    this.longitude,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    return TrackingEvent(
      id: json['id'] ?? '',
      stage: json['stage'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      location: json['location'],
      imageUrl: json['image_url'],
      signatureUrl: json['signature_url'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}