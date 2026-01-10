import 'package:dio/dio.dart';

abstract class TokenProvider {
  Future<String?> getAccessToken();

  Future<void> clearTokens();
}

class AuthInterceptor extends Interceptor {
  final TokenProvider tokenProvider;

  AuthInterceptor({required this.tokenProvider});

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
}
