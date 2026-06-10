import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/auth/data/datasources/apple_auth_service.dart';

void main() {
  group('AppleSignInResult', () {
    test('should hold identityToken and optional fullName', () {
      const result = AppleSignInResult(
        identityToken: 'token-abc',
        fullName: 'Yu Seungbum',
      );

      expect(result.identityToken, 'token-abc');
      expect(result.fullName, 'Yu Seungbum');
    });

    test('should default fullName to null', () {
      const result = AppleSignInResult(identityToken: 'token-xyz');

      expect(result.identityToken, 'token-xyz');
      expect(result.fullName, isNull);
    });
  });

  group('AppleAuthServiceImpl', () {
    test('AppleAuthServiceImpl conforms to AppleAuthService contract', () {
      final service = AppleAuthServiceImpl();
      expect(service, isA<AppleAuthService>());
    });
  });
}
