import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'router.dart';
import 'theme.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/locale_provider.dart';
import '../core/providers/theme_provider.dart';
import '../core/providers/connectivity_provider.dart';
import '../core/utils/logger.dart';
import '../shared/widgets/connectivity_overlay.dart';
import '../shared/widgets/global_loading_overlay.dart';

class GACPHerbalApp extends ConsumerWidget {
  const GACPHerbalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final connectivity = ref.watch(connectivityProvider);
    
    return MaterialApp.router(
      // App Information
      title: 'GACP Herbal AI',
      debugShowCheckedModeBanner: false,
      
      // Routing
      routerConfig: router,
      
      // Theming
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // Localization
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Global Configuration
      builder: (context, child) {
        // Error handling for widget tree
        ErrorWidget.builder = (FlutterErrorDetails details) {
          AppLogger.error('Widget error', details.exception, details.stack);
          return _buildErrorWidget(details);
        };
        
        return MediaQuery(
          // Prevent system text scaling from affecting UI
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
          ),
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              
              // Global overlays
              if (!connectivity.isConnected) const ConnectivityOverlay(),
              const GlobalLoadingOverlay(),
            ],
          ),
        );
      },
      
      // Scroll behavior
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
    );
  }
  
  Widget _buildErrorWidget(FlutterErrorDetails details) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.red[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'เกิดข้อผิดพลาด',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'กรุณารีสตาร์ทแอป',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[700],
              ),
            ),
            if (AppConstants.isDebugMode) ...[
              const SizedBox(height: 16),
              Text(
                details.exception.toString(),
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}