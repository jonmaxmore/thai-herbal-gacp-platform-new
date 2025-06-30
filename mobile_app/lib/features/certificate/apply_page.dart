import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import 'certificate_service.dart';

final applyFormKey = GlobalKey<FormState>();

class ApplyCertificatePage extends ConsumerStatefulWidget {
  const ApplyCertificatePage({super.key});

  @override
  ConsumerState<ApplyCertificatePage> createState() => _ApplyCertificatePageState();
}

class _ApplyCertificatePageState extends ConsumerState<ApplyCertificatePage> {
  final _farmNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _handleSubmit() async {
    if (!applyFormKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final service = ref.read(certificateServiceProvider);
    final result = await service.applyCertificate(
      farmName: _farmNameController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      location: _locationController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _successMessage = result.message ?? 'ส่งคำขอสำเร็จ';
        _errorMessage = null;
      } else {
        _successMessage = null;
        _errorMessage = result.message ?? 'เกิดข้อผิดพลาด';
      }
    });

    if (result.isSuccess) {
      AppLogger.info('Certificate request submitted');
      // Navigator.of(context).pushReplacementNamed('/certificate-status');
    }
  }

  @override
  void dispose() {
    _farmNameController.dispose();
    _ownerNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ขอใบรับรอง GACP')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: applyFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _farmNameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อฟาร์ม',
                    prefixIcon: Icon(Icons.agriculture),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'กรุณากรอกชื่อฟาร์ม' : null,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ownerNameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อเจ้าของฟาร์ม',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'กรุณากรอกชื่อเจ้าของฟาร์ม' : null,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'ที่ตั้งฟาร์ม',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'กรุณากรอกที่ตั้งฟาร์ม' : null,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),
                if (_successMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('ส่งคำขอใบรับรอง'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}