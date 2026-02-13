import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/widgets/glass_card.dart';

void main() {
  group('GlassCard', () {
    testWidgets('should render child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('should have container with card background color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('Test'),
            ),
          ),
        ),
      );

      final container = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(GlassCard),
          matching: find.byType(Container),
        ),
      ).first;
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('should apply default padding of 16', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('Test'),
            ),
          ),
        ),
      );

      final paddingFinder = find.byWidgetPredicate(
        (widget) => widget is Padding && widget.padding == const EdgeInsets.all(16),
      );
      expect(paddingFinder, findsOneWidget);
    });

    testWidgets('should apply custom padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              padding: EdgeInsets.all(24),
              child: Text('Test'),
            ),
          ),
        ),
      );

      final paddingFinder = find.byWidgetPredicate(
        (widget) => widget is Padding && widget.padding == const EdgeInsets.all(24),
      );
      expect(paddingFinder, findsOneWidget);
    });

    testWidgets('should apply custom margin', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              margin: EdgeInsets.all(8),
              child: Text('Test'),
            ),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate(
        (widget) => widget is Container && widget.margin == const EdgeInsets.all(8),
      );
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassCard(
              onTap: () => tapped = true,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GlassCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should not throw when onTap is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('Test'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GlassCard));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('should apply custom borderRadius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              borderRadius: 30,
              child: Text('Test'),
            ),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).borderRadius ==
                BorderRadius.circular(30),
      );
      expect(containerFinder, findsOneWidget);
    });

    group('Tap Animation', () {
      testWidgets('should have AnimatedScale widget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassCard(
                onTap: () {},
                child: const Text('Test'),
              ),
            ),
          ),
        );

        expect(find.byType(AnimatedScale), findsOneWidget);
      });

      testWidgets('should scale down to 0.98 when pressed', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassCard(
                onTap: () {},
                child: const Text('Test'),
              ),
            ),
          ),
        );

        final animatedScale = tester.widget<AnimatedScale>(
          find.byType(AnimatedScale),
        );
        expect(animatedScale.scale, 1.0);

        await tester.press(find.byType(GlassCard));
        await tester.pump();

        final pressedAnimatedScale = tester.widget<AnimatedScale>(
          find.byType(AnimatedScale),
        );
        expect(pressedAnimatedScale.scale, 0.98);
      });

      testWidgets('should scale back to 1.0 after tap up', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassCard(
                onTap: () {},
                child: const Text('Test'),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(GlassCard));
        await tester.pumpAndSettle();

        final animatedScale = tester.widget<AnimatedScale>(
          find.byType(AnimatedScale),
        );
        expect(animatedScale.scale, 1.0);
      });
    });
  });
}
