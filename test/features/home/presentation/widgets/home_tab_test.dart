import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/presentation/pages/shop_detail_page.dart';
import 'package:jellomark/features/home/presentation/widgets/home_tab.dart';
import 'package:jellomark/shared/widgets/sections/search_section.dart';
import 'package:jellomark/shared/widgets/sections/category_section.dart';
import 'package:jellomark/shared/widgets/units/banner_carousel.dart';
import 'package:jellomark/shared/widgets/units/shop_card.dart';

void main() {
  group('HomeTab', () {
    testWidgets('renders scrollable content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeTab(),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(find.byType(HomeTab), findsOneWidget);
    });

    testWidgets('renders search section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeTab(),
          ),
        ),
      );

      expect(find.byType(SearchSection), findsOneWidget);
    });

    testWidgets('renders category section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeTab(),
          ),
        ),
      );

      expect(find.byType(CategorySection), findsOneWidget);
    });

    testWidgets('renders banner carousel', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeTab(),
          ),
        ),
      );

      expect(find.byType(BannerCarousel), findsOneWidget);
    });

    testWidgets('renders section headers for shop lists', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeTab(),
          ),
        ),
      );

      expect(find.text('내 주변 인기 샵'), findsOneWidget);
      expect(find.text('할인 중인 샵'), findsOneWidget);
    });

    testWidgets('sections are in correct order', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeTab(),
          ),
        ),
      );

      final searchOffset = tester.getTopLeft(find.byType(SearchSection));
      final categoryOffset = tester.getTopLeft(find.byType(CategorySection));
      final bannerOffset = tester.getTopLeft(find.byType(BannerCarousel));

      expect(searchOffset.dy, lessThan(categoryOffset.dy));
      expect(categoryOffset.dy, lessThan(bannerOffset.dy));
    });

    testWidgets('has RefreshIndicator for pull to refresh', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeTab(),
          ),
        ),
      );

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('calls onRefresh when pulled down', (tester) async {
      bool refreshCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeTab(
              onRefresh: () async {
                refreshCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.fling(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      expect(refreshCalled, isTrue);
    });

    testWidgets('has SafeArea to avoid status bar overlap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeTab(),
          ),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('shows floating search icon when scrolled down', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeTab(),
          ),
        ),
      );

      expect(find.byKey(const Key('floating_search_icon')), findsNothing);

      await tester.fling(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -300),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('floating_search_icon')), findsOneWidget);
    });

    testWidgets('hides floating search icon when scrolled back to top', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeTab(),
          ),
        ),
      );

      await tester.fling(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -300),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('floating_search_icon')), findsOneWidget);

      await tester.fling(
        find.byType(SingleChildScrollView).first,
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('floating_search_icon')), findsNothing);
    });

    testWidgets('navigates to ShopDetailPage when shop card is tapped',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeTab(),
          ),
        ),
      );

      final shopCard = find.byType(ShopCard).first;
      await tester.tap(shopCard);
      await tester.pumpAndSettle();

      expect(find.byType(ShopDetailPage), findsOneWidget);
    });
  });
}
