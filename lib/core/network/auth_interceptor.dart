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

enum _RefreshOutcome { success, tokenInvalid, transient }

class AuthInterceptor extends QueuedInterceptor {
  final TokenProvider tokenProvider;
  final String baseUrl;

  Dio? _refreshDio;
  bool _isRefreshing = false;
  final _refreshCompleter = <Completer<_RefreshOutcome>>[];

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

    final outcome = await _refreshTokens(refreshToken);
    if (outcome == _RefreshOutcome.tokenInvalid) {
      await tokenProvider.clearTokens();
      return handler.next(err);
    }
    if (outcome == _RefreshOutcome.transient) {
      // Keep tokens — let user retry next time. Do not log out.
      return handler.next(err);
    }

    final newToken = await tokenProvider.getAccessToken();
    if (newToken == null) {
      return handler.next(err);
    }

    final retryOptions = err.requestOptions;
    retryOptions.headers['Authorization'] = 'Bearer $newToken';
    prepareRetryData(retryOptions);

    try {
      final response = await _getRefreshDio.fetch(retryOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  static void prepareRetryData(RequestOptions options) {
    final data = options.data;
    if (data is FormData) {
      options.data = data.clone();
    }
  }

  Future<_RefreshOutcome> _refreshTokens(String refreshToken) async {
    if (_isRefreshing) {
      final completer = Completer<_RefreshOutcome>();
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

        _completeRefreshRequests(_RefreshOutcome.success);
        return _RefreshOutcome.success;
      }

      _completeRefreshRequests(_RefreshOutcome.transient);
      return _RefreshOutcome.transient;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final outcome = (status == 401 || status == 403)
          ? _RefreshOutcome.tokenInvalid
          : _RefreshOutcome.transient;
      _completeRefreshRequests(outcome);
      return outcome;
    } catch (_) {
      _completeRefreshRequests(_RefreshOutcome.transient);
      return _RefreshOutcome.transient;
    } finally {
      _isRefreshing = false;
    }
  }

  void _completeRefreshRequests(_RefreshOutcome outcome) {
    for (final completer in _refreshCompleter) {
      completer.complete(outcome);
    }
    _refreshCompleter.clear();
  }
}
