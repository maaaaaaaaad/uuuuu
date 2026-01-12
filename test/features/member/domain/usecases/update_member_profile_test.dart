import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';
import 'package:jellomark/features/member/domain/repositories/member_repository.dart';
import 'package:jellomark/features/member/domain/usecases/update_member_profile.dart';

class MockMemberRepository implements MemberRepository {
  Member? memberResult;
  Failure? failure;
  String? lastNickname;

  @override
  Future<Either<Failure, Member>> updateProfile({
    required String nickname,
  }) async {
    lastNickname = nickname;
    if (failure != null) return Left(failure!);
    return Right(memberResult!);
  }
}

void main() {
  group('UpdateMemberProfile', () {
    late UpdateMemberProfile useCase;
    late MockMemberRepository mockRepository;

    setUp(() {
      mockRepository = MockMemberRepository();
      useCase = UpdateMemberProfile(repository: mockRepository);
    });

    test(
      'should return updated Member when repository call is successful',
      () async {
        const updatedMember = Member(
          id: '1',
          nickname: '새닉네임',
          socialProvider: 'KAKAO',
          socialId: 'test-kakao-id',
        );
        mockRepository.memberResult = updatedMember;

        final result = await useCase(nickname: '새닉네임');

        expect(result, const Right(updatedMember));
        expect(mockRepository.lastNickname, '새닉네임');
      },
    );

    test('should return Failure when repository call fails', () async {
      mockRepository.failure = const ServerFailure('서버 오류');

      final result = await useCase(nickname: '새닉네임');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure for empty nickname', () async {
      final result = await useCase(nickname: '');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure for too long nickname', () async {
      final longNickname = 'a' * 51;

      final result = await useCase(nickname: longNickname);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });
}
