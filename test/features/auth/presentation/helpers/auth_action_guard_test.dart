import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/models/token_pair_model.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/auth/presentation/helpers/auth_action_guard.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

const _kSampleMember = Member(
  id: 'm-1',
  nickname: '테스터123456',
  displayName: '테스터',
  socialProvider: 'KAKAO',
  socialId: 'kakao-1',
);

class _StubAuthRepository implements AuthRepository {
  TokenPair? stored;
  Either<Failure, Member> memberResult = const Right(_kSampleMember);
  int clearCallCount = 0;

  _StubAuthRepository(this.stored);

  @override
  Future<TokenPair?> getStoredTokens() async => stored;

  @override
  Future<Either<Failure, Member>> getCurrentMember() async => memberResult;

  @override
  Future<void> clearStoredTokens() async {
    clearCallCount++;
    stored = null;
  }

  @override
  Future<Either<Failure, TokenPair>> loginWithKakao(String kakaoAccessToken) async => throw UnimplementedError();
  @override
  Future<Either<Failure, TokenPair>> loginWithKakaoSdk() async => throw UnimplementedError();
  @override
  Future<Either<Failure, TokenPair>> loginWithApple(String identityToken, String? fullName) async => throw UnimplementedError();
  @override
  Future<Either<Failure, TokenPair>> loginWithAppleSdk() async => throw UnimplementedError();
  @override
  Future<Either<Failure, TokenPair>> refreshToken(String refreshToken) async => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> logout() async => const Right(null);
  @override
  Future<Either<Failure, void>> withdraw(String reason) async => const Right(null);
}

void main() {
  tearDown(() {
    if (sl.isRegistered<AuthRepository>()) {
      sl.unregister<AuthRepository>();
    }
  });

  Widget buildHarness(Future<bool> Function(BuildContext, WidgetRef) onTap) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) => ElevatedButton(
              onPressed: () async {
                final result = await onTap(context, ref);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result ? 'OK' : 'CANCEL')),
                  );
                }
              },
              child: const Text('진행'),
            ),
          ),
        ),
      ),
    );
  }

  group('ensureLoggedIn', () {
    testWidgets('returns true when tokens stored and backend accepts', (tester) async {
      sl.registerSingleton<AuthRepository>(
        _StubAuthRepository(
          const TokenPairModel(accessToken: 'a', refreshToken: 'b'),
        ),
      );

      await tester.pumpWidget(buildHarness((c, r) => ensureLoggedIn(c, r)));
      await tester.tap(find.text('진행'));
      await tester.pumpAndSettle();

      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('clears stale tokens and shows prompt when backend rejects', (tester) async {
      final repo = _StubAuthRepository(
        const TokenPairModel(accessToken: 'stale', refreshToken: 'stale'),
      )..memberResult = const Left(AuthFailure('토큰이 만료되었습니다'));
      sl.registerSingleton<AuthRepository>(repo);

      await tester.pumpWidget(buildHarness((c, r) => ensureLoggedIn(c, r)));
      await tester.tap(find.text('진행'));
      await tester.pumpAndSettle();

      expect(find.text('로그인이 필요해요'), findsOneWidget);
      expect(repo.clearCallCount, 1);
      expect(repo.stored, isNull);
    });

    testWidgets('shows guest login prompt when no tokens', (tester) async {
      sl.registerSingleton<AuthRepository>(_StubAuthRepository(null));

      await tester.pumpWidget(buildHarness(
        (c, r) => ensureLoggedIn(c, r, description: '예약하려면 로그인이 필요해요.'),
      ));
      await tester.tap(find.text('진행'));
      await tester.pumpAndSettle();

      expect(find.text('로그인이 필요해요'), findsOneWidget);
      expect(find.text('예약하려면 로그인이 필요해요.'), findsOneWidget);
    });

    testWidgets('returns false when guest dismisses prompt', (tester) async {
      sl.registerSingleton<AuthRepository>(_StubAuthRepository(null));

      await tester.pumpWidget(buildHarness((c, r) => ensureLoggedIn(c, r)));
      await tester.tap(find.text('진행'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('닫기'));
      await tester.pumpAndSettle();

      expect(find.text('CANCEL'), findsOneWidget);
    });
  });
}
