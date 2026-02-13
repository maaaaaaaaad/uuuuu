import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/widgets/glass_app_bar.dart';

void main() {
  group('GlassAppBar', () {
    testWidgets('should implement PreferredSizeWidget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const GlassAppBar(),
            body: Container(),
          ),
        ),
      );

      expect(find.byType(GlassAppBar), findsOneWidget);
    });

    testWidgets('should display title when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const GlassAppBar(title: 'Test Title'),
            body: Container(),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('should show back button by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const GlassAppBar(),
            body: Container(),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('should hide back button when showBackButton is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const GlassAppBar(showBackButton: false),
            body: Container(),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
    });

    testWidgets('should call Navigator.maybePop when back button is tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: const GlassAppBar(),
                        body: Container(),
                      ),
                    ),
                  );
                },
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.byType(GlassAppBar), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.byType(GlassAppBar), findsNothing);
    });

    testWidgets('should display custom leading widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const GlassAppBar(
              leading: Icon(Icons.menu),
              showBackButton: false,
            ),
            body: Container(),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('should display action buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const GlassAppBar(
              actions: [
                Icon(Icons.share),
                Icon(Icons.favorite),
              ],
            ),
            body: Container(),
          ),
        ),
      );

      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should apply glass decoration when not transparent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const GlassAppBar(transparent: false),
            body: Container(),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(GlassAppBar),
          matching: find.byType(Container),
        ),
      );
      final hasDecoratedContainer = containers.any(
        (c) => c.decoration is BoxDecoration && (c.decoration as BoxDecoration).border != null,
      );
      expect(hasDecoratedContainer, isTrue);
    });

    testWidgets('should not apply glass decoration when transparent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const GlassAppBar(transparent: true),
            body: Container(),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(GlassAppBar),
          matching: find.byType(Container),
        ),
      );
      final hasGlassDecoration = containers.any((c) {
        if (c.decoration is! BoxDecoration) return false;
        final d = c.decoration as BoxDecoration;
        return d.border != null && d.shape != BoxShape.circle;
      });
      expect(hasGlassDecoration, isFalse);
    });
  });
}
