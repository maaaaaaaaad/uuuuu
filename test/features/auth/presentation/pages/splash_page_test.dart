import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/models/member_model.dart';
import 'package:jellomark/features/auth/data/models/token_pair_model.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/auth/domain/usecases/check_auth_status.dart';
import 'package:jellomark/features/auth/presentation/pages/splash_page.dart';
import 'package:jellomark/features/auth/presentation/providers/auth_providers.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class MockAuthRepository implements AuthRepository {
  TokenPair? storedTokens;
  Member? memberResult;
  Failure? memberFailure;
  TokenPair? refreshResult;
  Failure? refreshFailure;

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
    return Right(
      refreshResult ??
          const TokenPairModel(accessToken: 'new', refreshToken: 'new'),
    );
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
    storedTokens = null;
  }
}

void main() {
  group('SplashPage', () {
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
    });

    Widget createSplashPage() {
      return ProviderScope(
        overrides: [
          checkAuthStatusUseCaseProvider.overrideWithValue(
            CheckAuthStatusUseCase(authRepository: mockRepository),
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
      mockRepository.storedTokens = null;

      await tester.pumpWidget(createSplashPage());
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should navigate to home when token is valid', (tester) async {
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

      await tester.pumpWidget(createSplashPage());
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('should navigate to login when token is invalid', (
      tester,
    ) async {
      mockRepository.storedTokens = const TokenPairModel(
        accessToken: 'invalid_access',
        refreshToken: 'invalid_refresh',
      );
      mockRepository.memberFailure = const AuthFailure('Token expired');
      mockRepository.refreshFailure = const AuthFailure('Refresh failed');

      await tester.pumpWidget(createSplashPage());
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should have keyboard warmup TextField', (
      tester,
    ) async {
      mockRepository.storedTokens = null;

      await tester.pumpWidget(createSplashPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final warmupTextField = find.byKey(
        const Key('keyboard_warmup_textfield'),
        skipOffstage: false,
      );
      expect(warmupTextField, findsOneWidget);
    });
  });
}
