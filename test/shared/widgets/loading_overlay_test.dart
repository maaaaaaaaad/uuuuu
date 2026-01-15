import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/theme/app_colors.dart';
import 'package:jellomark/shared/widgets/loading_overlay.dart';

void main() {
  group('LoadingOverlay', () {
    testWidgets('should show child when not loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingOverlay(isLoading: false, child: Text('콘텐츠')),
        ),
      );

      expect(find.text('콘텐츠'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show loading indicator when loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingOverlay(isLoading: true, child: Text('콘텐츠')),
        ),
      );

      expect(find.text('콘텐츠'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show semi-transparent overlay when loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingOverlay(isLoading: true, child: Text('콘텐츠')),
        ),
      );

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(LoadingOverlay),
          matching: find.byType(Container),
        ),
      );

      bool hasOverlay = false;
      for (final container in containers) {
        if (container.color != null ||
            (container.decoration is BoxDecoration &&
                (container.decoration as BoxDecoration).color != null)) {
          hasOverlay = true;
          break;
        }
      }
      expect(hasOverlay, isTrue);
    });

    testWidgets('should show loading text when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingOverlay(
            isLoading: true,
            loadingText: '로딩 중...',
            child: Text('콘텐츠'),
          ),
        ),
      );

      expect(find.text('로딩 중...'), findsOneWidget);
    });

    testWidgets('should not show loading text when not loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingOverlay(
            isLoading: false,
            loadingText: '로딩 중...',
            child: Text('콘텐츠'),
          ),
        ),
      );

      expect(find.text('로딩 중...'), findsNothing);
    });

    testWidgets('should use Stack to layer content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingOverlay(isLoading: true, child: Text('콘텐츠')),
        ),
      );

      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('should block interaction when loading', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: LoadingOverlay(
            isLoading: true,
            child: ElevatedButton(
              onPressed: () => tapped = true,
              child: const Text('버튼'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('버튼'), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('should allow interaction when not loading', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: LoadingOverlay(
            isLoading: false,
            child: ElevatedButton(
              onPressed: () => tapped = true,
              child: const Text('버튼'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('버튼'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    group('UI Redesign', () {
      testWidgets('has BackdropFilter for glassmorphism', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: LoadingOverlay(isLoading: true, child: Text('콘텐츠')),
          ),
        );

        expect(find.byType(BackdropFilter), findsWidgets);
      });

      testWidgets('has glassWhite background color', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: LoadingOverlay(isLoading: true, child: Text('콘텐츠')),
          ),
        );

        final containers = tester.widgetList<Container>(find.byType(Container));
        bool hasGlassBackground = false;
        for (final container in containers) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration &&
              decoration.color == AppColors.glassWhite) {
            hasGlassBackground = true;
            break;
          }
        }
        expect(hasGlassBackground, isTrue);
      });

      testWidgets('CircularProgressIndicator has mint color', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: LoadingOverlay(isLoading: true, child: Text('콘텐츠')),
          ),
        );

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.color, AppColors.mint);
      });
    });
  });
}
