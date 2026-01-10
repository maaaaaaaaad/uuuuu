import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/home/presentation/pages/home_page.dart';

void main() {
  group('HomePage', () {
    testWidgets('should render home page', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should display bottom navigation bar', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('should have correct navigation items', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));

      expect(find.text('홈'), findsOneWidget);
      expect(find.text('검색'), findsOneWidget);
      expect(find.text('마이'), findsOneWidget);
    });

    testWidgets('should switch tabs when navigation item tapped', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));

      await tester.tap(find.text('검색'));
      await tester.pumpAndSettle();

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.currentIndex, 1);
    });

    testWidgets('should show different content for each tab', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));

      expect(find.text('홈 탭'), findsOneWidget);

      await tester.tap(find.text('검색'));
      await tester.pumpAndSettle();
      expect(find.text('검색 탭'), findsOneWidget);

      await tester.tap(find.text('마이'));
      await tester.pumpAndSettle();
      expect(find.text('마이 탭'), findsOneWidget);
    });
  });
}
