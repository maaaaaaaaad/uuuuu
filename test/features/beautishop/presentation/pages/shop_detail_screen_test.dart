import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/beautishop/presentation/pages/shop_detail_screen.dart';
import 'package:jellomark/features/treatment/presentation/providers/treatment_provider.dart';

import '../../../../helpers/mock_http_client.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  group('ShopDetailScreen', () {
    late BeautyShop testShop;

    setUp(() {
      testShop = const BeautyShop(
        id: 'shop-1',
        name: '블루밍 네일',
        address: '서울시 강남구 역삼동 123-45',
        rating: 4.8,
        reviewCount: 234,
        distance: 0.3,
        tags: ['네일', '젤네일'],
      );
    });

    Widget createShopDetailScreen({
      required BeautyShop shop,
      List<ServiceMenu>? treatments,
      String? errorMessage,
    }) {
      return ProviderScope(
        overrides: [
          shopTreatmentsProvider(shop.id).overrideWith((ref) {
            if (errorMessage != null) {
              throw Exception(errorMessage);
            }
            return Future.value(treatments ?? []);
          }),
        ],
        child: MaterialApp(
          home: ShopDetailScreen(shop: shop),
        ),
      );
    }

    testWidgets('should render shop detail screen', (tester) async {
      await tester.pumpWidget(createShopDetailScreen(shop: testShop));
      await tester.pumpAndSettle();

      expect(find.byType(ShopDetailScreen), findsOneWidget);
    });

    testWidgets('should display shop name', (tester) async {
      await tester.pumpWidget(createShopDetailScreen(shop: testShop));
      await tester.pumpAndSettle();

      expect(find.text('블루밍 네일'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display SliverAppBar with back button', (
      tester,
    ) async {
      await tester.pumpWidget(createShopDetailScreen(shop: testShop));
      await tester.pumpAndSettle();

      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should display bottom reservation button', (tester) async {
      await tester.pumpWidget(createShopDetailScreen(shop: testShop));
      await tester.pumpAndSettle();

      expect(find.text('예약하기'), findsOneWidget);
    });

    testWidgets('should display loading indicator while loading treatments', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shopTreatmentsProvider(testShop.id).overrideWith((ref) async {
              await Future<void>.value();
              return const <ServiceMenu>[];
            }),
          ],
          child: MaterialApp(
            home: ShopDetailScreen(shop: testShop),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('should display treatments when loaded', (tester) async {
      const treatments = [
        ServiceMenu(
          id: 'treatment-1',
          name: '젤네일 기본',
          price: 50000,
          durationMinutes: 60,
        ),
        ServiceMenu(
          id: 'treatment-2',
          name: '젤네일 아트',
          price: 70000,
          durationMinutes: 90,
        ),
      ];

      await tester.pumpWidget(
        createShopDetailScreen(shop: testShop, treatments: treatments),
      );
      await tester.pumpAndSettle();

      expect(find.text('시술 메뉴'), findsOneWidget);
      expect(find.text('50,000원'), findsOneWidget);
      expect(find.text('70,000원'), findsOneWidget);
    });

    testWidgets('should hide service menu section when no treatments', (
      tester,
    ) async {
      await tester.pumpWidget(
        createShopDetailScreen(shop: testShop, treatments: []),
      );
      await tester.pumpAndSettle();

      expect(find.text('시술 메뉴'), findsNothing);
    });

    testWidgets('should display error message when loading fails', (
      tester,
    ) async {
      await tester.pumpWidget(
        createShopDetailScreen(
          shop: testShop,
          errorMessage: '시술 정보를 불러올 수 없습니다',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('시술 정보를 불러올 수 없습니다'), findsOneWidget);
    });

    testWidgets('should navigate back when back button is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shopTreatmentsProvider('shop-1').overrideWith((ref) async => []),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShopDetailScreen(shop: testShop),
                      ),
                    );
                  },
                  child: const Text('Go to detail'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go to detail'));
      await tester.pumpAndSettle();

      expect(find.byType(ShopDetailScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(ShopDetailScreen), findsNothing);
    });
  });
}
