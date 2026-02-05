import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jellomark/core/network/auth_interceptor.dart';

abstract class SecureStorageWrapper {
  Future<void> write({required String key, required String? value});

  Future<String?> read({required String key});

  Future<void> delete({required String key});

  Future<void> deleteAll();
}

class FlutterSecureStorageWrapper implements SecureStorageWrapper {
  final FlutterSecureStorage _storage;

  FlutterSecureStorageWrapper() : _storage = const FlutterSecureStorage();

  @override
  Future<void> write({required String key, required String? value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}

class SecureTokenStorage implements TokenProvider {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final SecureStorageWrapper _secureStorage;

  SecureTokenStorage({required SecureStorageWrapper secureStorage})
    : _secureStorage = secureStorage;

  Future<void> saveAccessToken(String token) =>
      _secureStorage.write(key: _accessTokenKey, value: token);

  @override
  Future<String?> getAccessToken() => _secureStorage.read(key: _accessTokenKey);

  Future<void> saveRefreshToken(String token) =>
      _secureStorage.write(key: _refreshTokenKey, value: token);

  @override
  Future<String?> getRefreshToken() =>
      _secureStorage.read(key: _refreshTokenKey);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  @override
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
}
