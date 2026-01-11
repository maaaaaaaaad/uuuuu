import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/widgets/units/category_chip.dart';

void main() {
  group('CategoryChip', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryChip(label: '네일', icon: Icons.brush),
          ),
        ),
      );

      expect(find.text('네일'), findsOneWidget);
    });

    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryChip(label: '네일', icon: Icons.brush),
          ),
        ),
      );

      expect(find.byIcon(Icons.brush), findsOneWidget);
    });

    testWidgets('has circular icon container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryChip(label: '네일', icon: Icons.brush),
          ),
        ),
      );

      final containers = find.byType(Container);
      bool hasCircularContainer = false;

      for (final container in containers.evaluate()) {
        final widget = container.widget as Container;
        final decoration = widget.decoration;
        if (decoration is BoxDecoration &&
            decoration.shape == BoxShape.circle) {
          hasCircularContainer = true;
          break;
        }
      }

      expect(hasCircularContainer, isTrue);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              label: '네일',
              icon: Icons.brush,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CategoryChip));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('applies selected state style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              label: '네일',
              icon: Icons.brush,
              isSelected: true,
            ),
          ),
        ),
      );

      final chip = tester.widget<CategoryChip>(find.byType(CategoryChip));
      expect(chip.isSelected, isTrue);
    });

    testWidgets('uses pastel pink background when selected', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              label: '네일',
              icon: Icons.brush,
              isSelected: true,
            ),
          ),
        ),
      );

      final containers = find.byType(Container);
      bool hasPinkBackground = false;

      for (final container in containers.evaluate()) {
        final widget = container.widget as Container;
        final decoration = widget.decoration;
        if (decoration is BoxDecoration &&
            decoration.shape == BoxShape.circle &&
            decoration.color != null) {
          final color = decoration.color!;
          if (color.r > color.b) {
            hasPinkBackground = true;
            break;
          }
        }
      }

      expect(hasPinkBackground, isTrue);
    });

    testWidgets('has neumorphism shadow on icon container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryChip(label: '네일', icon: Icons.brush),
          ),
        ),
      );

      final containers = find.byType(Container);
      bool hasShadow = false;

      for (final container in containers.evaluate()) {
        final widget = container.widget as Container;
        final decoration = widget.decoration;
        if (decoration is BoxDecoration &&
            decoration.boxShadow != null &&
            decoration.boxShadow!.isNotEmpty) {
          hasShadow = true;
          break;
        }
      }

      expect(hasShadow, isTrue);
    });

    testWidgets('label uses small font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryChip(label: '네일', icon: Icons.brush),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('네일'));
      expect(text.style?.fontSize, lessThanOrEqualTo(14));
    });

    testWidgets('renders custom icon image when provided', (tester) async {
      final chip = const CategoryChip(
        label: '네일',
        iconImagePath: 'assets/icons/nail.png',
      );

      expect(chip.iconImagePath, isNotNull);
      expect(chip.iconImagePath, 'assets/icons/nail.png');
    });
  });
}
