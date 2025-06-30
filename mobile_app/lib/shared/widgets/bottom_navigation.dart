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
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        case 2:
        case 3:
        case 4:
        default:
        context.go('/dashboard');
    }
  }
}