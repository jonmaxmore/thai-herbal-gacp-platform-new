import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/navigation_provider.dart';

class BottomNavigation extends ConsumerWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final l10n = AppLocalizations.of(context)!;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => _onTabTapped(context, ref, index),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard_outlined),
          activeIcon: const Icon(Icons.dashboard),
          label: l10n.dashboard,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.camera_alt_outlined),
          activeIcon: const Icon(Icons.camera_alt),
          label: l10n.analysis,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.verified_outlined),
          activeIcon: const Icon(Icons.verified),
          label: l10n.certificates,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.qr_code_scanner_outlined),
          activeIcon: const Icon(Icons.qr_code_scanner),
          label: l10n.tracking,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: l10n.profile,
        ),
      ],
    );
  }

  void _onTabTapped(BuildContext context, WidgetRef ref, int index) {
    final currentIndex = ref.read(navigationIndexProvider);
    
    // Don't navigate if already on the same tab
    if (currentIndex == index) return;

    // Update navigation index
    ref.read(navigationIndexProvider.notifier).setIndex(index);

    // Navigate to the corresponding route
    switch (index) {
      # GACP Herbal AI Platform - Production-Ready Codebase

## 📱 Mobile App (Flutter) - Complete Implementation

### 🔧 Project Configuration

#### pubspec.yaml
```yaml
name: gacp_herbal_ai
description: GACP Herbal AI Platform for Mobile Devices
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  riverpod: ^2.4.9
  flutter_riverpod: ^2.4.9
  
  # Navigation
  go_router: ^12.1.3
  
  # HTTP & API
  dio: ^5.4.0
  retrofit: ^4.0.3
  json_annotation: ^4.8.1
  pretty_dio_logger: ^1.3.1
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # AI & ML
  tflite_flutter: ^0.10.4
  onnxruntime: ^1.16.0
  image: ^4.1.3
  
  # Camera & Image
  camera: ^0.10.5+5
  image_picker: ^1.0.4
  
  # QR Code
  qr_code_scanner: ^1.0.1
  qr_flutter: ^4.1.0
  
  # Permissions & Device
  permission_handler: ^11.1.0
  device_info_plus: ^9.1.1
  connectivity_plus: ^5.0.1
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  
  # File Handling
  path_provider: ^2.1.1
  file_picker: ^6.1.1
  
  # UI Components
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  lottie: ^2.7.0
  fl_chart: ^0.66.0
  
  # Utils
  uuid: ^4.2.1
  intl: ^0.18.1
  crypto: ^3.0.3
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_analytics: ^10.7.4
  firebase_crashlytics: ^3.4.8
  firebase_messaging: ^14.7.9
  
  # Notifications
  flutter_local_notifications: ^16.3.0
  
  # Biometrics
  local_auth: ^2.1.7

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  retrofit_generator: ^8.0.4
  hive_generator: ^2.0.1
  mockito: ^5.4.4
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  generate: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
    - assets/ai_models/
  
  fonts:
    - family: Sarabun
      fonts:
        - asset: assets/fonts/Sarabun-Regular.ttf
        - asset: assets/fonts/Sarabun-Medium.ttf
          weight: 500
        - asset: assets/fonts/Sarabun-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Sarabun-Bold.ttf
          weight: 700

flutter_intl:
  enabled: true
  main_locale: th
  arb_dir: lib/l10n
  output_dir: lib/generated