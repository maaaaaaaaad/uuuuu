import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/datasources/kakao_auth_service.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/auth/domain/usecases/login_with_kakao.dart';
import 'package:jellomark/features/auth/presentation/pages/login_page.dart';
import 'package:jellomark/features/auth/presentation/providers/auth_providers.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class MockKakaoAuthService implements KakaoAuthService {
  String? accessToken;
  Exception? exception;
  Completer<String>? completer;

  @override
  Future<String> loginWithKakao() async {
    if (completer != null) {
      return completer!.future;
    }
    if (exception != null) throw exception!;
    return accessToken ?? 'mock_kakao_token';
  }

  @override
  Future<void> logout() async {}
}

class MockAuthRepository implements AuthRepository {
  TokenPair? tokenPairResult;
  Failure? loginFailure;

  @override
  Future<Either<Failure, TokenPair>> loginWithKakao(
    String kakaoAccessToken,
  ) async {
    if (loginFailure != null) return Left(loginFailure!);
    return Right(
      tokenPairResult ??
          const TokenPair(accessToken: 'access', refreshToken: 'refresh'),
    );
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
}

void main() {
  group('LoginPage', () {
    late MockKakaoAuthService mockKakaoService;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockKakaoService = MockKakaoAuthService();
      mockAuthRepository = MockAuthRepository();
    });

    Widget createLoginPage() {
      return ProviderScope(
        overrides: [
          loginWithKakaoUseCaseProvider.overrideWithValue(
            LoginWithKakaoUseCase(
              kakaoAuthService: mockKakaoService,
              authRepository: mockAuthRepository,
            ),
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
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should display Kakao login button', (tester) async {
      await tester.pumpWidget(createLoginPage());

      expect(find.text('카카오로 시작하기'), findsOneWidget);
    });

    testWidgets('should show loading indicator when login is in progress', (
      tester,
    ) async {
      mockKakaoService.completer = Completer<String>();

      await tester.pumpWidget(createLoginPage());

      await tester.tap(find.text('카카오로 시작하기'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      mockKakaoService.completer!.complete('test_token');
      await tester.pumpAndSettle();
    });

    testWidgets('should navigate to home when login succeeds', (tester) async {
      mockKakaoService.accessToken = 'test_kakao_token';
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
      mockKakaoService.exception = Exception('로그인에 실패했습니다');

      await tester.pumpWidget(createLoginPage());

      await tester.tap(find.text('카카오로 시작하기'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should disable button when loading', (tester) async {
      mockKakaoService.completer = Completer<String>();

      await tester.pumpWidget(createLoginPage());

      await tester.tap(find.text('카카오로 시작하기'));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      mockKakaoService.completer!.complete('test_token');
      await tester.pumpAndSettle();
    });
  });
}
