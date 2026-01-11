import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/widgets/units/banner_carousel.dart';

void main() {
  final testBanners = [
    const BannerItem(
      id: '1',
      title: '배너 1',
      imageUrl: 'https://example.com/1.jpg',
    ),
    const BannerItem(
      id: '2',
      title: '배너 2',
      imageUrl: 'https://example.com/2.jpg',
    ),
    const BannerItem(
      id: '3',
      title: '배너 3',
      imageUrl: 'https://example.com/3.jpg',
    ),
  ];

  group('BannerCarousel', () {
    testWidgets('renders PageView for swiping', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerCarousel(banners: testBanners),
          ),
        ),
      );

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('renders all banner items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerCarousel(banners: testBanners),
          ),
        ),
      );

      expect(find.text('배너 1'), findsOneWidget);
    });

    testWidgets('shows page indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerCarousel(banners: testBanners),
          ),
        ),
      );

      final containers = find.byType(Container).evaluate();
      int indicatorCount = 0;

      for (final element in containers) {
        final widget = element.widget as Container;
        final decoration = widget.decoration;
        if (decoration is BoxDecoration) {
          final color = decoration.color;
          if (color == const Color(0xFFFFB5BA) || color == const Color(0xFFFFE4E6)) {
            indicatorCount++;
          }
        }
      }

      expect(indicatorCount, greaterThanOrEqualTo(3));
    });

    testWidgets('can swipe to next banner', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerCarousel(banners: testBanners),
          ),
        ),
      );

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.text('배너 2'), findsOneWidget);
    });

    testWidgets('calls onBannerTap when banner is tapped', (tester) async {
      String? tappedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerCarousel(
              banners: testBanners,
              onBannerTap: (id) => tappedId = id,
            ),
          ),
        ),
      );

      await tester.tap(find.text('배너 1'));
      await tester.pumpAndSettle();

      expect(tappedId, '1');
    });

    testWidgets('has peek effect with viewportFraction less than 1', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerCarousel(banners: testBanners),
          ),
        ),
      );

      final pageView = tester.widget<PageView>(find.byType(PageView));
      final controller = pageView.controller;
      expect(controller?.viewportFraction, lessThan(1.0));
    });

    testWidgets('has rounded corners on banner cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerCarousel(banners: testBanners),
          ),
        ),
      );

      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('renders with custom height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerCarousel(
              banners: testBanners,
              height: 200,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, 200);
    });
  });

  group('BannerItem', () {
    test('creates instance with required fields', () {
      const item = BannerItem(
        id: '1',
        title: '테스트',
        imageUrl: 'https://example.com/test.jpg',
      );

      expect(item.id, '1');
      expect(item.title, '테스트');
      expect(item.imageUrl, 'https://example.com/test.jpg');
    });

    test('creates instance with optional subtitle', () {
      const item = BannerItem(
        id: '1',
        title: '테스트',
        imageUrl: 'https://example.com/test.jpg',
        subtitle: '서브타이틀',
      );

      expect(item.subtitle, '서브타이틀');
    });
  });
}
