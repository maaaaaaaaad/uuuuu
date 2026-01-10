import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:jellomark/features/auth/data/models/member_model.dart';
import 'package:jellomark/features/auth/data/models/token_pair_model.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/auth/domain/usecases/check_auth_status.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class MockAuthLocalDataSource implements AuthLocalDataSource {
  TokenPairModel? storedTokens;

  @override
  Future<void> saveTokens(TokenPairModel tokenPair) async {
    storedTokens = tokenPair;
  }

  @override
  Future<TokenPairModel?> getTokens() async => storedTokens;

  @override
  Future<void> clearTokens() async {
    storedTokens = null;
  }

  @override
  Future<String?> getAccessToken() async => storedTokens?.accessToken;

  @override
  Future<String?> getRefreshToken() async => storedTokens?.refreshToken;
}

class MockAuthRepository implements AuthRepository {
  Member? memberResult;
  TokenPair? refreshResult;
  Failure? memberFailure;
  Failure? refreshFailure;

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
}

void main() {
  group('CheckAuthStatusUseCase', () {
    late CheckAuthStatusUseCase useCase;
    late MockAuthLocalDataSource mockLocalDataSource;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockLocalDataSource = MockAuthLocalDataSource();
      mockRepository = MockAuthRepository();
      useCase = CheckAuthStatusUseCase(
        localDataSource: mockLocalDataSource,
        authRepository: mockRepository,
      );
    });

    test('should return NoTokenFailure when no tokens stored', () async {
      mockLocalDataSource.storedTokens = null;

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NoTokenFailure>()),
        (_) => fail('Should be failure'),
      );
    });

    test('should return Member when token is valid', () async {
      mockLocalDataSource.storedTokens = const TokenPairModel(
        accessToken: 'valid_access',
        refreshToken: 'valid_refresh',
      );
      mockRepository.memberResult = const MemberModel(
        id: 'member-123',
        nickname: '젤리',
        email: 'jelly@example.com',
      );

      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should be success'), (member) {
        expect(member.id, 'member-123');
        expect(member.nickname, '젤리');
      });
    });

    test('should refresh token and retry when access token expired', () async {
      mockLocalDataSource.storedTokens = const TokenPairModel(
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
      mockLocalDataSource.storedTokens = const TokenPairModel(
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
