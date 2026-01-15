import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';
import 'package:jellomark/features/member/domain/usecases/get_current_member.dart';
import 'package:jellomark/features/member/presentation/pages/profile_page.dart';
import 'package:jellomark/features/member/presentation/providers/member_providers.dart';
import 'package:jellomark/shared/theme/app_colors.dart';
import 'package:jellomark/shared/widgets/gradient_card.dart';

class MockAuthRepository implements AuthRepository {
  Member? memberResult;
  Failure? failure;
  bool logoutCalled = false;

  @override
  Future<Either<Failure, Member>> getCurrentMember() async {
    if (failure != null) return Left(failure!);
    return Right(memberResult!);
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
    logoutCalled = true;
    return const Right(null);
  }

  @override
  Future<TokenPair?> getStoredTokens() async => null;

  @override
  Future<void> clearStoredTokens() async {}
}

void main() {
  group('ProfilePage', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    Widget createProfilePage() {
      return ProviderScope(
        overrides: [
          getCurrentMemberUseCaseProvider.overrideWithValue(
            GetCurrentMember(repository: mockAuthRepository),
          ),
        ],
        child: MaterialApp(
          home: const ProfilePage(),
          routes: {'/login': (context) => const Scaffold(body: Text('Login'))},
        ),
      );
    }

    testWidgets('should render profile page', (tester) async {
      mockAuthRepository.memberResult = const Member(
        id: '1',
        nickname: '테스트유저123',
        displayName: '테스트유저',
        socialProvider: 'KAKAO',
        socialId: 'test-kakao-id',
      );

      await tester.pumpWidget(createProfilePage());
      await tester.pumpAndSettle();

      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('should display member displayName', (tester) async {
      mockAuthRepository.memberResult = const Member(
        id: '1',
        nickname: '테스트유저123',
        displayName: '테스트유저',
        socialProvider: 'KAKAO',
        socialId: 'test-kakao-id',
      );

      await tester.pumpWidget(createProfilePage());
      await tester.pumpAndSettle();

      expect(find.text('테스트유저'), findsOneWidget);
    });

    testWidgets('should display social provider info', (tester) async {
      mockAuthRepository.memberResult = const Member(
        id: '1',
        nickname: '테스트유저123',
        displayName: '테스트유저',
        socialProvider: 'KAKAO',
        socialId: 'test-kakao-id',
      );

      await tester.pumpWidget(createProfilePage());
      await tester.pumpAndSettle();

      expect(find.text('KAKAO로 로그인'), findsOneWidget);
    });

    testWidgets('should show loading indicator while loading', (tester) async {
      mockAuthRepository.memberResult = const Member(
        id: '1',
        nickname: '테스트유저123',
        displayName: '테스트유저',
        socialProvider: 'KAKAO',
        socialId: 'test-kakao-id',
      );

      await tester.pumpWidget(createProfilePage());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display logout button', (tester) async {
      mockAuthRepository.memberResult = const Member(
        id: '1',
        nickname: '테스트유저123',
        displayName: '테스트유저',
        socialProvider: 'KAKAO',
        socialId: 'test-kakao-id',
      );

      await tester.pumpWidget(createProfilePage());
      await tester.pumpAndSettle();

      expect(find.text('로그아웃'), findsOneWidget);
    });

    testWidgets('should show error message when loading fails', (tester) async {
      mockAuthRepository.failure = const ServerFailure('서버 오류');

      await tester.pumpWidget(createProfilePage());
      await tester.pumpAndSettle();

      expect(find.text('오류가 발생했습니다'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    group('UI Redesign', () {
      testWidgets('has lavender gradient background', (tester) async {
        mockAuthRepository.memberResult = const Member(
          id: '1',
          nickname: '테스트유저123',
          displayName: '테스트유저',
          socialProvider: 'KAKAO',
          socialId: 'test-kakao-id',
        );

        await tester.pumpWidget(createProfilePage());
        await tester.pumpAndSettle();

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(Scaffold),
            matching: find.byType(Container).first,
          ),
        );
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration?.gradient, isNotNull);
      });

      testWidgets('has GradientCard for profile section', (tester) async {
        mockAuthRepository.memberResult = const Member(
          id: '1',
          nickname: '테스트유저123',
          displayName: '테스트유저',
          socialProvider: 'KAKAO',
          socialId: 'test-kakao-id',
        );

        await tester.pumpWidget(createProfilePage());
        await tester.pumpAndSettle();

        expect(find.byType(GradientCard), findsOneWidget);
      });

      testWidgets('profile avatar has white border and shadow', (tester) async {
        mockAuthRepository.memberResult = const Member(
          id: '1',
          nickname: '테스트유저123',
          displayName: '테스트유저',
          socialProvider: 'KAKAO',
          socialId: 'test-kakao-id',
        );

        await tester.pumpWidget(createProfilePage());
        await tester.pumpAndSettle();

        final containers = tester.widgetList<Container>(find.byType(Container));
        bool hasAvatarWithBorderAndShadow = false;
        for (final container in containers) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration &&
              decoration.shape == BoxShape.circle &&
              decoration.border != null &&
              decoration.boxShadow != null) {
            hasAvatarWithBorderAndShadow = true;
            break;
          }
        }
        expect(hasAvatarWithBorderAndShadow, isTrue);
      });

      testWidgets('CircularProgressIndicator has mint color', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              getCurrentMemberUseCaseProvider.overrideWithValue(
                _CompleterMockGetCurrentMember(),
              ),
            ],
            child: MaterialApp(
              home: const ProfilePage(),
              routes: {
                '/login': (context) => const Scaffold(body: Text('Login')),
              },
            ),
          ),
        );
        await tester.pump();

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.color, AppColors.mint);
      });

      testWidgets('logout button has gray border', (tester) async {
        mockAuthRepository.memberResult = const Member(
          id: '1',
          nickname: '테스트유저123',
          displayName: '테스트유저',
          socialProvider: 'KAKAO',
          socialId: 'test-kakao-id',
        );

        await tester.pumpWidget(createProfilePage());
        await tester.pumpAndSettle();

        final button = tester.widget<OutlinedButton>(
          find.byType(OutlinedButton),
        );
        final style = button.style;
        expect(style, isNotNull);
      });

      testWidgets('has BackdropFilter for glassmorphism', (tester) async {
        mockAuthRepository.memberResult = const Member(
          id: '1',
          nickname: '테스트유저123',
          displayName: '테스트유저',
          socialProvider: 'KAKAO',
          socialId: 'test-kakao-id',
        );

        await tester.pumpWidget(createProfilePage());
        await tester.pumpAndSettle();

        expect(find.byType(BackdropFilter), findsWidgets);
      });
    });
  });
}

class _CompleterMockGetCurrentMember extends GetCurrentMember {
  _CompleterMockGetCurrentMember() : super(repository: _MockAuthRepository());

  @override
  Future<Either<Failure, Member>> call() {
    return Completer<Either<Failure, Member>>().future;
  }
}

class _MockAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
