import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';

final notificationServicesProvider = Provider<NotificationServices>((ref) {
  return NotificationServices._();
});

class NotificationServices {
  static final _local = FlutterLocalNotificationsPlugin();
  static final _firebase = FirebaseMessaging.instance;

  NotificationServices._();

  Future<void> initialize(BuildContext context) async {
    try {
      await _initLocalNotifications();
      await _initFirebaseMessaging(context);
      AppLogger.info('NotificationServices initialized');
    } catch (e, s) {
      AppLogger.error('NotificationServices init failed', e, s);
    }
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        AppLogger.info('Local notification tapped: ${details.payload}');
        // TODO: Handle navigation or deep link here if needed
      },
    );
  }

  Future<void> _initFirebaseMessaging(BuildContext context) async {
    if (Platform.isIOS) {
      await _firebase.requestPermission(alert: true, badge: true, sound: true);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info('Push received (foreground): ${message.notification?.title}');
      _showLocalNotification(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        AppLogger.info('Push opened from terminated: ${message.data}');
        // TODO: Handle navigation or deep link here if needed
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('Push opened from background: ${message.data}');
      // TODO: Handle navigation or deep link here if needed
    });
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const android = AndroidNotificationDetails(
      'gacp_channel',
      'GACP Notifications',
      channelDescription: 'แจ้งเตือนจากระบบ GACP Herbal AI',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);

    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      await showLocalNotification(
        title: notification.title ?? 'แจ้งเตือน',
        body: notification.body ?? '',
        payload: message.data['payload'],
      );
    }
  }

  Future<String?> getFcmToken() async {
    try {
      final token = await _firebase.getToken();
      AppLogger.info('FCM Token: $token');
      return token;
    } catch (e, s) {
      AppLogger.error('Get FCM token failed', e, s);
      return null;
    }
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await _firebase.requestPermission(alert: true, badge: true, sound: true);
    }
  }

  Future<void> cancelAllNotifications() async {
    await _local.cancelAll();
    AppLogger.info('All local notifications cancelled');
  }
}