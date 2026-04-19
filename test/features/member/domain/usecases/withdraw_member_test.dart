import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';
import 'package:jellomark/features/member/domain/usecases/withdraw_member.dart';

class MockAuthRepository implements AuthRepository {
  String? capturedReason;
  Failure? failure;

  @override
  Future<Either<Failure, void>> withdraw(String reason) async {
    capturedReason = reason;
    if (failure != null) return Left(failure!);
    return const Right(null);
  }

  @override
  Future<Either<Failure, TokenPair>> loginWithKakaoSdk() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, TokenPair>> loginWithKakao(String kakaoAccessToken) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, TokenPair>> refreshToken(String refreshToken) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Member>> getCurrentMember() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> logout() => throw UnimplementedError();

  @override
  Future<TokenPair?> getStoredTokens() async => null;

  @override
  Future<void> clearStoredTokens() async {}
}

void main() {
  group('WithdrawMember', () {
    late WithdrawMember useCase;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = WithdrawMember(repository: mockRepository);
    });

    test('should pass reason to repository and return Right on success',
        () async {
      final result = await useCase('사용하지 않음');

      expect(result.isRight(), isTrue);
      expect(mockRepository.capturedReason, '사용하지 않음');
    });

    test('should return Failure when repository call fails', () async {
      mockRepository.failure = const ServerFailure('서버 오류');

      final result = await useCase('테스트 사유');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });
}
