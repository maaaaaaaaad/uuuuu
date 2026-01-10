import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/auth/data/models/token_pair_model.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';

void main() {
  group('TokenPairModel', () {
    test('should be a subclass of TokenPair entity', () {
      const model = TokenPairModel(
        accessToken: 'access',
        refreshToken: 'refresh',
      );

      expect(model, isA<TokenPair>());
    });

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        final json = {
          'accessToken': 'access_token_123',
          'refreshToken': 'refresh_token_456',
        };

        final result = TokenPairModel.fromJson(json);

        expect(result.accessToken, 'access_token_123');
        expect(result.refreshToken, 'refresh_token_456');
      });
    });

    group('toJson', () {
      test('should return a valid JSON map', () {
        const model = TokenPairModel(
          accessToken: 'access_token_123',
          refreshToken: 'refresh_token_456',
        );

        final result = model.toJson();

        expect(result['accessToken'], 'access_token_123');
        expect(result['refreshToken'], 'refresh_token_456');
      });
    });
  });
}
