import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/models/member_model.dart';
import 'package:jellomark/features/auth/data/models/token_pair_model.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/auth/domain/usecases/check_auth_status.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class MockAuthRepository implements AuthRepository {
  TokenPair? storedTokens;
  Member? memberResult;
  TokenPair? refreshResult;
  Failure? memberFailure;
  Failure? refreshFailure;
  bool tokenCleared = false;

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
    if (refreshFailure != null) return Left(refreshFailure!);
    return Right(refreshResult!);
  }

  @override
  Future<Either<Failure, Member>> getCurrentMember() async {
    if (memberFailure != null) return Left(memberFailure!);
    return Right(memberResult!);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return const Right(null);
  }

  @override
  Future<TokenPair?> getStoredTokens() async => storedTokens;

  @override
  Future<void> clearStoredTokens() async {
    tokenCleared = true;
    storedTokens = null;
  }
}

void main() {
  group('CheckAuthStatusUseCase', () {
    late CheckAuthStatusUseCase useCase;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = CheckAuthStatusUseCase(authRepository: mockRepository);
    });

    test('should return NoTokenFailure when no tokens stored', () async {
      mockRepository.storedTokens = null;

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NoTokenFailure>()),
        (_) => fail('Should be failure'),
      );
    });

    test('should return Member when token is valid', () async {
      mockRepository.storedTokens = const TokenPairModel(
        accessToken: 'valid_access',
        refreshToken: 'valid_refresh',
      );
      mockRepository.memberResult = const MemberModel(
        id: 'member-123',
        nickname: '젤리123456',
        displayName: '젤리',
        socialProvider: 'KAKAO',
        socialId: 'kakao-123456',
      );

      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should be success'), (member) {
        expect(member.id, 'member-123');
        expect(member.displayName, '젤리');
      });
    });

    test('should refresh token and retry when access token expired', () async {
      mockRepository.storedTokens = const TokenPairModel(
        accessToken: 'expired_access',
        refreshToken: 'valid_refresh',
      );
      mockRepository.memberFailure = const AuthFailure('Token expired');
      mockRepository.refreshResult = const TokenPairModel(
        accessToken: 'new_access',
        refreshToken: 'new_refresh',
      );

      final result = await useCase();

      expect(result.isLeft(), isTrue);
    });

    test('should return AuthFailure when refresh token also expired', () async {
      mockRepository.storedTokens = const TokenPairModel(
        accessToken: 'expired_access',
        refreshToken: 'expired_refresh',
      );
      mockRepository.memberFailure = const AuthFailure('Token expired');
      mockRepository.refreshFailure = const AuthFailure(
        'Refresh token expired',
      );

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Should be failure'),
      );
    });
  });
}
