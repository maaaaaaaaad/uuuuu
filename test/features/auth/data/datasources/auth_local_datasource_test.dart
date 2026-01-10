import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/storage/secure_token_storage.dart';
import 'package:jellomark/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:jellomark/features/auth/data/models/token_pair_model.dart';

class MockSecureStorage implements SecureStorageWrapper {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value != null) {
      _storage[key] = value;
    } else {
      _storage.remove(key);
    }
  }

  @override
  Future<String?> read({required String key}) async => _storage[key];

  @override
  Future<void> delete({required String key}) async => _storage.remove(key);

  @override
  Future<void> deleteAll() async => _storage.clear();
}

void main() {
  group('AuthLocalDataSource', () {
    late AuthLocalDataSource dataSource;
    late MockSecureStorage mockStorage;

    setUp(() {
      mockStorage = MockSecureStorage();
      dataSource = AuthLocalDataSourceImpl(secureStorage: mockStorage);
    });

    group('saveTokens', () {
      test('should save access and refresh tokens', () async {
        const tokenPair = TokenPairModel(
          accessToken: 'access_123',
          refreshToken: 'refresh_456',
        );

        await dataSource.saveTokens(tokenPair);

        final accessToken = await mockStorage.read(key: 'access_token');
        final refreshToken = await mockStorage.read(key: 'refresh_token');
        expect(accessToken, 'access_123');
        expect(refreshToken, 'refresh_456');
      });
    });

    group('getTokens', () {
      test('should return TokenPairModel when tokens exist', () async {
        await mockStorage.write(key: 'access_token', value: 'stored_access');
        await mockStorage.write(key: 'refresh_token', value: 'stored_refresh');

        final result = await dataSource.getTokens();

        expect(result, isNotNull);
        expect(result!.accessToken, 'stored_access');
        expect(result.refreshToken, 'stored_refresh');
      });

      test('should return null when tokens do not exist', () async {
        final result = await dataSource.getTokens();

        expect(result, isNull);
      });
    });

    group('clearTokens', () {
      test('should remove all tokens', () async {
        await mockStorage.write(key: 'access_token', value: 'access');
        await mockStorage.write(key: 'refresh_token', value: 'refresh');

        await dataSource.clearTokens();

        final accessToken = await mockStorage.read(key: 'access_token');
        final refreshToken = await mockStorage.read(key: 'refresh_token');
        expect(accessToken, isNull);
        expect(refreshToken, isNull);
      });
    });

    group('getAccessToken', () {
      test('should return access token when exists', () async {
        await mockStorage.write(key: 'access_token', value: 'my_access_token');

        final result = await dataSource.getAccessToken();

        expect(result, 'my_access_token');
      });
    });

    group('getRefreshToken', () {
      test('should return refresh token when exists', () async {
        await mockStorage.write(
          key: 'refresh_token',
          value: 'my_refresh_token',
        );

        final result = await dataSource.getRefreshToken();

        expect(result, 'my_refresh_token');
      });
    });
  });
}
