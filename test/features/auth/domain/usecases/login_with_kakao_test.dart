import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/models/token_pair_model.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/auth/domain/usecases/login_with_kakao.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class MockAuthRepository implements AuthRepository {
  TokenPair? loginSdkResult;
  Failure? loginSdkFailure;

  @override
  Future<Either<Failure, TokenPair>> loginWithKakaoSdk() async {
    if (loginSdkFailure != null) return Left(loginSdkFailure!);
    return Right(loginSdkResult!);
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
}

void main() {
  group('LoginWithKakaoUseCase', () {
    late LoginWithKakaoUseCase useCase;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = LoginWithKakaoUseCase(authRepository: mockRepository);
    });

    test('should login with Kakao and return TokenPair on success', () async {
      mockRepository.loginSdkResult = const TokenPairModel(
        accessToken: 'server_access',
        refreshToken: 'server_refresh',
      );

      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should be success'), (tokenPair) {
        expect(tokenPair.accessToken, 'server_access');
        expect(tokenPair.refreshToken, 'server_refresh');
      });
    });

    test('should return KakaoLoginFailure when Kakao login fails', () async {
      mockRepository.loginSdkFailure = KakaoLoginFailure('Kakao login failed');

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<KakaoLoginFailure>()),
        (_) => fail('Should be failure'),
      );
    });

    test('should return AuthFailure when server auth fails', () async {
      mockRepository.loginSdkFailure = AuthFailure('Server error');

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Should be failure'),
      );
    });
  });
}
