import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/widgets/animated_tap_button.dart';

void main() {
  group('AnimatedTapButton', () {
    testWidgets('should render child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedTapButton(onTap: () {}, child: const Text('버튼')),
          ),
        ),
      );

      expect(find.text('버튼'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedTapButton(
              onTap: () => tapped = true,
              child: const Text('버튼'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AnimatedTapButton));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('should use AnimatedScale widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedTapButton(
              onTap: () {},
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedScale), findsOneWidget);
    });

    testWidgets('should have scale 1.0 when not pressed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedTapButton(
              onTap: () {},
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );

      final transform = tester.widget<AnimatedScale>(
        find.byType(AnimatedScale),
      );
      expect(transform.scale, equals(1.0));
    });

    testWidgets('should not respond when disabled', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedTapButton(onTap: null, child: const Text('버튼')),
          ),
        ),
      );

      await tester.tap(find.byType(AnimatedTapButton), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });

    testWidgets('should use GestureDetector', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedTapButton(onTap: () {}, child: const Text('버튼')),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });
}
