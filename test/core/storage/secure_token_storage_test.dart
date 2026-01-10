import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/network/auth_interceptor.dart';
import 'package:jellomark/core/storage/secure_token_storage.dart';

class MockFlutterSecureStorage implements SecureStorageWrapper {
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
  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }
}

void main() {
  group('SecureTokenStorage', () {
    late SecureTokenStorage storage;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      storage = SecureTokenStorage(secureStorage: mockStorage);
    });

    group('saveAccessToken', () {
      test('should save access token', () async {
        await storage.saveAccessToken('test_access_token');

        final savedToken = await mockStorage.read(key: 'access_token');
        expect(savedToken, 'test_access_token');
      });
    });

    group('getAccessToken', () {
      test('should return access token when exists', () async {
        await mockStorage.write(key: 'access_token', value: 'stored_token');

        final token = await storage.getAccessToken();

        expect(token, 'stored_token');
      });

      test('should return null when token does not exist', () async {
        final token = await storage.getAccessToken();

        expect(token, isNull);
      });
    });

    group('saveRefreshToken', () {
      test('should save refresh token', () async {
        await storage.saveRefreshToken('test_refresh_token');

        final savedToken = await mockStorage.read(key: 'refresh_token');
        expect(savedToken, 'test_refresh_token');
      });
    });

    group('getRefreshToken', () {
      test('should return refresh token when exists', () async {
        await mockStorage.write(key: 'refresh_token', value: 'stored_refresh');

        final token = await storage.getRefreshToken();

        expect(token, 'stored_refresh');
      });
    });

    group('clearTokens', () {
      test('should clear all tokens', () async {
        await mockStorage.write(key: 'access_token', value: 'access');
        await mockStorage.write(key: 'refresh_token', value: 'refresh');

        await storage.clearTokens();

        final accessToken = await mockStorage.read(key: 'access_token');
        final refreshToken = await mockStorage.read(key: 'refresh_token');
        expect(accessToken, isNull);
        expect(refreshToken, isNull);
      });
    });

    test('should implement TokenProvider interface', () {
      expect(storage, isA<TokenProvider>());
    });
  });
}
