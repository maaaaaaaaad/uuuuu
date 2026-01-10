import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';

void main() {
  group('TokenPair', () {
    test('should create TokenPair with accessToken and refreshToken', () {
      final tokenPair = TokenPair(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
      );

      expect(tokenPair.accessToken, 'access_token_123');
      expect(tokenPair.refreshToken, 'refresh_token_456');
    });

    test('should support value equality', () {
      final tokenPair1 = TokenPair(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
      );

      final tokenPair2 = TokenPair(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
      );

      expect(tokenPair1, equals(tokenPair2));
    });

    test('should be different when tokens differ', () {
      final tokenPair1 = TokenPair(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
      );

      final tokenPair2 = TokenPair(
        accessToken: 'different_access',
        refreshToken: 'different_refresh',
      );

      expect(tokenPair1, isNot(equals(tokenPair2)));
    });
  });
}
