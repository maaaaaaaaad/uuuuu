import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:jellomark/features/auth/data/models/member_model.dart';
import 'package:jellomark/features/auth/data/models/token_pair_model.dart';

void main() {
  group('AuthRemoteDataSource', () {
    late AuthRemoteDataSource dataSource;
    late ApiClient apiClient;
    late DioAdapter dioAdapter;

    setUp(() {
      apiClient = ApiClient(baseUrl: 'https://api.example.com');
      dioAdapter = DioAdapter(dio: apiClient.dio);
      dataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
    });

    group('loginWithKakao', () {
      test('should return TokenPairModel when login is successful', () async {
        dioAdapter.onPost(
          '/api/auth/kakao',
          (server) => server.reply(200, {
            'accessToken': 'server_access_token',
            'refreshToken': 'server_refresh_token',
          }),
          data: {'kakaoAccessToken': 'kakao_token'},
        );

        final result = await dataSource.loginWithKakao('kakao_token');

        expect(result, isA<TokenPairModel>());
        expect(result.accessToken, 'server_access_token');
        expect(result.refreshToken, 'server_refresh_token');
      });

      test('should throw exception when login fails', () async {
        dioAdapter.onPost(
          '/api/auth/kakao',
          (server) => server.reply(401, {'error': 'Invalid token'}),
          data: {'kakaoAccessToken': 'invalid_token'},
        );

        expect(
          () => dataSource.loginWithKakao('invalid_token'),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('refreshToken', () {
      test(
        'should return new TokenPairModel when refresh is successful',
        () async {
          dioAdapter.onPost(
            '/api/auth/refresh',
            (server) => server.reply(200, {
              'accessToken': 'new_access_token',
              'refreshToken': 'new_refresh_token',
            }),
            data: {'refreshToken': 'old_refresh_token'},
          );

          final result = await dataSource.refreshToken('old_refresh_token');

          expect(result, isA<TokenPairModel>());
          expect(result.accessToken, 'new_access_token');
        },
      );
    });

    group('getCurrentMember', () {
      test('should return MemberModel when request is successful', () async {
        dioAdapter.onGet(
          '/api/members/me',
          (server) => server.reply(200, {
            'id': 'member-123',
            'nickname': '젤리',
            'email': 'jelly@example.com',
          }),
        );

        final result = await dataSource.getCurrentMember();

        expect(result, isA<MemberModel>());
        expect(result.id, 'member-123');
        expect(result.nickname, '젤리');
        expect(result.email, 'jelly@example.com');
      });
    });
  });
}
