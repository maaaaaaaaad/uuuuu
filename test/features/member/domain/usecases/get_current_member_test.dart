import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';
import 'package:jellomark/features/member/domain/usecases/get_current_member.dart';

class MockAuthRepository implements AuthRepository {
  Member? memberResult;
  Failure? failure;

  @override
  Future<Either<Failure, Member>> getCurrentMember() async {
    if (failure != null) return Left(failure!);
    return Right(memberResult!);
  }

  @override
  Future<Either<Failure, TokenPair>> loginWithKakaoSdk() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TokenPair>> loginWithKakao(String kakaoAccessToken) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TokenPair>> refreshToken(String refreshToken) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> logout() {
    throw UnimplementedError();
  }

  @override
  Future<TokenPair?> getStoredTokens() async => null;

  @override
  Future<void> clearStoredTokens() async {}
}

void main() {
  group('GetCurrentMember', () {
    late GetCurrentMember useCase;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = GetCurrentMember(repository: mockRepository);
    });

    test('should return Member when repository call is successful', () async {
      const member = Member(
        id: '1',
        nickname: '테스트유저',
        socialProvider: 'KAKAO',
        socialId: 'test-kakao-id',
      );
      mockRepository.memberResult = member;

      final result = await useCase();

      expect(result, const Right(member));
    });

    test('should return Failure when repository call fails', () async {
      mockRepository.failure = const ServerFailure('서버 오류');

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return NetworkFailure when no network', () async {
      mockRepository.failure = const NetworkFailure('네트워크 연결 실패');

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });
}
