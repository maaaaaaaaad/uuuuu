import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/datasources/kakao_auth_service.dart';
import 'package:jellomark/features/auth/data/models/token_pair_model.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/auth/domain/usecases/logout.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class MockKakaoAuthService implements KakaoAuthService {
  bool logoutCalled = false;
  Exception? exception;

  @override
  Future<String> loginWithKakao() async => '';

  @override
  Future<void> logout() async {
    if (exception != null) throw exception!;
    logoutCalled = true;
  }
}

class MockAuthRepository implements AuthRepository {
  bool logoutCalled = false;

  @override
  Future<Either<Failure, TokenPair>> loginWithKakao(
    String kakaoAccessToken,
  ) async {
    return const Right(TokenPairModel(accessToken: '', refreshToken: ''));
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
    logoutCalled = true;
    return const Right(null);
  }
}

void main() {
  group('LogoutUseCase', () {
    late LogoutUseCase useCase;
    late MockKakaoAuthService mockKakaoService;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockKakaoService = MockKakaoAuthService();
      mockRepository = MockAuthRepository();
      useCase = LogoutUseCase(
        kakaoAuthService: mockKakaoService,
        authRepository: mockRepository,
      );
    });

    test('should logout from both Kakao and local storage', () async {
      final result = await useCase();

      expect(result.isRight(), isTrue);
      expect(mockKakaoService.logoutCalled, isTrue);
      expect(mockRepository.logoutCalled, isTrue);
    });

    test(
      'should still clear local tokens even if Kakao logout fails',
      () async {
        mockKakaoService.exception = Exception('Kakao logout failed');

        final result = await useCase();

        // 로컬 토큰은 여전히 삭제되어야 함
        expect(result.isRight(), isTrue);
        expect(mockRepository.logoutCalled, isTrue);
      },
    );
  });
}
