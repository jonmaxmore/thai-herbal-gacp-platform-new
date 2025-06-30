import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/connectivity_provider.dart';
import '../../core/utils/app_constants.dart';
import '../providers/navigation_provider.dart';
import 'bottom_navigation.dart';
import 'connectivity_banner.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: Column(
        children: [
          // Connectivity banner (shows when offline)
          if (!connectivity.isConnected)
            const ConnectivityBanner(),
          
          // Main content
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(),
      
      // Floating Action Button for Camera (conditional)
      floatingActionButton: _shouldShowFAB(context) ? _buildCameraFAB(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  bool _shouldShowFAB(BuildContext context) {
    final location = GoRouterState.of(context).location;
    return location.startsWith('/analysis') || location == '/dashboard';
  }

  Widget _buildCameraFAB(BuildContext context) {
    return FloatingActionButton.large(
      onPressed: () => context.push('/analysis/camera'),
      tooltip: 'ถ่ายภาพวิเคราะห์',
      child: const Icon(
        Icons.camera_alt,
        size: 32,
      ),
    );
  }
}