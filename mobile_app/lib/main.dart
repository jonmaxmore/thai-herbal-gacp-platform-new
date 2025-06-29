import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app/app.dart';
import 'core/services/ai_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/permission_service.dart';
import 'core/utils/app_constants.dart';
import 'core/utils/logger.dart';
import 'firebase_options.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    // Preserve splash screen
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    // Initialize logging
    AppLogger.init();
    AppLogger.info('🚀 Starting GACP Herbal AI Platform...');

    try {
      await _initializeApp();
      
      // Run the app
      runApp(
        ProviderScope(
          observers: [RiverpodLogger()],
          child: const GACPHerbalApp(),
        ),
      );
      
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize app', e, stackTrace);
      _runErrorApp(e.toString());
    }
  }, (error, stack) {
    AppLogger.error('Uncaught error', error, stack);
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

Future<void> _initializeApp() async {
  try {
    // 1. Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Set up Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    
    AppLogger.info('✅ Firebase initialized');

    // 2. Hive Database
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(AppConstants.userDataBox);
    await Hive.openBox<dynamic>(AppConstants.cacheBox);
    await Hive.openBox<dynamic>(AppConstants.settingsBox);
    AppLogger.info('✅ Hive database initialized');

    // 3. System UI
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // 4. Request permissions
    await PermissionService.requestEssentialPermissions();
    AppLogger.info('✅ Permissions requested');

    // 5. Initialize services
    await Future.wait([
      AIService.initialize(),
      NotificationService.initialize(),
      AnalyticsService.initialize(),
    ]);
    
    AppLogger.info('✅ All services initialized');
    
    // Remove splash screen
    FlutterNativeSplash.remove();
    
  } catch (e, stackTrace) {
    AppLogger.error('App initialization failed', e, stackTrace);
    rethrow;
  }
}

void _runErrorApp(String error) {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'เกิดข้อผิดพลาดในการเริ่มต้นแอป',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: const Text('ปิดแอป'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class RiverpodLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (AppConstants.enableStateLogging) {
      AppLogger.debug(
        'Provider ${provider.name ?? provider.runtimeType} updated: $newValue'
      );
    }
  }
}