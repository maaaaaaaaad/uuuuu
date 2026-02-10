import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:jellomark/core/notification/notification_handler.dart';
import 'package:jellomark/features/notification/domain/repositories/device_token_repository.dart';

class FcmService {
  final FirebaseMessaging _messaging;
  final DeviceTokenRepository _deviceTokenRepository;
  final NotificationHandler _notificationHandler;

  FcmService({
    required FirebaseMessaging messaging,
    required DeviceTokenRepository deviceTokenRepository,
    required NotificationHandler notificationHandler,
  })  : _messaging = messaging,
        _deviceTokenRepository = deviceTokenRepository,
        _notificationHandler = notificationHandler;

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _registerToken();
      _messaging.onTokenRefresh.listen(_onTokenRefresh);
    }

    _setupMessageHandlers();
    await _notificationHandler.handleInitialMessage();
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_notificationHandler.handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _notificationHandler.handleNotificationTap(message.data);
    });
  }

  Future<void> _registerToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      final platform = Platform.isIOS ? 'IOS' : 'ANDROID';
      await _deviceTokenRepository.registerToken(token, platform);
    }
  }

  void _onTokenRefresh(String token) {
    final platform = Platform.isIOS ? 'IOS' : 'ANDROID';
    _deviceTokenRepository.registerToken(token, platform);
  }

  Future<void> unregisterToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _deviceTokenRepository.unregisterToken(token);
    }
  }

  String get platform => Platform.isIOS ? 'IOS' : 'ANDROID';
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}
