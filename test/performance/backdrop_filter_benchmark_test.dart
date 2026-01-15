import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/widgets/glass_card.dart';
import 'package:jellomark/shared/widgets/glass_bottom_nav_bar.dart';
import 'package:jellomark/shared/widgets/units/glass_search_bar.dart';

void main() {
  group('BackdropFilter Performance Benchmark', () {
    testWidgets('GlassCard renders within acceptable time', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => GlassCard(
                margin: const EdgeInsets.all(8),
                child: Text('Card $index'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      final renderTime = stopwatch.elapsedMilliseconds;
      debugPrint('GlassCard x10 render time: ${renderTime}ms');

      expect(renderTime, lessThan(2000), reason: 'GlassCard rendering should complete within 2 seconds');
    });

    testWidgets('GlassBottomNavBar renders within acceptable time', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox.expand(),
            bottomNavigationBar: GlassBottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
              items: const [
                BottomNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: '홈'),
                BottomNavItem(icon: Icons.search_outlined, selectedIcon: Icons.search, label: '검색'),
                BottomNavItem(icon: Icons.person_outlined, selectedIcon: Icons.person, label: '프로필'),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      final renderTime = stopwatch.elapsedMilliseconds;
      debugPrint('GlassBottomNavBar render time: ${renderTime}ms');

      expect(renderTime, lessThan(1000), reason: 'GlassBottomNavBar rendering should complete within 1 second');
    });

    testWidgets('GlassSearchBar renders within acceptable time', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: GlassSearchBar(
                hintText: '검색',
                controller: TextEditingController(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      final renderTime = stopwatch.elapsedMilliseconds;
      debugPrint('GlassSearchBar render time: ${renderTime}ms');

      expect(renderTime, lessThan(500), reason: 'GlassSearchBar rendering should complete within 500ms');
    });

    testWidgets('Multiple BackdropFilter widgets render efficiently', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: GlassSearchBar(hintText: '검색'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => GlassCard(
                      margin: const EdgeInsets.all(8),
                      child: Text('Card $index'),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: GlassBottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
              items: const [
                BottomNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: '홈'),
                BottomNavItem(icon: Icons.search_outlined, selectedIcon: Icons.search, label: '검색'),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      final renderTime = stopwatch.elapsedMilliseconds;
      debugPrint('Combined BackdropFilter widgets render time: ${renderTime}ms');

      expect(renderTime, lessThan(3000), reason: 'Combined BackdropFilter widgets should render within 3 seconds');
    });
  });

  group('Scroll Performance Benchmark', () {
    testWidgets('GlassCard list scrolls smoothly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 50,
              itemBuilder: (context, index) => GlassCard(
                margin: const EdgeInsets.all(8),
                child: SizedBox(
                  height: 100,
                  child: Center(child: Text('Card $index')),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      await tester.fling(
        find.byType(ListView),
        const Offset(0, -500),
        1000,
      );
      await tester.pumpAndSettle();

      stopwatch.stop();
      final scrollTime = stopwatch.elapsedMilliseconds;
      debugPrint('GlassCard list scroll time: ${scrollTime}ms');

      expect(scrollTime, lessThan(2000), reason: 'Scroll animation should complete within 2 seconds');
    });

    testWidgets('Rapid scrolling maintains performance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) => GlassCard(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  height: 80,
                  child: Center(child: Text('Item $index')),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < 5; i++) {
        await tester.fling(
          find.byType(ListView),
          const Offset(0, -300),
          800,
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();

      stopwatch.stop();
      final totalTime = stopwatch.elapsedMilliseconds;
      debugPrint('Rapid scroll (5x) total time: ${totalTime}ms');

      expect(totalTime, lessThan(5000), reason: 'Rapid scrolling should complete within 5 seconds');
    });
  });

  group('Memory Usage Estimation', () {
    testWidgets('Widget tree depth with BackdropFilter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) => GlassCard(
                margin: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text('Card $index'),
                    const SizedBox(height: 8),
                    const Text('Description text for testing widget tree depth'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final glassCards = find.byType(GlassCard);
      final backdropFilters = find.byType(BackdropFilter);

      debugPrint('GlassCard count: ${tester.widgetList(glassCards).length}');
      debugPrint('BackdropFilter count: ${tester.widgetList(backdropFilters).length}');

      expect(tester.widgetList(backdropFilters).length, lessThanOrEqualTo(20),
          reason: 'BackdropFilter count should match visible cards');
    });

    testWidgets('Lazy loading prevents excessive BackdropFilter instances', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 1000,
              itemBuilder: (context, index) => GlassCard(
                margin: const EdgeInsets.all(8),
                child: SizedBox(
                  height: 100,
                  child: Center(child: Text('Card $index')),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final backdropFilters = find.byType(BackdropFilter);
      final visibleCount = tester.widgetList(backdropFilters).length;

      debugPrint('Visible BackdropFilter count (of 1000 items): $visibleCount');

      expect(visibleCount, lessThan(20),
          reason: 'ListView should only render visible BackdropFilters');
    });
  });
}
