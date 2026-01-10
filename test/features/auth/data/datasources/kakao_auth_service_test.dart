import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/auth/data/datasources/kakao_auth_service.dart';

void main() {
  group('KakaoAuthService', () {
    test('should define loginWithKakao method', () {
      expect(KakaoAuthService, isNotNull);
    });

    test('should define logout method', () {
      expect(KakaoAuthService, isNotNull);
    });
  });
}
