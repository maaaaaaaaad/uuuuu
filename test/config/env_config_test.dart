import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/config/env_config.dart';

void main() {
  group('EnvConfig', () {
    group('development', () {
      test('should have development environment name', () {
        expect(EnvConfig.development.name, 'development');
      });

      test('should have development API base URL', () {
        expect(EnvConfig.development.apiBaseUrl, 'http://localhost:8080');
      });

      test('should be in debug mode', () {
        expect(EnvConfig.development.isDebug, isTrue);
      });
    });

    group('production', () {
      test('should have production environment name', () {
        expect(EnvConfig.production.name, 'production');
      });

      test('should have production API base URL', () {
        expect(EnvConfig.production.apiBaseUrl, isNotEmpty);
      });

      test('should not be in debug mode', () {
        expect(EnvConfig.production.isDebug, isFalse);
      });
    });

    group('current', () {
      test('should return valid environment', () {
        final current = EnvConfig.current;

        expect(current, isNotNull);
        expect(current.name, isNotEmpty);
        expect(current.apiBaseUrl, isNotEmpty);
      });
    });
  });
}
