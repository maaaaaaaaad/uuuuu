import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/image_thumbnail_grid.dart';

void main() {
  group('ImageThumbnailGrid', () {
    testWidgets('should render GridView with 2 columns', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageThumbnailGrid(
              imageUrls: ['image1.jpg', 'image2.jpg', 'image3.jpg'],
            ),
          ),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.crossAxisCount, 2);
    });

    testWidgets('should render correct number of thumbnails', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageThumbnailGrid(
              imageUrls: ['image1.jpg', 'image2.jpg', 'image3.jpg'],
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('thumbnail_0')), findsOneWidget);
      expect(find.byKey(const Key('thumbnail_1')), findsOneWidget);
      expect(find.byKey(const Key('thumbnail_2')), findsOneWidget);
    });

    testWidgets('should have square aspect ratio thumbnails', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageThumbnailGrid(
              imageUrls: ['image1.jpg', 'image2.jpg'],
            ),
          ),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.childAspectRatio, 1.0);
    });

    testWidgets('should have 8px spacing between items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageThumbnailGrid(
              imageUrls: ['image1.jpg', 'image2.jpg'],
            ),
          ),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.crossAxisSpacing, 8.0);
      expect(delegate.mainAxisSpacing, 8.0);
    });

    testWidgets('should have 12px border radius on thumbnails', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageThumbnailGrid(
              imageUrls: ['image1.jpg'],
            ),
          ),
        ),
      );

      final clipRRect = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byKey(const Key('thumbnail_0')),
          matching: find.byType(ClipRRect),
        ),
      );

      expect(clipRRect.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('should call onImageTap with correct index when tapped', (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageThumbnailGrid(
              imageUrls: ['image1.jpg', 'image2.jpg', 'image3.jpg'],
              onImageTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('thumbnail_1')));
      await tester.pump();

      expect(tappedIndex, 1);
    });

    testWidgets('should render Image.network for each thumbnail', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageThumbnailGrid(
              imageUrls: ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsNWidgets(2));
    });

    testWidgets('should have placeholder background color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageThumbnailGrid(
              imageUrls: ['https://example.com/image.jpg'],
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const Key('thumbnail_0')),
          matching: find.byType(Container),
        ),
      );

      expect(container.color, isNotNull);
    });

    testWidgets('should show empty state when no images provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageThumbnailGrid(
              imageUrls: [],
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('empty_state')), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
    });

    testWidgets('should not render GridView when empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageThumbnailGrid(
              imageUrls: [],
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('should support custom column count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageThumbnailGrid(
              imageUrls: ['image1.jpg', 'image2.jpg', 'image3.jpg'],
              crossAxisCount: 3,
            ),
          ),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.crossAxisCount, 3);
    });

    testWidgets('should use shrinkWrap for flexible height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ImageThumbnailGrid(
                imageUrls: ['image1.jpg', 'image2.jpg'],
              ),
            ),
          ),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));

      expect(gridView.shrinkWrap, true);
    });

    testWidgets('should have NeverScrollableScrollPhysics by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageThumbnailGrid(
              imageUrls: ['image1.jpg', 'image2.jpg'],
            ),
          ),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));

      expect(gridView.physics, isA<NeverScrollableScrollPhysics>());
    });

    testWidgets('should support custom image size via mainAxisExtent', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageThumbnailGrid(
              imageUrls: ['image1.jpg', 'image2.jpg'],
              imageSize: 80,
            ),
          ),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.mainAxisExtent, 80);
    });

    testWidgets('should use childAspectRatio when imageSize is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageThumbnailGrid(
              imageUrls: ['image1.jpg', 'image2.jpg'],
            ),
          ),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.childAspectRatio, 1.0);
      expect(delegate.mainAxisExtent, isNull);
    });
  });
}
