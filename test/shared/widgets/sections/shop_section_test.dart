import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/shared/widgets/sections/shop_section.dart';
import 'package:jellomark/shared/widgets/units/section_header.dart';
import 'package:jellomark/shared/widgets/units/shop_card.dart';

void main() {
  final testShops = [
    const BeautyShop(id: '1', name: '네일샵 A', address: '강남구', rating: 4.5),
    const BeautyShop(id: '2', name: '네일샵 B', address: '서초구', rating: 4.2),
    const BeautyShop(id: '3', name: '네일샵 C', address: '송파구', rating: 4.8),
  ];

  group('HorizontalShopSection', () {
    testWidgets('renders section header with title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HorizontalShopSection(
                title: '내 주변 인기 샵',
                shops: testShops,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SectionHeader), findsOneWidget);
      expect(find.text('내 주변 인기 샵'), findsOneWidget);
    });

    testWidgets('renders shop cards in horizontal scroll', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HorizontalShopSection(
                title: '인기 샵',
                shops: testShops,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ShopCard), findsNWidgets(3));
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('calls onShopTap when shop is tapped', (tester) async {
      String? tappedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HorizontalShopSection(
                title: '인기 샵',
                shops: testShops,
                onShopTap: (id) => tappedId = id,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('네일샵 A'));
      await tester.pumpAndSettle();

      expect(tappedId, '1');
    });

    testWidgets('shows more button when showMore is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HorizontalShopSection(
                title: '인기 샵',
                shops: testShops,
                showMore: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('더보기'), findsOneWidget);
    });
  });

  group('VerticalShopSection', () {
    testWidgets('renders section header with title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VerticalShopSection(
                title: '추천 샵',
                shops: testShops,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SectionHeader), findsOneWidget);
      expect(find.text('추천 샵'), findsOneWidget);
    });

    testWidgets('renders shop cards in vertical list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VerticalShopSection(
                title: '추천 샵',
                shops: testShops,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ShopCard), findsNWidgets(3));
    });

    testWidgets('calls onShopTap when shop is tapped', (tester) async {
      String? tappedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VerticalShopSection(
                title: '추천 샵',
                shops: testShops,
                onShopTap: (id) => tappedId = id,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('네일샵 A'));
      await tester.pumpAndSettle();

      expect(tappedId, '1');
    });

    testWidgets('uses full width for cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VerticalShopSection(
                title: '추천 샵',
                shops: testShops,
              ),
            ),
          ),
        ),
      );

      final section = tester.widget<VerticalShopSection>(
        find.byType(VerticalShopSection),
      );
      expect(section.shops.length, 3);
    });
  });
}
