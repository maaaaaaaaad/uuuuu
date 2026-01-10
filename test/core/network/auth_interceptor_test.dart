import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/network/auth_interceptor.dart';

class MockTokenProvider implements TokenProvider {
  String? token;

  @override
  Future<String?> getAccessToken() async => token;

  @override
  Future<void> clearTokens() async {
    token = null;
  }
}

void main() {
  group('AuthInterceptor', () {
    late Dio dio;
    late MockTokenProvider tokenProvider;
    late AuthInterceptor interceptor;

    setUp(() {
      dio = Dio();
      tokenProvider = MockTokenProvider();
      interceptor = AuthInterceptor(tokenProvider: tokenProvider);
      dio.interceptors.add(interceptor);
    });

    test('should add Authorization header when token exists', () async {
      tokenProvider.token = 'test_access_token';

      final options = RequestOptions(path: '/test');
      final handler = _MockRequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer test_access_token');
      expect(handler.nextCalled, isTrue);
    });

    test('should not add Authorization header when token is null', () async {
      tokenProvider.token = null;

      final options = RequestOptions(path: '/test');
      final handler = _MockRequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], isNull);
      expect(handler.nextCalled, isTrue);
    });
  });
}

class _MockRequestInterceptorHandler extends RequestInterceptorHandler {
  bool nextCalled = false;

  @override
  void next(RequestOptions requestOptions) {
    nextCalled = true;
  }
}
