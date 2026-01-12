import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jellomark/config/env_config.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class AppConfig {
  static Future<void> initializeApp() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    KakaoSdk.init(nativeAppKey: EnvConfig.kakaoNativeAppKey);

    await initDependencies();
  }
}
