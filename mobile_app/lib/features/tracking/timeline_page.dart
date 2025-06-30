import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tracking_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TimelinePage extends ConsumerWidget {
  final String trackingId;
  const TimelinePage({super.key, required this.trackingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(trackingTimelineProvider(trackingId));

    return Scaffold(
      appBar: AppBar(title: const Text('ไทม์ไลน์การติดตาม')),
      body: timelineAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return const Center(child: Text('ไม่พบข้อมูลการติดตาม'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                child: ListTile(
                  leading: event.imageUrl != null
                      ? Image.network(event.imageUrl!, width: 48, height: 48, fit: BoxFit.cover)
                      : const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(event.stage),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.description),
                      if (event.location != null) Text('สถานที่: ${event.location!}'),
                      if (event.latitude != null && event.longitude != null)
                        Row(
                          children: [
                            Text('พิกัด: ${event.latitude}, ${event.longitude}'),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              icon: const Icon(Icons.map, size: 18),
                              label: const Text('ดูแผนที่'),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MapViewPage(
                                      latitude: event.latitude!,
                                      longitude: event.longitude!,
                                      title: event.stage,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      if (event.signatureUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Image.network(event.signatureUrl!, height: 32),
                        ),
                    ],
                  ),
                  trailing: Text(
                    '${event.timestamp.day}/${event.timestamp.month}/${event.timestamp.year}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('เกิดข้อผิดพลาด: $e')),
      ),
    );
  }
}

class MapViewPage extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String title;

  const MapViewPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng position = LatLng(latitude, longitude);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: position, zoom: 16),
        markers: {
          Marker(
            markerId: const MarkerId('event_location'),
            position: position,
            infoWindow: InfoWindow(title: title),
          ),
        },
      ),
    );
  }
}