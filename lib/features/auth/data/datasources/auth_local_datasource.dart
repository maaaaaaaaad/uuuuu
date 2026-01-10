import 'package:jellomark/core/storage/secure_token_storage.dart';
import 'package:jellomark/features/auth/data/models/token_pair_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens(TokenPairModel tokenPair);

  Future<TokenPairModel?> getTokens();

  Future<void> clearTokens();

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final SecureStorageWrapper _secureStorage;

  AuthLocalDataSourceImpl({required SecureStorageWrapper secureStorage})
    : _secureStorage = secureStorage;

  @override
  Future<void> saveTokens(TokenPairModel tokenPair) async {
    await _secureStorage.write(
      key: _accessTokenKey,
      value: tokenPair.accessToken,
    );
    await _secureStorage.write(
      key: _refreshTokenKey,
      value: tokenPair.refreshToken,
    );
  }

  @override
  Future<TokenPairModel?> getTokens() async {
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return TokenPairModel(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  @override
  Future<String?> getAccessToken() => _secureStorage.read(key: _accessTokenKey);

  @override
  Future<String?> getRefreshToken() =>
      _secureStorage.read(key: _refreshTokenKey);
}
