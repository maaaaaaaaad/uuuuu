import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/datasources/kakao_auth_service.dart';
import 'package:jellomark/features/auth/data/models/token_pair_model.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/auth/domain/usecases/login_with_kakao.dart';
import 'package:jellomark/features/auth/presentation/pages/login_page.dart';
import 'package:jellomark/features/auth/presentation/providers/auth_providers.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class MockKakaoAuthService implements KakaoAuthService {
  String? kakaoToken;
  Exception? exception;

  @override
  Future<String> loginWithKakao() async {
    if (exception != null) throw exception!;
    return kakaoToken ?? 'mock_token';
  }

  @override
  Future<void> logout() async {}
}

class MockAuthRepository implements AuthRepository {
  TokenPair? loginResult;
  Failure? failure;

  @override
  Future<Either<Failure, TokenPair>> loginWithKakao(
    String kakaoAccessToken,
  ) async {
    if (failure != null) return Left(failure!);
    return Right(
      loginResult ??
          const TokenPairModel(accessToken: 'access', refreshToken: 'refresh'),
    );
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
    return const Right(null);
  }
}

void main() {
  group('LoginPage', () {
    late MockKakaoAuthService mockKakaoService;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockKakaoService = MockKakaoAuthService();
      mockRepository = MockAuthRepository();
    });

    Widget createLoginPage() {
      return ProviderScope(
        overrides: [
          loginWithKakaoUseCaseProvider.overrideWithValue(
            LoginWithKakaoUseCase(
              kakaoAuthService: mockKakaoService,
              authRepository: mockRepository,
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
    });

    testWidgets('should display Kakao login button', (tester) async {
      await tester.pumpWidget(createLoginPage());

      expect(find.text('카카오로 시작하기'), findsOneWidget);
    });

    testWidgets('should show loading indicator when login in progress', (
      tester,
    ) async {
      await tester.pumpWidget(createLoginPage());

      await tester.tap(find.text('카카오로 시작하기'));
      await tester.pump();
    });

    testWidgets('should show error message on login failure', (tester) async {
      mockKakaoService.exception = Exception('Login failed');

      await tester.pumpWidget(createLoginPage());

      await tester.tap(find.text('카카오로 시작하기'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
