import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/theme/app_colors.dart';
import 'package:jellomark/shared/widgets/pill_chip.dart';

void main() {
  group('PillChip', () {
    testWidgets('should render label text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PillChip(label: 'Test Label'),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('should apply pill border radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PillChip(label: 'Test'),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.borderRadius == BorderRadius.circular(50);
        }
        return false;
      });
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('should show filled background when selected', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PillChip(
              label: 'Test',
              isSelected: true,
            ),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.color == AppColors.pastelPink;
        }
        return false;
      });
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('should show border when not selected', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PillChip(
              label: 'Test',
              isSelected: false,
            ),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.color == Colors.transparent &&
              decoration.border != null;
        }
        return false;
      });
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('should apply custom selectedColor', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PillChip(
              label: 'Test',
              isSelected: true,
              selectedColor: Colors.red,
            ),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.color == Colors.red;
        }
        return false;
      });
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('should display icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PillChip(
              label: 'Test',
              icon: Icons.star,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should not display icon when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PillChip(label: 'Test'),
          ),
        ),
      );

      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PillChip(
              label: 'Test',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PillChip));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
