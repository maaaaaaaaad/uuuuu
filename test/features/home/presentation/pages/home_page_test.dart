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
import 'package:jellomark/features/reservation/domain/usecases/get_my_reservations_usecase.dart';
import 'package:jellomark/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:jellomark/features/search/domain/usecases/manage_search_history_usecase.dart';
import 'package:jellomark/features/search/presentation/providers/search_provider.dart';
import 'package:jellomark/features/location/domain/repositories/location_repository.dart';
import 'package:jellomark/features/location/domain/repositories/location_setting_repository.dart';
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';
import 'package:jellomark/features/location/presentation/providers/location_setting_provider.dart';
import 'package:jellomark/shared/widgets/glass_bottom_nav_bar.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_http_client.dart';

class MockGetFilteredShopsUseCase extends Mock
    implements GetFilteredShopsUseCase {}

class MockManageSearchHistoryUseCase extends Mock
    implements ManageSearchHistoryUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class FakeBeautyShopFilter extends Fake implements BeautyShopFilter {}

class MockLocationSettingRepository extends Mock
    implements LocationSettingRepository {}

class MockLocationRepository extends Mock implements LocationRepository {}

class MockGetMyReservationsUseCase extends Mock
    implements GetMyReservationsUseCase {}

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
    late MockLocationSettingRepository mockLocationSettingRepository;
    late MockLocationRepository mockLocationRepository;
    late MockGetMyReservationsUseCase mockGetMyReservationsUseCase;

    setUpAll(() {
      HttpOverrides.global = MockHttpOverrides();
      registerFallbackValue(FakeBeautyShopFilter());
    });

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockGetFilteredShopsUseCase = MockGetFilteredShopsUseCase();
      mockGetCategoriesUseCase = MockGetCategoriesUseCase();
      mockManageSearchHistoryUseCase = MockManageSearchHistoryUseCase();
      mockLocationSettingRepository = MockLocationSettingRepository();
      mockLocationRepository = MockLocationRepository();
      mockGetMyReservationsUseCase = MockGetMyReservationsUseCase();

      when(() => mockGetMyReservationsUseCase())
          .thenAnswer((_) async => const Right([]));
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
      when(() => mockLocationSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => true);
      when(() => mockLocationRepository.checkPermissionStatus())
          .thenAnswer((_) async => LocationPermissionResult.granted);
    });

    Widget createHomePage({
      LocationPermissionResult permissionStatus = LocationPermissionResult.granted,
    }) {
      when(() => mockLocationRepository.checkPermissionStatus())
          .thenAnswer((_) async => permissionStatus);
      when(() => mockLocationSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => permissionStatus == LocationPermissionResult.granted);

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
          currentLocationProvider.overrideWith((ref) async => null),
          locationSettingRepositoryProvider.overrideWithValue(
            mockLocationSettingRepository,
          ),
          locationRepositoryForSettingProvider.overrideWithValue(
            mockLocationRepository,
          ),
          getMyReservationsUseCaseProvider.overrideWithValue(
            mockGetMyReservationsUseCase,
          ),
        ],
        child: const MaterialApp(home: HomePage()),
      );
    }

    testWidgets('should render home page', (tester) async {
      await tester.pumpWidget(createHomePage());

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should display GlassBottomNavBar', (tester) async {
      await tester.pumpWidget(createHomePage());

      expect(find.byType(GlassBottomNavBar), findsOneWidget);
    });

    testWidgets('should have correct navigation icons', (tester) async {
      await tester.pumpWidget(createHomePage());

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('should switch tabs when navigation item tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createHomePage());

      await tester.tap(find.byIcon(Icons.search_outlined));
      await tester.pumpAndSettle();

      final bottomNav = tester.widget<GlassBottomNavBar>(
        find.byType(GlassBottomNavBar),
      );
      expect(bottomNav.currentIndex, 1);
    });

    testWidgets('should show different content for each tab', (tester) async {
      await tester.pumpWidget(createHomePage());

      expect(find.byType(HomeTab), findsOneWidget);

      await tester.tap(find.byIcon(Icons.search_outlined));
      await tester.pumpAndSettle();
      expect(find.text('취소'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();
      expect(find.text('프로필'), findsOneWidget);
    });

    testWidgets('should have lavender gradient background', (tester) async {
      await tester.pumpWidget(createHomePage());

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(HomePage),
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

    group('Tab Transition Animation', () {
      testWidgets('should have AnimatedSwitcher for tab transitions', (
        tester,
      ) async {
        await tester.pumpWidget(createHomePage());

        expect(find.byType(AnimatedSwitcher), findsOneWidget);
      });

      testWidgets('should animate when switching tabs', (tester) async {
        await tester.pumpWidget(createHomePage());

        expect(find.byType(HomeTab), findsOneWidget);

        await tester.tap(find.byIcon(Icons.search_outlined));
        await tester.pump();

        expect(find.byType(FadeTransition), findsWidgets);
      });
    });

    group('Location Permission Alert', () {
      testWidgets('should show location permission alert when permission denied', (
        tester,
      ) async {
        await tester.pumpWidget(
          createHomePage(permissionStatus: LocationPermissionResult.denied),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('젤로마크는 위치 기반 서비스이므로 위치 정보 제공에 동의가 꼭 필요해요'),
          findsOneWidget,
        );
      });

      testWidgets('should not show alert when permission granted', (
        tester,
      ) async {
        await tester.pumpWidget(
          createHomePage(permissionStatus: LocationPermissionResult.granted),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('젤로마크는 위치 기반 서비스이므로 위치 정보 제공에 동의가 꼭 필요해요'),
          findsNothing,
        );
      });

      testWidgets('should close alert when cancel button tapped', (
        tester,
      ) async {
        await tester.pumpWidget(
          createHomePage(permissionStatus: LocationPermissionResult.denied),
        );
        await tester.pumpAndSettle();

        expect(find.text('취소'), findsOneWidget);

        await tester.tap(find.text('취소'));
        await tester.pumpAndSettle();

        expect(
          find.text('젤로마크는 위치 기반 서비스이므로 위치 정보 제공에 동의가 꼭 필요해요'),
          findsNothing,
        );
      });

      testWidgets('should not show alert again after cancel in same session', (
        tester,
      ) async {
        await tester.pumpWidget(
          createHomePage(permissionStatus: LocationPermissionResult.denied),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('젤로마크는 위치 기반 서비스이므로 위치 정보 제공에 동의가 꼭 필요해요'),
          findsOneWidget,
        );

        await tester.tap(find.text('취소'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.search_outlined));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.home_outlined));
        await tester.pumpAndSettle();

        expect(
          find.text('젤로마크는 위치 기반 서비스이므로 위치 정보 제공에 동의가 꼭 필요해요'),
          findsNothing,
        );
      });
    });
  });
}
