import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// 알림 권한이 미정(notDetermined)일 때만 iOS native prompt 한 번 호출.
///
/// - `notDetermined`: iOS native prompt (시스템 다이얼로그)
/// - `denied` / `deniedForever` / `authorized` / `provisional`: 아무 동작 X
///
/// 사용자가 명시적으로 한 액션(예약 완료) 직후에만 호출. 거부한 사용자의 결정은 존중한다.
Future<void> promptForNotificationIfNeeded(BuildContext context) async {
  try {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      await messaging.requestPermission();
    }
  } catch (_) {}
}
