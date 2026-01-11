import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';
import 'package:jellomark/features/member/domain/repositories/member_repository.dart';
import 'package:jellomark/features/member/domain/usecases/get_current_member.dart';
import 'package:jellomark/features/member/domain/usecases/update_member_profile.dart';
import 'package:jellomark/features/member/presentation/pages/profile_page.dart';
import 'package:jellomark/features/member/presentation/providers/member_providers.dart';

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
}

class MockMemberRepository implements MemberRepository {
  Member? memberResult;
  Failure? failure;

  @override
  Future<Either<Failure, Member>> updateProfile({
    required String nickname,
  }) async {
    if (failure != null) return Left(failure!);
    return Right(memberResult!);
  }
}

void main() {
  group('ProfilePage', () {
    late MockAuthRepository mockAuthRepository;
    late MockMemberRepository mockMemberRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockMemberRepository = MockMemberRepository();
    });

    Widget createProfilePage() {
      return ProviderScope(
        overrides: [
          getCurrentMemberUseCaseProvider.overrideWithValue(
            GetCurrentMember(repository: mockAuthRepository),
          ),
          updateMemberProfileUseCaseProvider.overrideWithValue(
            UpdateMemberProfile(repository: mockMemberRepository),
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
        nickname: '테스트유저',
        email: 'test@test.com',
      );

      await tester.pumpWidget(createProfilePage());
      await tester.pumpAndSettle();

      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('should display member nickname', (tester) async {
      mockAuthRepository.memberResult = const Member(
        id: '1',
        nickname: '테스트유저',
        email: 'test@test.com',
      );

      await tester.pumpWidget(createProfilePage());
      await tester.pumpAndSettle();

      expect(find.text('테스트유저'), findsOneWidget);
    });

    testWidgets('should display member email', (tester) async {
      mockAuthRepository.memberResult = const Member(
        id: '1',
        nickname: '테스트유저',
        email: 'test@test.com',
      );

      await tester.pumpWidget(createProfilePage());
      await tester.pumpAndSettle();

      expect(find.text('test@test.com'), findsOneWidget);
    });

    testWidgets('should show loading indicator while loading', (tester) async {
      mockAuthRepository.memberResult = const Member(
        id: '1',
        nickname: '테스트유저',
        email: 'test@test.com',
      );

      await tester.pumpWidget(createProfilePage());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display logout button', (tester) async {
      mockAuthRepository.memberResult = const Member(
        id: '1',
        nickname: '테스트유저',
        email: 'test@test.com',
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
  });
}
