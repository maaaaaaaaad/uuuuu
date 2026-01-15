import 'package:flutter/services.dart';
import 'package:jellomark/config/env_config.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

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

    KakaoSdk.init(nativeAppKey: EnvConfig.kakaoNativeAppKey);

    await initDependencies();
  }
}
