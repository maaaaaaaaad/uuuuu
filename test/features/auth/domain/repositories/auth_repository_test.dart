import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, TokenPair>> loginWithKakaoSdk() async {
    return Right(
      TokenPair(
        accessToken: 'server_access_token',
        refreshToken: 'server_refresh_token',
      ),
    );
  }

  @override
  Future<Either<Failure, TokenPair>> loginWithKakao(
    String kakaoAccessToken,
  ) async {
    return Right(
      TokenPair(
        accessToken: 'server_access_token',
        refreshToken: 'server_refresh_token',
      ),
    );
  }

  @override
  Future<Either<Failure, TokenPair>> refreshToken(String refreshToken) async {
    return Right(
      TokenPair(
        accessToken: 'new_access_token',
        refreshToken: 'new_refresh_token',
      ),
    );
  }

  @override
  Future<Either<Failure, Member>> getCurrentMember() async {
    return Right(
      Member(
        id: 'member-123',
        nickname: '젤리',
        displayName: '젤리',
        socialProvider: 'KAKAO',
        socialId: 'kakao-123456',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return const Right(null);
  }

  @override
  Future<TokenPair?> getStoredTokens() async {
    return TokenPair(
      accessToken: 'stored_access',
      refreshToken: 'stored_refresh',
    );
  }

  @override
  Future<void> clearStoredTokens() async {}
}

void main() {
  group('AuthRepository', () {
    late MockAuthRepository repository;

    setUp(() {
      repository = MockAuthRepository();
    });

    test('should define loginWithKakaoSdk method', () async {
      final result = await repository.loginWithKakaoSdk();

      expect(result.isRight(), isTrue);
      result.fold((failure) => fail('Should not be failure'), (tokenPair) {
        expect(tokenPair.accessToken, isNotEmpty);
        expect(tokenPair.refreshToken, isNotEmpty);
      });
    });

    test('should define loginWithKakao method', () async {
      final result = await repository.loginWithKakao('kakao_token');

      expect(result.isRight(), isTrue);
      result.fold((failure) => fail('Should not be failure'), (tokenPair) {
        expect(tokenPair.accessToken, isNotEmpty);
        expect(tokenPair.refreshToken, isNotEmpty);
      });
    });

    test('should define refreshToken method', () async {
      final result = await repository.refreshToken('refresh_token');

      expect(result.isRight(), isTrue);
    });

    test('should define getCurrentMember method', () async {
      final result = await repository.getCurrentMember();

      expect(result.isRight(), isTrue);
      result.fold((failure) => fail('Should not be failure'), (member) {
        expect(member.id, isNotEmpty);
        expect(member.nickname, isNotEmpty);
      });
    });

    test('should define logout method', () async {
      final result = await repository.logout();

      expect(result.isRight(), isTrue);
    });

    test('should define getStoredTokens method', () async {
      final result = await repository.getStoredTokens();

      expect(result, isNotNull);
      expect(result!.accessToken, isNotEmpty);
    });

    test('should define clearStoredTokens method', () async {
      await repository.clearStoredTokens();
    });
  });
}
