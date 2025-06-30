import 'package:intl/intl.dart';

/// ฟังก์ชันช่วยเหลือทั่วไปที่ใช้ซ้ำในหลายจุด

String formatDate(DateTime? date, {String pattern = 'dd/MM/yyyy'}) {
  if (date == null) return '-';
  return DateFormat(pattern).format(date);
}

String formatDateTime(DateTime? date, {String pattern = 'dd/MM/yyyy HH:mm'}) {
  if (date == null) return '-';
  return DateFormat(pattern).format(date);
}

String? maskEmail(String? email) {
  if (email == null || !email.contains('@')) return email;
  final parts = email.split('@');
  if (parts[0].length <= 2) return email;
  final masked = parts[0][0] + '*' * (parts[0].length - 2) + parts[0].substring(parts[0].length - 1);
  return '$masked@${parts[1]}';
}