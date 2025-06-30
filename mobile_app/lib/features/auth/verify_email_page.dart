import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/app_constants.dart';
import 'auth_service.dart';

final verifyEmailFormKey = GlobalKey<FormState>();

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _infoMessage;
  String? _errorMessage;

  Future<void> _handleVerifyEmail() async {
    if (!verifyEmailFormKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _infoMessage = null;
      _errorMessage = null;
    });

    final authService = ref.read(authServiceProvider);
    final result = await authService.verifyEmail(
      email: _emailController.text.trim(),
      code: _codeController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _infoMessage = result.message ?? 'ยืนยันอีเมลสำเร็จ';
        _errorMessage = null;
      } else {
        _infoMessage = null;
        _errorMessage = result.message ?? 'เกิดข้อผิดพลาด';
      }
    });

    if (result.isSuccess) {
      AppLogger.info('Verify email success');
      // สามารถนำทางไปหน้า login หรือ dashboard ได้
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ยืนยันอีเมล')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: verifyEmailFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'อีเมล',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกอีเมล';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'รูปแบบอีเมลไม่ถูกต้อง';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'รหัสยืนยัน',
                    prefixIcon: Icon(Icons.verified),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัสยืนยัน';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),
                if (_infoMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _infoMessage!,
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
                    onPressed: _isLoading ? null : _handleVerifyEmail,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('ยืนยันอีเมล'),
                  ),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
                        },
                  child: const Text('กลับสู่หน้าล็อกอิน'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}