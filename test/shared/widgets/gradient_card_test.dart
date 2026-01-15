import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/widgets/gradient_card.dart';

void main() {
  group('GradientCard', () {
    testWidgets('should render child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientCard(
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('should apply mint gradient by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientCard(
              child: Text('Test'),
            ),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.gradient == AppGradients.mintGradient;
        }
        return false;
      });
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('should apply lavender gradient when specified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientCard(
              gradientType: GradientType.lavender,
              child: Text('Test'),
            ),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.gradient == AppGradients.lavenderGradient;
        }
        return false;
      });
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('should apply pink gradient when specified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientCard(
              gradientType: GradientType.pink,
              child: Text('Test'),
            ),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.gradient == AppGradients.pinkGradient;
        }
        return false;
      });
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('should apply custom gradient when provided', (tester) async {
      const customGradient = LinearGradient(
        colors: [Colors.red, Colors.blue],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientCard(
              customGradient: customGradient,
              child: Text('Test'),
            ),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.gradient == customGradient;
        }
        return false;
      });
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCard(
              onTap: () => tapped = true,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GradientCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should apply custom padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientCard(
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

    testWidgets('should scale down on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCard(
              onTap: () {},
              child: const Text('Test'),
            ),
          ),
        ),
      );

      final animatedScaleFinder = find.byType(AnimatedScale);
      expect(animatedScaleFinder, findsOneWidget);

      await tester.press(find.byType(GradientCard));
      await tester.pump();

      final animatedScale = tester.widget<AnimatedScale>(animatedScaleFinder);
      expect(animatedScale.scale, 0.98);
    });
  });
}
