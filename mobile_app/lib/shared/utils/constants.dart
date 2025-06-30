/// ค่าคงที่ที่ใช้ทั่วทั้งแอป
class AppConstants {
  // API
  static const String apiBaseUrl = 'https://api.example.com'; // เปลี่ยนเป็น production endpoint จริง

  // Route names
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String dashboardRoute = '/dashboard';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String certificateApplyRoute = '/certificate/apply';
  static const String certificateStatusRoute = '/certificate/status';
  static const String trackingTimelineRoute = '/tracking/timeline';
  static const String qrScannerRoute = '/tracking/qr-scanner';

  // GACP
  static const String gacpCertificateName = 'GACP Certificate';

  // UI
  static const double defaultPadding = 16.0;
  static const double borderRadius = 12.0;

  // Others
  static const int requestTimeoutSeconds = 10;
}