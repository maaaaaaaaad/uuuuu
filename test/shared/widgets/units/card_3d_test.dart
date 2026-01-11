import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/widgets/units/card_3d.dart';

void main() {
  group('Card3D', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Card3D(child: Text('Test Content'))),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('has rounded corners with 16px radius by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Card3D(child: Text('Test'))),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('applies custom border radius when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Card3D(borderRadius: 20, child: Text('Test'))),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(20));
    });

    testWidgets('has neumorphism shadow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Card3D(child: Text('Test'))),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, greaterThanOrEqualTo(1));
    });

    testWidgets('applies 3D rotation on tap down', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Card3D(child: SizedBox(width: 200, height: 200)),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Card3D)),
      );
      await tester.pump(const Duration(milliseconds: 50));

      final transform = tester.widget<Transform>(find.byType(Transform).first);
      expect(transform.transform, isNot(Matrix4.identity()));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('resets rotation on tap up', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Card3D(child: SizedBox(width: 200, height: 200)),
          ),
        ),
      );

      await tester.tap(find.byType(Card3D));
      await tester.pumpAndSettle();

      final transform = tester.widget<Transform>(find.byType(Transform).first);
      final matrix = transform.transform;
      expect(matrix.getMaxScaleOnAxis(), closeTo(1.0, 0.01));
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card3D(onTap: () => tapped = true, child: const Text('Test')),
          ),
        ),
      );

      await tester.tap(find.byType(Card3D));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Card3D(padding: EdgeInsets.all(24), child: Text('Test')),
          ),
        ),
      );

      final card3D = tester.widget<Card3D>(find.byType(Card3D));
      expect(card3D.padding, const EdgeInsets.all(24));
    });

    testWidgets('uses white background by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Card3D(child: Text('Test'))),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
    });

    testWidgets('applies custom background color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Card3D(backgroundColor: Colors.pink, child: Text('Test')),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.pink);
    });
  });
}
