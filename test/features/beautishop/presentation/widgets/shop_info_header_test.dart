import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_info_header.dart';

void main() {
  group('ShopInfoHeader', () {
    testWidgets('should display shop name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopInfoHeader(
              name: '블루밍 네일',
              rating: 4.8,
              reviewCount: 234,
            ),
          ),
        ),
      );

      expect(find.text('블루밍 네일'), findsOneWidget);
    });

    testWidgets('should display rating with star icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopInfoHeader(
              name: '블루밍 네일',
              rating: 4.8,
              reviewCount: 234,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
    });

    testWidgets('should display review count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopInfoHeader(
              name: '블루밍 네일',
              rating: 4.8,
              reviewCount: 234,
            ),
          ),
        ),
      );

      expect(find.text('리뷰 234개'), findsOneWidget);
    });

    testWidgets('should display distance when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopInfoHeader(
              name: '블루밍 네일',
              rating: 4.8,
              reviewCount: 234,
              address: '서울시 강남구 역삼동 123-45',
              distance: '300m',
            ),
          ),
        ),
      );

      expect(find.text('300m'), findsOneWidget);
    });

    testWidgets('should display tags when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopInfoHeader(
              name: '블루밍 네일',
              rating: 4.8,
              reviewCount: 234,
              tags: ['네일', '젤네일'],
            ),
          ),
        ),
      );

      expect(find.text('네일'), findsOneWidget);
      expect(find.text('젤네일'), findsOneWidget);
    });

    testWidgets('should display address when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopInfoHeader(
              name: '블루밍 네일',
              rating: 4.8,
              reviewCount: 234,
              address: '서울시 강남구 역삼동 123-45',
            ),
          ),
        ),
      );

      expect(find.text('서울시 강남구 역삼동 123-45'), findsOneWidget);
    });

    testWidgets('should trigger onReviewTap when review button is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShopInfoHeader(
              name: '블루밍 네일',
              rating: 4.8,
              reviewCount: 234,
              onReviewTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('리뷰 234개'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
