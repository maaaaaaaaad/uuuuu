import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';
import 'package:jellomark/features/member/domain/usecases/withdraw_member.dart';
import 'package:jellomark/features/member/presentation/pages/withdrawal_page.dart';
import 'package:jellomark/features/member/presentation/providers/withdrawal_provider.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, void>> withdraw(String reason) async =>
      const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getStoredTokens) return Future.value(null);
    if (invocation.memberName == #clearStoredTokens) return Future.value();
    return super.noSuchMethod(invocation);
  }

  @override
  Future<Either<Failure, TokenPair>> loginWithKakaoSdk() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, TokenPair>> loginWithKakao(String kakaoAccessToken) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, TokenPair>> refreshToken(String refreshToken) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Member>> getCurrentMember() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> logout() => throw UnimplementedError();

  @override
  Future<TokenPair?> getStoredTokens() async => null;

  @override
  Future<void> clearStoredTokens() async {}
}

void main() {
  group('WithdrawalPage', () {
    testWidgets('첫 화면에 안내 문구와 다음 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            withdrawMemberUseCaseProvider.overrideWithValue(
              WithdrawMember(repository: _FakeAuthRepository()),
            ),
          ],
          child: const MaterialApp(home: WithdrawalPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('회원 탈퇴'), findsOneWidget);
      expect(find.text('회원 탈퇴 시 삭제되는 정보'), findsOneWidget);
      expect(find.text('다음'), findsOneWidget);
    });
  });
}
