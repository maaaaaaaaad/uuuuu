import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/presentation/pages/shop_detail_page.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_map_widget.dart';
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';
import 'package:jellomark/shared/widgets/sections/shop_section.dart';

void main() {
  setUp(() {
    ShopMapWidget.useTestMode = true;
  });

  tearDown(() {
    ShopMapWidget.useTestMode = false;
  });

  group('Shop Navigation', () {
    const testShop = BeautyShop(
      id: 'shop-1',
      name: '테스트 네일샵',
      address: '서울시 강남구 역삼동',
      rating: 4.5,
      reviewCount: 100,
      distance: 0.5,
      tags: ['네일', '젤네일'],
    );

    testWidgets(
      'HorizontalShopSection calls onShopTap with shop id when card is tapped',
      (tester) async {
        String? tappedShopId;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HorizontalShopSection(
                title: '테스트 섹션',
                shops: const [testShop],
                onShopTap: (id) => tappedShopId = id,
              ),
            ),
          ),
        );

        await tester.tap(find.text('테스트 네일샵'));
        await tester.pumpAndSettle();

        expect(tappedShopId, equals('shop-1'));
      },
    );

    testWidgets(
      'VerticalShopSection calls onShopTap with shop id when card is tapped',
      (tester) async {
        String? tappedShopId;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: VerticalShopSection(
                  title: '테스트 섹션',
                  shops: const [testShop],
                  onShopTap: (id) => tappedShopId = id,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('테스트 네일샵'));
        await tester.pumpAndSettle();

        expect(tappedShopId, equals('shop-1'));
      },
    );

    testWidgets('navigates to ShopDetailPage when shop card is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentLocationProvider.overrideWith((ref) async => null),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: HorizontalShopSection(
                title: '테스트 섹션',
                shops: const [testShop],
                onShopTap: (id) {
                  Navigator.of(
                    tester.element(find.byType(HorizontalShopSection)),
                  ).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ShopDetailPage.fromBeautyShop(shop: testShop),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('테스트 네일샵'));
      await tester.pumpAndSettle();

      expect(find.byType(ShopDetailPage), findsOneWidget);
    });

    testWidgets('ShopDetailPage shows correct shop name', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentLocationProvider.overrideWith((ref) async => null),
          ],
          child: MaterialApp(
            home: ShopDetailPage.fromBeautyShop(shop: testShop),
          ),
        ),
      );

      expect(find.text('테스트 네일샵'), findsAtLeastNWidgets(1));
    });

    testWidgets('back button navigates back from ShopDetailPage', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentLocationProvider.overrideWith((ref) async => null),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ShopDetailPage.fromBeautyShop(shop: testShop),
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

      expect(find.byType(ShopDetailPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(ShopDetailPage), findsNothing);
      expect(find.text('Go to detail'), findsOneWidget);
    });
  });
}
