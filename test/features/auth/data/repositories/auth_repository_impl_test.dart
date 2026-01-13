import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:jellomark/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:jellomark/features/auth/data/datasources/kakao_auth_service.dart';
import 'package:jellomark/features/auth/data/models/member_model.dart';
import 'package:jellomark/features/auth/data/models/token_pair_model.dart';
import 'package:jellomark/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  TokenPairModel? loginResult;
  TokenPairModel? refreshResult;
  MemberModel? memberResult;
  Exception? exception;

  @override
  Future<TokenPairModel> loginWithKakao(String kakaoAccessToken) async {
    if (exception != null) throw exception!;
    return loginResult!;
  }

  @override
  Future<TokenPairModel> refreshToken(String refreshToken) async {
    if (exception != null) throw exception!;
    return refreshResult!;
  }

  @override
  Future<MemberModel> getCurrentMember() async {
    if (exception != null) throw exception!;
    return memberResult!;
  }

  @override
  Future<void> logout() async {
    if (exception != null) throw exception!;
  }
}

class MockAuthLocalDataSource implements AuthLocalDataSource {
  TokenPairModel? savedTokens;
  TokenPairModel? storedTokens;

  @override
  Future<void> saveTokens(TokenPairModel tokenPair) async {
    savedTokens = tokenPair;
  }

  @override
  Future<TokenPairModel?> getTokens() async => storedTokens;

  @override
  Future<void> clearTokens() async {
    savedTokens = null;
    storedTokens = null;
  }

  @override
  Future<String?> getAccessToken() async => storedTokens?.accessToken;

  @override
  Future<String?> getRefreshToken() async => storedTokens?.refreshToken;
}

class MockKakaoAuthService implements KakaoAuthService {
  String? kakaoToken;
  bool logoutCalled = false;
  Exception? exception;

  @override
  Future<String> loginWithKakao() async {
    if (exception != null) throw exception!;
    return kakaoToken!;
  }

  @override
  Future<void> logout() async {
    if (exception != null) throw exception!;
    logoutCalled = true;
  }
}

void main() {
  group('AuthRepositoryImpl', () {
    late AuthRepository repository;
    late MockAuthRemoteDataSource mockRemoteDataSource;
    late MockAuthLocalDataSource mockLocalDataSource;
    late MockKakaoAuthService mockKakaoAuthService;

    setUp(() {
      mockRemoteDataSource = MockAuthRemoteDataSource();
      mockLocalDataSource = MockAuthLocalDataSource();
      mockKakaoAuthService = MockKakaoAuthService();
      repository = AuthRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: mockLocalDataSource,
        kakaoAuthService: mockKakaoAuthService,
      );
    });

    group('loginWithKakao', () {
      test('should return TokenPair and save tokens on success', () async {
        const tokenPair = TokenPairModel(
          accessToken: 'access',
          refreshToken: 'refresh',
        );
        mockRemoteDataSource.loginResult = tokenPair;

        final result = await repository.loginWithKakao('kakao_token');

        expect(result, Right(tokenPair));
        expect(mockLocalDataSource.savedTokens, tokenPair);
      });

      test('should return AuthFailure on DioException', () async {
        mockRemoteDataSource.exception = DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 401,
          ),
        );

        final result = await repository.loginWithKakao('invalid_token');

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<AuthFailure>()),
          (_) => fail('Should be failure'),
        );
      });
    });

    group('loginWithKakaoSdk', () {
      test('should login with Kakao SDK and return TokenPair', () async {
        mockKakaoAuthService.kakaoToken = 'kakao_access_token';
        const tokenPair = TokenPairModel(
          accessToken: 'server_access',
          refreshToken: 'server_refresh',
        );
        mockRemoteDataSource.loginResult = tokenPair;

        final result = await repository.loginWithKakaoSdk();

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Should be success'), (token) {
          expect(token.accessToken, 'server_access');
          expect(token.refreshToken, 'server_refresh');
        });
      });

      test('should return KakaoLoginFailure when Kakao SDK fails', () async {
        mockKakaoAuthService.exception = Exception('Kakao login failed');

        final result = await repository.loginWithKakaoSdk();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<KakaoLoginFailure>()),
          (_) => fail('Should be failure'),
        );
      });
    });

    group('getCurrentMember', () {
      test('should return Member on success', () async {
        const member = MemberModel(
          id: 'member-123',
          nickname: '젤리',
          socialProvider: 'KAKAO',
          socialId: 'kakao-123456',
        );
        mockRemoteDataSource.memberResult = member;

        final result = await repository.getCurrentMember();

        expect(result, Right(member));
      });
    });

    group('logout', () {
      test('should logout from Kakao and clear tokens', () async {
        mockLocalDataSource.storedTokens = const TokenPairModel(
          accessToken: 'access',
          refreshToken: 'refresh',
        );

        final result = await repository.logout();

        expect(result.isRight(), isTrue);
        expect(mockKakaoAuthService.logoutCalled, isTrue);
        expect(mockLocalDataSource.storedTokens, isNull);
      });

      test('should clear tokens even if Kakao logout fails', () async {
        mockKakaoAuthService.exception = Exception('Kakao logout failed');
        mockLocalDataSource.storedTokens = const TokenPairModel(
          accessToken: 'access',
          refreshToken: 'refresh',
        );

        final result = await repository.logout();

        expect(result.isRight(), isTrue);
        expect(mockLocalDataSource.storedTokens, isNull);
      });
    });

    group('getStoredTokens', () {
      test('should return stored tokens', () async {
        const tokenPair = TokenPairModel(
          accessToken: 'access',
          refreshToken: 'refresh',
        );
        mockLocalDataSource.storedTokens = tokenPair;

        final result = await repository.getStoredTokens();

        expect(result, tokenPair);
      });

      test('should return null when no tokens stored', () async {
        mockLocalDataSource.storedTokens = null;

        final result = await repository.getStoredTokens();

        expect(result, isNull);
      });
    });

    group('clearStoredTokens', () {
      test('should clear stored tokens', () async {
        mockLocalDataSource.storedTokens = const TokenPairModel(
          accessToken: 'access',
          refreshToken: 'refresh',
        );

        await repository.clearStoredTokens();

        expect(mockLocalDataSource.storedTokens, isNull);
      });
    });
  });
}
