import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/auth/domain/usecases/login_with_kakao.dart';
import 'package:jellomark/features/auth/presentation/pages/login_page.dart';
import 'package:jellomark/features/auth/presentation/providers/auth_providers.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class MockAuthRepository implements AuthRepository {
  TokenPair? tokenPairResult;
  Failure? loginFailure;
  Completer<Either<Failure, TokenPair>>? completer;

  @override
  Future<Either<Failure, TokenPair>> loginWithKakaoSdk() async {
    if (completer != null) {
      return completer!.future;
    }
    if (loginFailure != null) return Left(loginFailure!);
    return Right(
      tokenPairResult ??
          const TokenPair(accessToken: 'access', refreshToken: 'refresh'),
    );
  }

  @override
  Future<Either<Failure, TokenPair>> loginWithKakao(
    String kakaoAccessToken,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TokenPair>> refreshToken(String refreshToken) async {
    throw UnimplementedError();
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
  group('LoginPage', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    Widget createLoginPage() {
      return ProviderScope(
        overrides: [
          loginWithKakaoUseCaseProvider.overrideWithValue(
            LoginWithKakaoUseCase(authRepository: mockAuthRepository),
          ),
        ],
        child: MaterialApp(
          home: const LoginPage(),
          routes: {'/home': (context) => const Scaffold(body: Text('Home'))},
        ),
      );
    }

    testWidgets('should render login page with app logo', (tester) async {
      await tester.pumpWidget(createLoginPage());

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('should display Kakao login button', (tester) async {
      await tester.pumpWidget(createLoginPage());

      expect(find.text('카카오로 시작하기'), findsOneWidget);
    });

    testWidgets('should show loading indicator when login is in progress', (
      tester,
    ) async {
      mockAuthRepository.completer = Completer<Either<Failure, TokenPair>>();

      await tester.pumpWidget(createLoginPage());

      await tester.tap(find.text('카카오로 시작하기'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      mockAuthRepository.completer!.complete(
        const Right(TokenPair(accessToken: 'access', refreshToken: 'refresh')),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('should navigate to home when login succeeds', (tester) async {
      mockAuthRepository.tokenPairResult = const TokenPair(
        accessToken: 'server_access',
        refreshToken: 'server_refresh',
      );

      await tester.pumpWidget(createLoginPage());

      await tester.tap(find.text('카카오로 시작하기'));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('should show error snackbar when login fails', (tester) async {
      mockAuthRepository.loginFailure = KakaoLoginFailure('로그인에 실패했습니다');

      await tester.pumpWidget(createLoginPage());

      await tester.tap(find.text('카카오로 시작하기'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should disable button when loading', (tester) async {
      mockAuthRepository.completer = Completer<Either<Failure, TokenPair>>();

      await tester.pumpWidget(createLoginPage());

      await tester.tap(find.text('카카오로 시작하기'));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      mockAuthRepository.completer!.complete(
        const Right(TokenPair(accessToken: 'access', refreshToken: 'refresh')),
      );
      await tester.pumpAndSettle();
    });

    group('UI Redesign', () {
      testWidgets('should have lavender gradient background', (tester) async {
        await tester.pumpWidget(createLoginPage());

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(LoginPage),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration as BoxDecoration).gradient != null,
            ),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.gradient, isA<LinearGradient>());
      });

      testWidgets('should have glass style kakao button with BackdropFilter', (tester) async {
        await tester.pumpWidget(createLoginPage());

        expect(find.byType(BackdropFilter), findsOneWidget);
      });

      testWidgets('should have kakao icon in login button', (tester) async {
        await tester.pumpWidget(createLoginPage());

        expect(find.byType(Image), findsWidgets);
      });

      testWidgets('should be scrollable to prevent keyboard overflow', (tester) async {
        await tester.pumpWidget(createLoginPage());

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });
  });
}
