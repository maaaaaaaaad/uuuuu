import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';
import 'package:jellomark/features/recent_shops/domain/entities/recent_shop.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/add_recent_shop_usecase.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/clear_recent_shops_usecase.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/get_recent_shops_usecase.dart';
import 'package:jellomark/features/recent_shops/presentation/pages/recent_shops_page.dart';
import 'package:jellomark/features/recent_shops/presentation/providers/recent_shops_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetRecentShopsUseCase extends Mock implements GetRecentShopsUseCase {}

class MockAddRecentShopUseCase extends Mock implements AddRecentShopUseCase {}

class MockClearRecentShopsUseCase extends Mock
    implements ClearRecentShopsUseCase {}

void main() {
  late MockGetRecentShopsUseCase mockGetRecentShopsUseCase;
  late MockAddRecentShopUseCase mockAddRecentShopUseCase;
  late MockClearRecentShopsUseCase mockClearRecentShopsUseCase;

  setUp(() {
    mockGetRecentShopsUseCase = MockGetRecentShopsUseCase();
    mockAddRecentShopUseCase = MockAddRecentShopUseCase();
    mockClearRecentShopsUseCase = MockClearRecentShopsUseCase();
  });

  final tRecentShop = RecentShop(
    shopId: 'shop-1',
    shopName: 'Test Shop',
    thumbnailUrl: null,
    address: 'Test Address',
    rating: 4.5,
    viewedAt: DateTime.now().subtract(const Duration(hours: 2)),
  );

  final tRecentShops = [tRecentShop];

  Widget createRecentShopsPage() {
    return ProviderScope(
      overrides: [
        getRecentShopsUseCaseProvider
            .overrideWithValue(mockGetRecentShopsUseCase),
        addRecentShopUseCaseProvider.overrideWithValue(mockAddRecentShopUseCase),
        clearRecentShopsUseCaseProvider
            .overrideWithValue(mockClearRecentShopsUseCase),
        currentLocationProvider.overrideWith((ref) async => null),
      ],
      child: const MaterialApp(
        home: RecentShopsPage(),
      ),
    );
  }

  group('RecentShopsPage', () {
    testWidgets('should render recent shops page', (tester) async {
      when(() => mockGetRecentShopsUseCase())
          .thenAnswer((_) async => Right(tRecentShops));

      await tester.pumpWidget(createRecentShopsPage());
      await tester.pumpAndSettle();

      expect(find.byType(RecentShopsPage), findsOneWidget);
    });

    testWidgets('should display header with title', (tester) async {
      when(() => mockGetRecentShopsUseCase())
          .thenAnswer((_) async => Right(tRecentShops));

      await tester.pumpWidget(createRecentShopsPage());
      await tester.pumpAndSettle();

      expect(find.text('최근 본 샵'), findsOneWidget);
    });

    testWidgets('should show loading state during initial load', (tester) async {
      when(() => mockGetRecentShopsUseCase()).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 100),
          () => Right(tRecentShops),
        ),
      );

      await tester.pumpWidget(createRecentShopsPage());
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('should display recent shops when loaded', (tester) async {
      when(() => mockGetRecentShopsUseCase())
          .thenAnswer((_) async => Right(tRecentShops));

      await tester.pumpWidget(createRecentShopsPage());
      await tester.pumpAndSettle();

      expect(find.text('Test Shop'), findsOneWidget);
      expect(find.text('Test Address'), findsOneWidget);
    });

    testWidgets('should display empty state when no recent shops',
        (tester) async {
      when(() => mockGetRecentShopsUseCase())
          .thenAnswer((_) async => const Right(<RecentShop>[]));

      await tester.pumpWidget(createRecentShopsPage());
      await tester.pumpAndSettle();

      expect(find.text('최근 본 샵이 없습니다'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('should display error state when loading fails',
        (tester) async {
      when(() => mockGetRecentShopsUseCase())
          .thenAnswer((_) async => const Left(CacheFailure('캐시 오류')));

      await tester.pumpWidget(createRecentShopsPage());
      await tester.pumpAndSettle();

      expect(find.text('캐시 오류'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display retry button on error', (tester) async {
      when(() => mockGetRecentShopsUseCase())
          .thenAnswer((_) async => const Left(CacheFailure('캐시 오류')));

      await tester.pumpWidget(createRecentShopsPage());
      await tester.pumpAndSettle();

      expect(find.text('다시 시도'), findsOneWidget);
    });

    testWidgets('should display delete all button when shops exist',
        (tester) async {
      when(() => mockGetRecentShopsUseCase())
          .thenAnswer((_) async => Right(tRecentShops));

      await tester.pumpWidget(createRecentShopsPage());
      await tester.pumpAndSettle();

      expect(find.text('전체 삭제'), findsOneWidget);
    });

    testWidgets('should not display delete all button when no shops',
        (tester) async {
      when(() => mockGetRecentShopsUseCase())
          .thenAnswer((_) async => const Right(<RecentShop>[]));

      await tester.pumpWidget(createRecentShopsPage());
      await tester.pumpAndSettle();

      expect(find.text('전체 삭제'), findsNothing);
    });

    testWidgets('should show delete confirmation dialog on delete all tap',
        (tester) async {
      when(() => mockGetRecentShopsUseCase())
          .thenAnswer((_) async => Right(tRecentShops));

      await tester.pumpWidget(createRecentShopsPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('전체 삭제'));
      await tester.pumpAndSettle();

      expect(find.text('최근 본 샵 삭제'), findsOneWidget);
      expect(find.text('최근 본 샵 기록을 모두 삭제하시겠습니까?'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
      expect(find.text('삭제'), findsOneWidget);
    });

    testWidgets('should display star rating when shop has rating',
        (tester) async {
      when(() => mockGetRecentShopsUseCase())
          .thenAnswer((_) async => Right(tRecentShops));

      await tester.pumpWidget(createRecentShopsPage());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
    });

    testWidgets('should display viewed time', (tester) async {
      when(() => mockGetRecentShopsUseCase())
          .thenAnswer((_) async => Right(tRecentShops));

      await tester.pumpWidget(createRecentShopsPage());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('should display back button', (tester) async {
      when(() => mockGetRecentShopsUseCase())
          .thenAnswer((_) async => Right(tRecentShops));

      await tester.pumpWidget(createRecentShopsPage());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });

    testWidgets('should display chevron right for navigation',
        (tester) async {
      when(() => mockGetRecentShopsUseCase())
          .thenAnswer((_) async => Right(tRecentShops));

      await tester.pumpWidget(createRecentShopsPage());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });
}
