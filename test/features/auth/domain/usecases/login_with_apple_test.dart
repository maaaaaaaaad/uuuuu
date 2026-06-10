import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/models/token_pair_model.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/auth/domain/usecases/login_with_apple.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class _MockAuthRepository implements AuthRepository {
  TokenPair? loginAppleSdkResult;
  Failure? loginAppleSdkFailure;

  @override
  Future<Either<Failure, TokenPair>> loginWithAppleSdk() async {
    if (loginAppleSdkFailure != null) return Left(loginAppleSdkFailure!);
    return Right(loginAppleSdkResult!);
  }

  @override
  Future<Either<Failure, TokenPair>> loginWithApple(
    String identityToken,
    String? fullName,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TokenPair>> loginWithKakaoSdk() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TokenPair>> loginWithKakao(
    String kakaoAccessToken,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TokenPair>> refreshToken(String refreshToken) async {
    return const Right(TokenPairModel(accessToken: '', refreshToken: ''));
  }

  @override
  Future<Either<Failure, Member>> getCurrentMember() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return const Right(null);
  }

  @override
  Future<TokenPair?> getStoredTokens() async => null;

  @override
  Future<void> clearStoredTokens() async {}

  @override
  Future<Either<Failure, void>> withdraw(String reason) async =>
      const Right(null);
}

void main() {
  group('LoginWithAppleUseCase', () {
    late LoginWithAppleUseCase useCase;
    late _MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = _MockAuthRepository();
      useCase = LoginWithAppleUseCase(authRepository: mockRepository);
    });

    test('should return TokenPair on success', () async {
      const tokenPair = TokenPairModel(
        accessToken: 'apple_access',
        refreshToken: 'apple_refresh',
      );
      mockRepository.loginAppleSdkResult = tokenPair;

      final result = await useCase();

      expect(result, const Right<Failure, TokenPair>(tokenPair));
    });

    test('should return failure when SDK fails', () async {
      mockRepository.loginAppleSdkFailure = const AppleLoginFailure('cancelled');

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<AppleLoginFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
