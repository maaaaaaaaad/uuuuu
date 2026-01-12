import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jellomark/core/network/api_client.dart';
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
  group('ApiClient', () {
    test('should create Dio instance with base url', () {
      const baseUrl = 'https://api.example.com';
      final client = ApiClient(baseUrl: baseUrl);

      expect(client.dio.options.baseUrl, baseUrl);
    });

    test('should have default timeout settings', () {
      final client = ApiClient(baseUrl: 'https://api.example.com');

      expect(client.dio.options.connectTimeout, const Duration(seconds: 30));
      expect(client.dio.options.receiveTimeout, const Duration(seconds: 30));
    });

    test('should have JSON content type header', () {
      final client = ApiClient(baseUrl: 'https://api.example.com');

      expect(client.dio.options.headers['Content-Type'], 'application/json');
    });

    group('API Requests', () {
      late ApiClient client;
      late DioAdapter dioAdapter;

      setUp(() {
        client = ApiClient(baseUrl: 'https://api.example.com');
        dioAdapter = DioAdapter(dio: client.dio);
      });

      test('should perform GET request successfully', () async {
        dioAdapter.onGet(
          '/users',
          (server) => server.reply(200, {'data': 'success'}),
        );

        final response = await client.get('/users');

        expect(response.statusCode, 200);
        expect(response.data['data'], 'success');
      });

      test('should perform POST request successfully', () async {
        dioAdapter.onPost(
          '/users',
          (server) => server.reply(201, {'id': 1}),
          data: {'name': 'test'},
        );

        final response = await client.post('/users', data: {'name': 'test'});

        expect(response.statusCode, 201);
        expect(response.data['id'], 1);
      });
    });

    group('Error Handling', () {
      late ApiClient client;
      late DioAdapter dioAdapter;

      setUp(() {
        client = ApiClient(baseUrl: 'https://api.example.com');
        dioAdapter = DioAdapter(dio: client.dio);
      });

      test('should throw DioException on 401 Unauthorized', () async {
        dioAdapter.onGet(
          '/protected',
          (server) => server.reply(401, {'error': 'Unauthorized'}),
        );

        expect(() => client.get('/protected'), throwsA(isA<DioException>()));
      });

      test('should throw DioException on 409 Conflict', () async {
        dioAdapter.onPost(
          '/users',
          (server) => server.reply(409, {'error': 'Conflict'}),
          data: Matchers.any,
        );

        expect(
          () => client.post('/users', data: {}),
          throwsA(isA<DioException>()),
        );
      });

      test('should throw DioException on 422 Unprocessable Entity', () async {
        dioAdapter.onPost(
          '/users',
          (server) => server.reply(422, {'error': 'Validation failed'}),
          data: Matchers.any,
        );

        expect(
          () => client.post('/users', data: {}),
          throwsA(isA<DioException>()),
        );
      });

      test('should throw DioException on 500 Internal Server Error', () async {
        dioAdapter.onGet(
          '/error',
          (server) => server.reply(500, {'error': 'Server error'}),
        );

        expect(() => client.get('/error'), throwsA(isA<DioException>()));
      });
    });

    group('AuthInterceptor', () {
      test('should add AuthInterceptor when provided', () {
        final mockTokenProvider = MockTokenProvider();
        final authInterceptor = AuthInterceptor(tokenProvider: mockTokenProvider);
        final client = ApiClient(
          baseUrl: 'https://api.example.com',
          authInterceptor: authInterceptor,
        );

        expect(
          client.dio.interceptors.whereType<AuthInterceptor>().length,
          1,
        );
      });

      test('should not have AuthInterceptor when not provided', () {
        final client = ApiClient(baseUrl: 'https://api.example.com');

        expect(
          client.dio.interceptors.whereType<AuthInterceptor>().length,
          0,
        );
      });
    });
  });
}
