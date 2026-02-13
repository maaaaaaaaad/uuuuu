import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/shared/widgets/glass_card.dart';
import 'package:jellomark/shared/widgets/units/shop_card.dart';

void main() {
  const testShop = BeautyShop(
    id: '1',
    name: '네일샵 A',
    address: '서울시 강남구',
    rating: 4.5,
    reviewCount: 120,
    distance: 1.2,
    tags: ['네일', '젤네일'],
  );

  group('ShopCard', () {
    Widget buildTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 300,
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('renders shop name', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const ShopCard(shop: testShop, width: 250)),
      );

      expect(find.text('네일샵 A'), findsOneWidget);
    });

    testWidgets('renders shop address', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const ShopCard(shop: testShop, width: 250)),
      );

      expect(find.text('서울시 강남구'), findsOneWidget);
    });

    testWidgets('renders rating', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const ShopCard(shop: testShop, width: 250)),
      );

      expect(find.textContaining('4.5'), findsOneWidget);
      expect(find.textContaining('(120)'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders distance', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const ShopCard(shop: testShop, width: 250)),
      );

      expect(find.text('1.2km'), findsOneWidget);
    });

    testWidgets('renders tags', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const ShopCard(shop: testShop, width: 250)),
      );

      expect(find.text('네일'), findsOneWidget);
      expect(find.text('젤네일'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          ShopCard(
            shop: testShop,
            width: 250,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(ShopCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('shows discount badge when shop has discount', (tester) async {
      const discountShop = BeautyShop(
        id: '2',
        name: '할인샵',
        address: '서울',
        discountRate: 20,
      );

      await tester.pumpWidget(
        buildTestWidget(const ShopCard(shop: discountShop, width: 250)),
      );

      expect(find.text('20%'), findsOneWidget);
    });

    testWidgets('shows new badge when shop is new', (tester) async {
      const newShop = BeautyShop(
        id: '3',
        name: '신규샵',
        address: '서울',
        isNew: true,
      );

      await tester.pumpWidget(
        buildTestWidget(const ShopCard(shop: newShop, width: 250)),
      );

      expect(find.text('NEW'), findsOneWidget);
    });

    testWidgets('uses GlassCard for glassmorphism effect', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const ShopCard(shop: testShop, width: 250)),
      );

      expect(find.byType(GlassCard), findsOneWidget);
    });
  });
}
