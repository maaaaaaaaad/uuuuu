import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:jellomark/config/env_config.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/core/notification/fcm_service.dart';
import 'package:jellomark/core/notification/local_notification_service.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AppConfig {
  static Future<void> initializeApp() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: SemanticColors.special.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    try {
      await Firebase.initializeApp()
          .timeout(const Duration(seconds: 10));
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (_) {}

    try {
      KakaoSdk.init(nativeAppKey: EnvConfig.kakaoNativeAppKey);
    } catch (_) {}

    try {
      await FlutterNaverMap()
          .init(clientId: EnvConfig.naverMapClientId)
          .timeout(const Duration(seconds: 5));
    } catch (_) {}

    await initDependencies();

    try {
      await sl<LocalNotificationService>().initialize()
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }
}
