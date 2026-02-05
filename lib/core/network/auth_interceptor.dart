import 'dart:async';
import 'package:dio/dio.dart';

abstract class TokenProvider {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clearTokens();
}

class AuthInterceptor extends QueuedInterceptor {
  final TokenProvider tokenProvider;
  final String baseUrl;

  Dio? _refreshDio;
  bool _isRefreshing = false;
  final _refreshCompleter = <Completer<bool>>[];

  AuthInterceptor({
    required this.tokenProvider,
    required this.baseUrl,
  });

  Dio get _getRefreshDio {
    _refreshDio ??= Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    return _refreshDio!;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenProvider.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final refreshToken = await tokenProvider.getRefreshToken();
    if (refreshToken == null) {
      await tokenProvider.clearTokens();
      return handler.next(err);
    }

    final success = await _refreshTokens(refreshToken);
    if (!success) {
      await tokenProvider.clearTokens();
      return handler.next(err);
    }

    final newToken = await tokenProvider.getAccessToken();
    if (newToken == null) {
      return handler.next(err);
    }

    final retryOptions = err.requestOptions;
    retryOptions.headers['Authorization'] = 'Bearer $newToken';

    try {
      final response = await _getRefreshDio.fetch(retryOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  Future<bool> _refreshTokens(String refreshToken) async {
    if (_isRefreshing) {
      final completer = Completer<bool>();
      _refreshCompleter.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final response = await _getRefreshDio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final accessToken = response.data['accessToken'] as String;
        final newRefreshToken = response.data['refreshToken'] as String;

        await tokenProvider.saveTokens(
          accessToken: accessToken,
          refreshToken: newRefreshToken,
        );

        _completeRefreshRequests(true);
        return true;
      }

      _completeRefreshRequests(false);
      return false;
    } catch (_) {
      _completeRefreshRequests(false);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  void _completeRefreshRequests(bool success) {
    for (final completer in _refreshCompleter) {
      completer.complete(success);
    }
    _refreshCompleter.clear();
  }
}
