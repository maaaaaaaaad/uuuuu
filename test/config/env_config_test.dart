import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/config/env_config.dart';

void main() {
  group('EnvConfig', () {
    test('should have env value', () {
      expect(EnvConfig.env, isNotNull);
      expect(EnvConfig.env, isNotEmpty);
    });

    test('should have apiBaseUrl value', () {
      expect(EnvConfig.apiBaseUrl, isNotNull);
      expect(EnvConfig.apiBaseUrl, isNotEmpty);
    });

    test('should have kakaoNativeAppKey defined', () {
      expect(EnvConfig.kakaoNativeAppKey, isNotNull);
    });

    test('isDebug should return true when env is dev', () {
      expect(EnvConfig.isDebug, EnvConfig.env == 'dev');
    });

    test('isProduction should return true when env is prod', () {
      expect(EnvConfig.isProduction, EnvConfig.env == 'prod');
    });

    test('isDebug and isProduction should be mutually exclusive', () {
      expect(EnvConfig.isDebug != EnvConfig.isProduction, isTrue);
    });
  });
}
