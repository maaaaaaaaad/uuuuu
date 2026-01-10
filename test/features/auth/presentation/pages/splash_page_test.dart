import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:jellomark/features/auth/data/models/member_model.dart';
import 'package:jellomark/features/auth/data/models/token_pair_model.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/auth/domain/usecases/check_auth_status.dart';
import 'package:jellomark/features/auth/presentation/pages/splash_page.dart';
import 'package:jellomark/features/auth/presentation/providers/auth_providers.dart';
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
  Failure? memberFailure;

  @override
  Future<Either<Failure, TokenPair>> loginWithKakao(
    String kakaoAccessToken,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TokenPair>> refreshToken(String refreshToken) async {
    return const Right(TokenPairModel(accessToken: 'new', refreshToken: 'new'));
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
  group('SplashPage', () {
    late MockAuthLocalDataSource mockLocalDataSource;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockLocalDataSource = MockAuthLocalDataSource();
      mockRepository = MockAuthRepository();
    });

    Widget createSplashPage() {
      return ProviderScope(
        overrides: [
          checkAuthStatusUseCaseProvider.overrideWithValue(
            CheckAuthStatusUseCase(
              localDataSource: mockLocalDataSource,
              authRepository: mockRepository,
            ),
          ),
        ],
        child: MaterialApp(
          home: const SplashPage(),
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login')),
            '/home': (context) => const Scaffold(body: Text('Home')),
          },
        ),
      );
    }

    testWidgets('should navigate to login when no token stored', (
      tester,
    ) async {
      mockLocalDataSource.storedTokens = null;

      await tester.pumpWidget(createSplashPage());
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should navigate to home when token is valid', (tester) async {
      mockLocalDataSource.storedTokens = const TokenPairModel(
        accessToken: 'valid_access',
        refreshToken: 'valid_refresh',
      );
      mockRepository.memberResult = const MemberModel(
        id: 'member-123',
        nickname: '젤리',
        email: 'jelly@example.com',
      );

      await tester.pumpWidget(createSplashPage());
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('should navigate to login when token is invalid', (
      tester,
    ) async {
      mockLocalDataSource.storedTokens = const TokenPairModel(
        accessToken: 'invalid_access',
        refreshToken: 'invalid_refresh',
      );
      mockRepository.memberFailure = const AuthFailure('Token expired');

      await tester.pumpWidget(createSplashPage());
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });
  });
}
