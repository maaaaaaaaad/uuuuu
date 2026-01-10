import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/home/presentation/widgets/main_carousel.dart';

void main() {
  group('MainCarousel', () {
    final testItems = [
      const CarouselItem(
        id: '1',
        imageUrl: 'https://example.com/1.jpg',
        title: '첫 번째 배너',
      ),
      const CarouselItem(
        id: '2',
        imageUrl: 'https://example.com/2.jpg',
        title: '두 번째 배너',
      ),
      const CarouselItem(
        id: '3',
        imageUrl: 'https://example.com/3.jpg',
        title: '세 번째 배너',
      ),
    ];

    testWidgets('should render carousel widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MainCarousel(items: testItems)),
        ),
      );

      expect(find.byType(MainCarousel), findsOneWidget);
    });

    testWidgets('should display page view for swiping', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MainCarousel(items: testItems)),
        ),
      );

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should display page indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MainCarousel(items: testItems)),
        ),
      );

      expect(find.byType(PageIndicator), findsOneWidget);
    });

    testWidgets('should swipe to next page', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(height: 300, child: MainCarousel(items: testItems)),
          ),
        ),
      );

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('두 번째 배너'), findsOneWidget);
    });
  });
}
