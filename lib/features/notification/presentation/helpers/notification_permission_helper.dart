import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jellomark/features/notification/presentation/widgets/notification_permission_dialog.dart';

/// 알림 권한이 아직 granted가 아니면 안내한다.
///
/// - `notDetermined`: iOS native prompt 호출 (한 번만 뜸)
/// - `denied` / `deniedForever`: 우리 안내 다이얼로그 (사용자가 명시적으로 설정 이동 선택 시에만 redirect)
/// - `authorized` / `provisional`: 아무 동작 X
///
/// 사용자가 명시적으로 한 액션(예: 예약 완료) 직후에만 호출해야 한다.
Future<void> promptForNotificationIfNeeded(BuildContext context) async {
  try {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      return;
    }

    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      await messaging.requestPermission();
      return;
    }

    if (!context.mounted) return;
    await NotificationPermissionDialog.show(context: context);
  } catch (_) {}
}
