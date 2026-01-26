import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/widgets/hero_carousel.dart';

void main() {
  group('HeroCarousel', () {
    Widget createTestWidget({bool enableAutoSlide = false}) {
      return MaterialApp(
        home: Scaffold(
          body: HeroCarousel(enableAutoSlide: enableAutoSlide),
        ),
      );
    }

    testWidgets('should render PageView with 3 cards', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should display welcome card as first page', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('환영합니다! 👋'), findsOneWidget);
      expect(find.text('오늘도 예뻐지는 하루 되세요'), findsOneWidget);
    });

    testWidgets('should display app intro card when swiped', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text('젤로마크'), findsOneWidget);
      expect(find.text('내 주변 뷰티샵을 한눈에 찾아보세요'), findsOneWidget);
    });

    testWidgets('should display feature card when swiped twice', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();
      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text('편리한 기능'), findsOneWidget);
      expect(find.text('리뷰 확인 · 즐겨찾기 · 위치 기반 검색'), findsOneWidget);
    });

    testWidgets('should have page indicator', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final indicator = find.byKey(const Key('hero_carousel_indicator'));
      expect(indicator, findsOneWidget);
    });
  });
}
