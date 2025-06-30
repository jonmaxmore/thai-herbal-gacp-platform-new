/// ฟังก์ชันตรวจสอบความถูกต้องของข้อมูลฟอร์ม
library;

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'กรุณากรอกอีเมล';
  }
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailRegex.hasMatch(value.trim())) {
    return 'รูปแบบอีเมลไม่ถูกต้อง';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'กรุณากรอกรหัสผ่าน';
  }
  if (value.length < 6) {
    return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
  }
  return null;
}

String? validateNotEmpty(String? value, {String? fieldName}) {
  if (value == null || value.trim().isEmpty) {
    return 'กรุณากรอก${fieldName ?? "ข้อมูล"}';
  }
  return null;
}