import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'certificate_service.dart';

class CertificateStatusPage extends ConsumerWidget {
  const CertificateStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(certificateStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('สถานะใบรับรอง')),
      body: statusAsync.when(
        data: (statusList) {
          if (statusList.isEmpty) {
            return const Center(child: Text('ยังไม่มีคำขอใบรับรอง'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: statusList.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final status = statusList[index];
              return ListTile(
                leading: Icon(
                  status.status == 'approved'
                      ? Icons.verified
                      : status.status == 'pending'
                          ? Icons.hourglass_top
                          : Icons.cancel,
                  color: status.status == 'approved'
                      ? Colors.green
                      : status.status == 'pending'
                          ? Colors.orange
                          : Colors.red,
                ),
                title: Text(status.farmName),
                subtitle: Text('สถานะ: ${status.statusTh}'),
                trailing: Text(status.updatedAtString),
                onTap: () {
                  // สามารถแสดงรายละเอียดเพิ่มเติมได้
                },
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