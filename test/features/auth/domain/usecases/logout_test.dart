import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/models/token_pair_model.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/auth/domain/usecases/logout.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class MockAuthRepository implements AuthRepository {
  bool logoutCalled = false;

  @override
  Future<Either<Failure, TokenPair>> loginWithKakaoSdk() async {
    throw UnimplementedError();
  }

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

  @override
  Future<TokenPair?> getStoredTokens() async => null;

  @override
  Future<void> clearStoredTokens() async {}
}

void main() {
  group('LogoutUseCase', () {
    late LogoutUseCase useCase;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = LogoutUseCase(authRepository: mockRepository);
    });

    test('should logout from both Kakao and local storage', () async {
      final result = await useCase();

      expect(result.isRight(), isTrue);
      expect(mockRepository.logoutCalled, isTrue);
    });

    test('should return success on logout', () async {
      final result = await useCase();

      expect(result.isRight(), isTrue);
    });
  });
}
