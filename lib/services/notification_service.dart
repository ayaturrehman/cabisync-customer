import 'api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final ApiService _apiService;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  NotificationService(this._apiService);

  Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Notification permission granted');
      
      final fcmToken = await _messaging.getToken();
      if (fcmToken != null) {
        await registerFCMToken(fcmToken);
      }

      _messaging.onTokenRefresh.listen((newToken) {
        registerFCMToken(newToken);
      });

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    } else {
      print('❌ Notification permission denied');
    }
  }

  Future<void> registerFCMToken(String token) async {
    try {
      await _apiService.post(
        '/fcm-token',
        data: {
          'fcm_token': token,
          'device_type': _getDeviceType(),
        },
      );
      print('✅ FCM token registered: $token');
    } catch (e) {
      print('❌ Failed to register FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('📨 Foreground notification received');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('📱 Notification opened app');
    print('Data: ${message.data}');
  }

  String _getDeviceType() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'android';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ios';
    }
    return 'unknown';
  }
}

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
