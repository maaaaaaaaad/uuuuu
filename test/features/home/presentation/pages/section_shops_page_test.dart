import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_beauty_shops.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_filtered_shops_usecase.dart';
import 'package:jellomark/features/home/domain/entities/home_section.dart';
import 'package:jellomark/features/home/presentation/pages/section_shops_page.dart';
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

  Widget createTestWidget(HomeSection section) {
    return ProviderScope(
      overrides: [
        getFilteredShopsUseCaseProvider.overrideWithValue(
          mockGetFilteredShopsUseCase,
        ),
        currentLocationProvider.overrideWith((ref) async => null),
      ],
      child: MaterialApp(home: SectionShopsPage(section: section)),
    );
  }

  group('SectionShopsPage', () {
    testWidgets('displays the section title in the app bar', (tester) async {
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => const Right(
          PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
        ),
      );

      await tester.pumpWidget(createTestWidget(HomeSection.recommended));
      await tester.pumpAndSettle();

      expect(find.text('추천 샵'), findsOneWidget);
    });

    testWidgets('renders the sort filter chips', (tester) async {
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => const Right(
          PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
        ),
      );

      await tester.pumpWidget(createTestWidget(HomeSection.newShops));
      await tester.pumpAndSettle();

      expect(find.text('거리순'), findsOneWidget);
      expect(find.text('평점순'), findsOneWidget);
      expect(find.text('리뷰순'), findsOneWidget);
      expect(find.text('최신순'), findsOneWidget);
    });

    testWidgets('shows the empty state when no shops are returned', (
      tester,
    ) async {
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => const Right(
          PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
        ),
      );

      await tester.pumpWidget(createTestWidget(HomeSection.recommended));
      await tester.pumpAndSettle();

      expect(find.text('표시할 샵이 없습니다'), findsOneWidget);
    });

    testWidgets('renders fetched shops', (tester) async {
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => const Right(
          PagedBeautyShops(
            items: [
              BeautyShop(id: '1', name: '젤로네일', address: '서울 강남구'),
            ],
            hasNext: false,
            totalElements: 1,
          ),
        ),
      );

      await tester.pumpWidget(createTestWidget(HomeSection.recommended));
      await tester.pumpAndSettle();

      expect(find.text('젤로네일'), findsOneWidget);
    });
  });
}
