import 'package:validators/validators.dart' as v;

/// Production-ready validators for forms and business logic.
class AppValidators {
  static String? required(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? 'กรุณากรอกข้อมูล';
    }
    return null;
  }

  static String? email(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) return null;
    if (!v.isEmail(value.trim())) {
      return message ?? 'อีเมลไม่ถูกต้อง';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 8, String? message}) {
    if (value == null || value.isEmpty) return null;
    final hasUpper = value.contains(RegExp(r'[A-Z]'));
    final hasLower = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'\d'));
    final hasSpecial = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    if (value.length < minLength || !hasUpper || !hasLower || !hasDigit || !hasSpecial) {
      return message ?? 'รหัสผ่านต้องมีอย่างน้อย $minLength ตัว อักษรใหญ่ เล็ก ตัวเลข และอักขระพิเศษ';
    }
    return null;
  }

  static String? phone(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) return null;
    final pattern = RegExp(r'^(?:\+66|0)\d{8,9}$');
    if (!pattern.hasMatch(value.trim())) {
      return message ?? 'เบอร์โทรศัพท์ไม่ถูกต้อง';
    }
    return null;
  }

  static String? thaiId(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) return null;
    final id = value.replaceAll('-', '');
    if (!RegExp(r'^\d{13}$').hasMatch(id)) {
      return message ?? 'เลขบัตรประชาชนไม่ถูกต้อง';
    }
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(id[i]) * (13 - i);
    }
    final int check = (11 - (sum % 11)) % 10;
    if (check != int.parse(id[12])) {
      return message ?? 'เลขบัตรประชาชนไม่ถูกต้อง';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String? message}) {
    if (value == null || value.length < min) {
      return message ?? 'ต้องมีอย่างน้อย $min ตัวอักษร';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String? message}) {
    if (value != null && value.length > max) {
      return message ?? 'ต้องไม่เกิน $max ตัวอักษร';
    }
    return null;
  }

  static String? match(String? value, String? other, {String? message}) {
    if (value != other) {
      return message ?? 'ข้อมูลไม่ตรงกัน';
    }
    return null;
  }

  static String? url(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) return null;
    if (!v.isURL(value.trim())) {
      return message ?? 'URL ไม่ถูกต้อง';
    }
    return null;
  }

  static String? number(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) return null;
    if (!v.isNumeric(value.trim())) {
      return message ?? 'กรุณากรอกตัวเลข';
    }
    return null;
  }

  static String? date(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) return null;
    if (!v.isDate(value)) {
      return message ?? 'รูปแบบวันที่ไม่ถูกต้อง (YYYY-MM-DD)';
    }
    return null;
  }

  static String? afterDate(String? value, String? reference, {String? message}) {
    if (value == null || reference == null) return null;
    final valueDate = DateTime.tryParse(value);
    final referenceDate = DateTime.tryParse(reference);
    if (valueDate == null || referenceDate == null) return null;
    if (!valueDate.isAfter(referenceDate)) {
      return message ?? 'ต้องเป็นวันที่หลังจาก ${referenceDate.toLocal()}';
    }
    return null;
  }
}