import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/full_screen_image_viewer.dart';

void main() {
  group('FullScreenImageViewer', () {
    const testImages = [
      'https://example.com/image1.jpg',
      'https://example.com/image2.jpg',
      'https://example.com/image3.jpg',
      'https://example.com/image4.jpg',
      'https://example.com/image5.jpg',
    ];

    testWidgets('should display image at initial index', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FullScreenImageViewer(
            images: testImages,
            initialIndex: 2,
          ),
        ),
      );

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.controller?.initialPage, 2);
    });

    testWidgets('should display current index text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FullScreenImageViewer(
            images: testImages,
            initialIndex: 0,
          ),
        ),
      );

      expect(find.text('1/5'), findsOneWidget);
    });

    testWidgets('should update index text on swipe', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FullScreenImageViewer(
            images: testImages,
            initialIndex: 0,
          ),
        ),
      );

      expect(find.text('1/5'), findsOneWidget);

      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text('2/5'), findsOneWidget);
    });

    testWidgets('should have close button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FullScreenImageViewer(
            images: testImages,
            initialIndex: 0,
          ),
        ),
      );

      expect(find.byKey(const Key('close_button')), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should close when close button tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageViewer(
                        images: testImages,
                        initialIndex: 0,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(FullScreenImageViewer), findsOneWidget);

      await tester.tap(find.byKey(const Key('close_button')));
      await tester.pumpAndSettle();

      expect(find.byType(FullScreenImageViewer), findsNothing);
    });

    testWidgets('should have black semi-transparent background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FullScreenImageViewer(
            images: testImages,
            initialIndex: 0,
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.black);
    });

    testWidgets('should close when background tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageViewer(
                        images: testImages,
                        initialIndex: 0,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(FullScreenImageViewer), findsOneWidget);

      await tester.tap(find.byKey(const Key('background_tap_area')));
      await tester.pumpAndSettle();

      expect(find.byType(FullScreenImageViewer), findsNothing);
    });

    testWidgets('should have InteractiveViewer for zoom support', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FullScreenImageViewer(
            images: testImages,
            initialIndex: 0,
          ),
        ),
      );

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('should have PageView for swiping between images', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FullScreenImageViewer(
            images: testImages,
            initialIndex: 0,
          ),
        ),
      );

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should display index text at bottom center', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FullScreenImageViewer(
            images: testImages,
            initialIndex: 0,
          ),
        ),
      );

      final indexContainer = find.byKey(const Key('index_indicator'));
      expect(indexContainer, findsOneWidget);

      final positioned = tester.widget<Positioned>(
        find.ancestor(
          of: indexContainer,
          matching: find.byType(Positioned),
        ).first,
      );
      expect(positioned.bottom, isNotNull);
    });

    testWidgets('should have white close icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FullScreenImageViewer(
            images: testImages,
            initialIndex: 0,
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.close));
      expect(icon.color, Colors.white);
    });

    testWidgets('should start from initialIndex 0 by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FullScreenImageViewer(
            images: testImages,
          ),
        ),
      );

      expect(find.text('1/5'), findsOneWidget);
    });

    testWidgets('should handle single image', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FullScreenImageViewer(
            images: ['https://example.com/single.jpg'],
          ),
        ),
      );

      expect(find.text('1/1'), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
    });
  });
}
