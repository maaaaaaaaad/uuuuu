import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_description.dart';

void main() {
  group('ShopDescription', () {
    testWidgets('should display description text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ShopDescription(description: '강남 최고의 네일샵입니다.')),
        ),
      );

      expect(find.text('강남 최고의 네일샵입니다.'), findsOneWidget);
    });

    testWidgets('should display section title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ShopDescription(description: '설명입니다.')),
        ),
      );

      expect(find.text('샵 소개'), findsOneWidget);
    });

    testWidgets('should truncate long text with expandable option', (
      tester,
    ) async {
      final longText = '이것은 매우 긴 설명입니다. ' * 20;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShopDescription(description: longText, maxLines: 3),
          ),
        ),
      );

      expect(find.text('더보기'), findsOneWidget);
    });

    testWidgets('should expand text when 더보기 is tapped', (tester) async {
      final longText = '이것은 매우 긴 설명입니다. ' * 20;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShopDescription(description: longText, maxLines: 3),
          ),
        ),
      );

      await tester.tap(find.text('더보기'));
      await tester.pump();

      expect(find.text('접기'), findsOneWidget);
    });

    testWidgets('should not show 더보기 for short text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopDescription(description: '짧은 설명', maxLines: 3),
          ),
        ),
      );

      expect(find.text('더보기'), findsNothing);
    });
  });
}
