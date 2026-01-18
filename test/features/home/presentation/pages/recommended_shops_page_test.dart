import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_beauty_shops.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_filtered_shops_usecase.dart';
import 'package:jellomark/features/home/presentation/pages/recommended_shops_page.dart';
import 'package:jellomark/features/home/presentation/providers/home_provider.dart';
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_http_client.dart';

class MockGetFilteredShopsUseCase extends Mock
    implements GetFilteredShopsUseCase {}

class FakeBeautyShopFilter extends Fake implements BeautyShopFilter {}

void main() {
  late MockGetFilteredShopsUseCase mockGetFilteredShopsUseCase;

  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
    registerFallbackValue(FakeBeautyShopFilter());
  });

  setUp(() {
    mockGetFilteredShopsUseCase = MockGetFilteredShopsUseCase();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        getFilteredShopsUseCaseProvider.overrideWithValue(
          mockGetFilteredShopsUseCase,
        ),
        currentLocationProvider.overrideWith((ref) async => null),
      ],
      child: const MaterialApp(home: RecommendedShopsPage()),
    );
  }

  group('RecommendedShopsPage', () {
    testWidgets('displays app bar with correct title', (tester) async {
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => const Right(
          PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
        ),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('추천 샵'), findsOneWidget);
    });

    testWidgets('shows loading indicator while loading', (tester) async {
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return const Right(
            PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
          );
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('displays shops from provider', (tester) async {
      const shops = [
        BeautyShop(id: '1', name: 'Shop 1', address: 'Seoul', rating: 4.8),
        BeautyShop(id: '2', name: 'Shop 2', address: 'Busan', rating: 4.5),
      ];

      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => const Right(
          PagedBeautyShops(items: shops, hasNext: false, totalElements: 2),
        ),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Shop 1'), findsOneWidget);
      expect(find.text('Shop 2'), findsOneWidget);
    });

    testWidgets('calls loadInitial on mount', (tester) async {
      const shops = [
        BeautyShop(id: '1', name: 'Shop1', address: 'Seoul', rating: 4.8),
      ];

      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => const Right(
          PagedBeautyShops(items: shops, hasNext: false, totalElements: 1),
        ),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      verify(() => mockGetFilteredShopsUseCase(any())).called(1);
      expect(find.text('Shop1'), findsOneWidget);
    });

    testWidgets('displays multiple shops correctly', (tester) async {
      const shops = [
        BeautyShop(id: '1', name: 'Shop1', address: 'Seoul', rating: 4.8),
        BeautyShop(id: '2', name: 'Shop2', address: 'Busan', rating: 4.7),
        BeautyShop(id: '3', name: 'Shop3', address: 'Daegu', rating: 4.6),
      ];

      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => const Right(
          PagedBeautyShops(items: shops, hasNext: true, totalElements: 10),
        ),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Shop1'), findsOneWidget);
      expect(find.text('Shop2'), findsOneWidget);
      expect(find.text('Shop3'), findsOneWidget);
    });

    testWidgets('does not load more when hasMore is false', (tester) async {
      const shops = [
        BeautyShop(id: '1', name: 'Shop1', address: 'Seoul', rating: 4.8),
      ];

      int callCount = 0;
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer((_) async {
        callCount++;
        return const Right(
          PagedBeautyShops(items: shops, hasNext: false, totalElements: 1),
        );
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final initialCallCount = callCount;

      await tester.drag(find.byType(ListView), const Offset(0, -5000));
      await tester.pumpAndSettle();

      expect(callCount, initialCallCount);
    });
  });
}
