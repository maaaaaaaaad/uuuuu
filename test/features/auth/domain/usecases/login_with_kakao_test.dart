import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/datasources/kakao_auth_service.dart';
import 'package:jellomark/features/auth/data/models/token_pair_model.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/auth/domain/usecases/login_with_kakao.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class MockKakaoAuthService implements KakaoAuthService {
  String? kakaoToken;
  Exception? exception;

  @override
  Future<String> loginWithKakao() async {
    if (exception != null) throw exception!;
    return kakaoToken!;
  }

  @override
  Future<void> logout() async {}
}

class MockAuthRepository implements AuthRepository {
  TokenPair? loginResult;
  Failure? failure;

  @override
  Future<Either<Failure, TokenPair>> loginWithKakao(
    String kakaoAccessToken,
  ) async {
    if (failure != null) return Left(failure!);
    return Right(loginResult!);
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
}

void main() {
  group('LoginWithKakaoUseCase', () {
    late LoginWithKakaoUseCase useCase;
    late MockKakaoAuthService mockKakaoService;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockKakaoService = MockKakaoAuthService();
      mockRepository = MockAuthRepository();
      useCase = LoginWithKakaoUseCase(
        kakaoAuthService: mockKakaoService,
        authRepository: mockRepository,
      );
    });

    test('should login with Kakao and return TokenPair on success', () async {
      mockKakaoService.kakaoToken = 'kakao_access_token_123';
      mockRepository.loginResult = const TokenPairModel(
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
      mockKakaoService.exception = Exception('Kakao login failed');

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<KakaoLoginFailure>()),
        (_) => fail('Should be failure'),
      );
    });

    test('should return AuthFailure when server auth fails', () async {
      mockKakaoService.kakaoToken = 'kakao_token';
      mockRepository.failure = AuthFailure('Server error');

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Should be failure'),
      );
    });
  });
}
