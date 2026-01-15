import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/widgets/glass_bottom_nav_bar.dart';

void main() {
  group('BottomNavItem', () {
    test('should create with required parameters', () {
      const item = BottomNavItem(
        icon: Icons.home_outlined,
        label: 'Home',
      );

      expect(item.icon, Icons.home_outlined);
      expect(item.label, 'Home');
      expect(item.selectedIcon, isNull);
    });

    test('should create with selectedIcon', () {
      const item = BottomNavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: 'Home',
      );

      expect(item.selectedIcon, Icons.home);
    });
  });

  group('GlassBottomNavBar', () {
    final testItems = const [
      BottomNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
      BottomNavItem(icon: Icons.search_outlined, selectedIcon: Icons.search, label: 'Search'),
      BottomNavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
    ];

    testWidgets('should render all navigation items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GlassBottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
              items: testItems,
            ),
          ),
        ),
      );

      expect(find.byType(GlassBottomNavBar), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('should call onTap with correct index when item tapped', (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GlassBottomNavBar(
              currentIndex: 0,
              onTap: (index) => tappedIndex = index,
              items: testItems,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search_outlined));
      await tester.pumpAndSettle();

      expect(tappedIndex, 1);
    });

    testWidgets('should show selected icon for current index', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GlassBottomNavBar(
              currentIndex: 1,
              onTap: (_) {},
              items: testItems,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('should apply BackdropFilter for glass effect', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GlassBottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
              items: testItems,
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('should have top rounded corners only for edge-to-edge style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GlassBottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
              items: testItems,
            ),
          ),
        ),
      );

      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(
        clipRRect.borderRadius,
        const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      );
    });

    testWidgets('should display label for selected item only', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GlassBottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
              items: testItems,
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsNothing);
      expect(find.text('Profile'), findsNothing);
    });

    testWidgets('should update selection when currentIndex changes', (tester) async {
      int currentIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                bottomNavigationBar: GlassBottomNavBar(
                  currentIndex: currentIndex,
                  onTap: (index) => setState(() => currentIndex = index),
                  items: testItems,
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });
}
