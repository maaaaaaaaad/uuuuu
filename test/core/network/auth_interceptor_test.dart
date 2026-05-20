import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/network/auth_interceptor.dart';

class MockTokenProvider implements TokenProvider {
  String? accessToken;
  String? refreshToken;

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
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
      interceptor = AuthInterceptor(
        tokenProvider: tokenProvider,
        baseUrl: 'http://localhost:8080',
      );
      dio.interceptors.add(interceptor);
    });

    test('should add Authorization header when token exists', () async {
      tokenProvider.accessToken = 'test_access_token';

      final options = RequestOptions(path: '/test');
      final handler = _MockRequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer test_access_token');
      expect(handler.nextCalled, isTrue);
    });

    test('should not add Authorization header when token is null', () async {
      tokenProvider.accessToken = null;

      final options = RequestOptions(path: '/test');
      final handler = _MockRequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], isNull);
      expect(handler.nextCalled, isTrue);
    });
  });

  group('AuthInterceptor.prepareRetryData', () {
    test('clones already-consumed FormData so the retry body is re-readable',
        () {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes([1, 2, 3, 4], filename: 'menu.jpg'),
      });
      formData.finalize();

      final options =
          RequestOptions(path: '/api/images/upload', data: formData);

      AuthInterceptor.prepareRetryData(options);

      expect(options.data, isNot(same(formData)));
      expect(() => (options.data as FormData).finalize(), returnsNormally);
    });

    test('leaves non-FormData payloads untouched', () {
      final body = {'refreshToken': 'abc'};
      final options = RequestOptions(path: '/api/auth/refresh', data: body);

      AuthInterceptor.prepareRetryData(options);

      expect(options.data, same(body));
    });

    test('tolerates null payloads', () {
      final options = RequestOptions(path: '/api/members/me');

      expect(() => AuthInterceptor.prepareRetryData(options), returnsNormally);
      expect(options.data, isNull);
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
