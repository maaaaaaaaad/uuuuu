import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/member/data/datasources/member_remote_datasource.dart';

class MockApiClient implements ApiClient {
  @override
  Dio get dio => throw UnimplementedError();

  Map<String, dynamic>? patchResult;
  Exception? exception;
  String? lastPath;
  Object? lastData;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> post<T>(String path, {Object? data}) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> put<T>(String path, {Object? data}) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> delete<T>(String path) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> patch<T>(String path, {Object? data}) async {
    lastPath = path;
    lastData = data;
    if (exception != null) throw exception!;
    return Response<T>(
      data: patchResult as T,
      requestOptions: RequestOptions(path: path),
    );
  }
}

void main() {
  group('MemberRemoteDataSourceImpl', () {
    late MemberRemoteDataSource dataSource;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      dataSource = MemberRemoteDataSourceImpl(apiClient: mockApiClient);
    });

    group('updateProfile', () {
      test('should call PATCH /api/members/me with nickname', () async {
        mockApiClient.patchResult = {
          'id': 'member-123',
          'nickname': '새닉네임',
          'socialProvider': 'KAKAO',
          'socialId': 'kakao-123456',
        };

        await dataSource.updateProfile(nickname: '새닉네임');

        expect(mockApiClient.lastPath, '/api/members/me');
        expect(mockApiClient.lastData, {'nickname': '새닉네임'});
      });

      test('should return MemberModel on success', () async {
        mockApiClient.patchResult = {
          'id': 'member-123',
          'nickname': '새닉네임',
          'socialProvider': 'KAKAO',
          'socialId': 'kakao-123456',
        };

        final result = await dataSource.updateProfile(nickname: '새닉네임');

        expect(result.id, 'member-123');
        expect(result.nickname, '새닉네임');
        expect(result.socialProvider, 'KAKAO');
      });

      test('should throw DioException on error', () async {
        mockApiClient.exception = DioException(
          requestOptions: RequestOptions(path: '/api/members/me'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/api/members/me'),
            statusCode: 422,
          ),
        );

        expect(
          () => dataSource.updateProfile(nickname: 'x'),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
