import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_action_bar.dart';

void main() {
  group('ShopActionBar', () {
    testWidgets('should display call button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopActionBar(),
          ),
        ),
      );

      expect(find.byIcon(Icons.call), findsOneWidget);
      expect(find.text('전화'), findsOneWidget);
    });

    testWidgets('should display bookmark button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopActionBar(),
          ),
        ),
      );

      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      expect(find.text('저장'), findsOneWidget);
    });

    testWidgets('should display share button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopActionBar(),
          ),
        ),
      );

      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.text('공유'), findsOneWidget);
    });

    testWidgets('should call onCall when call button tapped', (tester) async {
      bool callTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShopActionBar(
              onCall: () => callTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('전화'));
      await tester.pump();

      expect(callTapped, isTrue);
    });

    testWidgets('should call onBookmark when bookmark button tapped', (tester) async {
      bool bookmarkTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShopActionBar(
              onBookmark: () => bookmarkTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('저장'));
      await tester.pump();

      expect(bookmarkTapped, isTrue);
    });

    testWidgets('should show filled bookmark icon when bookmarked', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopActionBar(isBookmarked: true),
          ),
        ),
      );

      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });
  });
}
