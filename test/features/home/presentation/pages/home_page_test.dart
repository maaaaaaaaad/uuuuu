import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/home/presentation/pages/home_page.dart';
import 'package:jellomark/features/home/presentation/widgets/home_tab.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';
import 'package:jellomark/features/member/domain/repositories/member_repository.dart';
import 'package:jellomark/features/member/domain/usecases/get_current_member.dart';
import 'package:jellomark/features/member/domain/usecases/update_member_profile.dart';
import 'package:jellomark/features/member/presentation/providers/member_providers.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, Member>> getCurrentMember() async {
    return const Right(
      Member(
        id: '1',
        nickname: '테스트',
        socialProvider: 'KAKAO',
        socialId: 'test-kakao-id',
      ),
    );
  }

  @override
  Future<Either<Failure, TokenPair>> loginWithKakaoSdk() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TokenPair>> loginWithKakao(String kakaoAccessToken) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TokenPair>> refreshToken(String refreshToken) {
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

class MockMemberRepository implements MemberRepository {
  @override
  Future<Either<Failure, Member>> updateProfile({
    required String nickname,
  }) async {
    return const Right(
      Member(
        id: '1',
        nickname: '테스트',
        socialProvider: 'KAKAO',
        socialId: 'test-kakao-id',
      ),
    );
  }
}

void main() {
  group('HomePage', () {
    late MockAuthRepository mockAuthRepository;
    late MockMemberRepository mockMemberRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockMemberRepository = MockMemberRepository();
    });

    Widget createHomePage() {
      return ProviderScope(
        overrides: [
          getCurrentMemberUseCaseProvider.overrideWithValue(
            GetCurrentMember(repository: mockAuthRepository),
          ),
          updateMemberProfileUseCaseProvider.overrideWithValue(
            UpdateMemberProfile(repository: mockMemberRepository),
          ),
        ],
        child: const MaterialApp(home: HomePage()),
      );
    }

    testWidgets('should render home page', (tester) async {
      await tester.pumpWidget(createHomePage());

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should display bottom navigation bar', (tester) async {
      await tester.pumpWidget(createHomePage());

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('should have correct navigation items', (tester) async {
      await tester.pumpWidget(createHomePage());

      expect(find.text('홈'), findsOneWidget);
      expect(find.text('검색'), findsOneWidget);
      expect(find.text('마이'), findsOneWidget);
    });

    testWidgets('should switch tabs when navigation item tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createHomePage());

      await tester.tap(find.text('검색'));
      await tester.pumpAndSettle();

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.currentIndex, 1);
    });

    testWidgets('should show different content for each tab', (tester) async {
      await tester.pumpWidget(createHomePage());

      expect(find.byType(HomeTab), findsOneWidget);

      await tester.tap(find.text('검색'));
      await tester.pumpAndSettle();
      expect(find.text('검색 탭'), findsOneWidget);

      await tester.tap(find.text('마이'));
      await tester.pumpAndSettle();
      expect(find.text('프로필'), findsOneWidget);
    });
  });
}
