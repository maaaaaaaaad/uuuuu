import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/models/member_model.dart';
import 'package:jellomark/features/member/data/datasources/member_remote_datasource.dart';
import 'package:jellomark/features/member/data/repositories/member_repository_impl.dart';
import 'package:jellomark/features/member/domain/repositories/member_repository.dart';

class MockMemberRemoteDataSource implements MemberRemoteDataSource {
  MemberModel? updateResult;
  Exception? exception;

  @override
  Future<MemberModel> updateProfile({required String nickname}) async {
    if (exception != null) throw exception!;
    return updateResult!;
  }
}

void main() {
  group('MemberRepositoryImpl', () {
    late MemberRepository repository;
    late MockMemberRemoteDataSource mockRemoteDataSource;

    setUp(() {
      mockRemoteDataSource = MockMemberRemoteDataSource();
      repository = MemberRepositoryImpl(remoteDataSource: mockRemoteDataSource);
    });

    group('updateProfile', () {
      test('should return Member on success', () async {
        const member = MemberModel(
          id: 'member-123',
          nickname: '새닉네임',
          socialProvider: 'KAKAO',
          socialId: 'kakao-123456',
        );
        mockRemoteDataSource.updateResult = member;

        final result = await repository.updateProfile(nickname: '새닉네임');

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Should be success'), (m) {
          expect(m.nickname, '새닉네임');
          expect(m.id, 'member-123');
        });
      });

      test('should return ValidationFailure on 422 error', () async {
        mockRemoteDataSource.exception = DioException(
          requestOptions: RequestOptions(path: '/api/members/me'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/api/members/me'),
            statusCode: 422,
          ),
        );

        final result = await repository.updateProfile(nickname: 'x');

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Should be failure'),
        );
      });

      test('should return ServerFailure on other errors', () async {
        mockRemoteDataSource.exception = DioException(
          requestOptions: RequestOptions(path: '/api/members/me'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/api/members/me'),
            statusCode: 500,
          ),
        );

        final result = await repository.updateProfile(nickname: '닉네임');

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Should be failure'),
        );
      });
    });
  });
}
