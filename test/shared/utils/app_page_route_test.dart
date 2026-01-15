import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/utils/app_page_route.dart';

void main() {
  group('AppPageRoute', () {
    testWidgets('should create a page route with fade transition', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageRoute(
                    page: const Scaffold(body: Text('New Page')),
                  ),
                );
              },
              child: const Text('Navigate'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pump();

      expect(find.byType(FadeTransition), findsWidgets);
    });

    testWidgets('should create a page route with slide transition', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageRoute(
                    page: const Scaffold(body: Text('New Page')),
                  ),
                );
              },
              child: const Text('Navigate'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pump();

      expect(find.byType(SlideTransition), findsWidgets);
    });

    testWidgets('should complete transition and show new page', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageRoute(
                    page: const Scaffold(body: Text('New Page')),
                  ),
                );
              },
              child: const Text('Navigate'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('New Page'), findsOneWidget);
    });

    testWidgets('should have default transition duration of 300ms', (
      tester,
    ) async {
      final route = AppPageRoute(
        page: const Scaffold(body: Text('Test')),
      );

      expect(route.transitionDuration, const Duration(milliseconds: 300));
    });
  });
}
