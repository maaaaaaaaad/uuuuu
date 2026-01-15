import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_beauty_shops.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_filtered_shops_usecase.dart';
import 'package:jellomark/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:jellomark/features/home/presentation/pages/home_page.dart';
import 'package:jellomark/features/home/presentation/providers/home_provider.dart';
import 'package:jellomark/features/home/presentation/widgets/home_tab.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';
import 'package:jellomark/features/member/domain/usecases/get_current_member.dart';
import 'package:jellomark/features/member/presentation/providers/member_providers.dart';
import 'package:jellomark/features/search/domain/usecases/manage_search_history_usecase.dart';
import 'package:jellomark/features/search/presentation/providers/search_provider.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_http_client.dart';

class MockGetFilteredShopsUseCase extends Mock
    implements GetFilteredShopsUseCase {}

class MockManageSearchHistoryUseCase extends Mock
    implements ManageSearchHistoryUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class FakeBeautyShopFilter extends Fake implements BeautyShopFilter {}

class MockAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, Member>> getCurrentMember() async {
    return const Right(
      Member(
        id: '1',
        nickname: '테스트123456',
        displayName: '테스트',
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

void main() {
  group('HomePage', () {
    late MockAuthRepository mockAuthRepository;
    late MockGetFilteredShopsUseCase mockGetFilteredShopsUseCase;
    late MockGetCategoriesUseCase mockGetCategoriesUseCase;
    late MockManageSearchHistoryUseCase mockManageSearchHistoryUseCase;

    setUpAll(() {
      HttpOverrides.global = MockHttpOverrides();
      registerFallbackValue(FakeBeautyShopFilter());
    });

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockGetFilteredShopsUseCase = MockGetFilteredShopsUseCase();
      mockGetCategoriesUseCase = MockGetCategoriesUseCase();
      mockManageSearchHistoryUseCase = MockManageSearchHistoryUseCase();

      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Right([]));
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => const Right(
          PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
        ),
      );
      when(
        () => mockManageSearchHistoryUseCase.getSearchHistory(),
      ).thenAnswer((_) async => const Right([]));
    });

    Widget createHomePage() {
      return ProviderScope(
        overrides: [
          getCurrentMemberUseCaseProvider.overrideWithValue(
            GetCurrentMember(repository: mockAuthRepository),
          ),
          getFilteredShopsUseCaseProvider.overrideWithValue(
            mockGetFilteredShopsUseCase,
          ),
          getCategoriesUseCaseProvider.overrideWithValue(
            mockGetCategoriesUseCase,
          ),
          manageSearchHistoryUseCaseProvider.overrideWithValue(
            mockManageSearchHistoryUseCase,
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
      expect(find.text('취소'), findsOneWidget);

      await tester.tap(find.text('마이'));
      await tester.pumpAndSettle();
      expect(find.text('프로필'), findsOneWidget);
    });
  });
}
