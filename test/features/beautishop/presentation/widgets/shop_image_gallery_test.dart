import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_image_gallery.dart';

void main() {
  group('ShopImageGallery', () {
    testWidgets('should render PageView for images', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopImageGallery(
              images: ['image1.jpg', 'image2.jpg', 'image3.jpg'],
            ),
          ),
        ),
      );

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should show page indicator dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopImageGallery(
              images: ['image1.jpg', 'image2.jpg', 'image3.jpg'],
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('page_indicator')), findsOneWidget);
    });

    testWidgets('should have correct number of indicator dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopImageGallery(
              images: ['image1.jpg', 'image2.jpg', 'image3.jpg'],
            ),
          ),
        ),
      );

      final indicator = find.byKey(const Key('page_indicator'));
      final indicatorWidget = tester.widget<Row>(
        find.descendant(of: indicator, matching: find.byType(Row)),
      );

      expect(indicatorWidget.children.length, 3);
    });

    testWidgets('should update indicator on page change', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopImageGallery(
              images: ['image1.jpg', 'image2.jpg', 'image3.jpg'],
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('indicator_dot_0_active')), findsOneWidget);
      expect(find.byKey(const Key('indicator_dot_1_inactive')), findsOneWidget);

      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byKey(const Key('indicator_dot_0_inactive')), findsOneWidget);
      expect(find.byKey(const Key('indicator_dot_1_active')), findsOneWidget);
    });

    testWidgets('should show placeholder when no images', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopImageGallery(images: []),
          ),
        ),
      );

      expect(find.byIcon(Icons.store), findsOneWidget);
    });

    testWidgets('should use square aspect ratio by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopImageGallery(
              images: ['image1.jpg'],
            ),
          ),
        ),
      );

      expect(find.byType(AspectRatio), findsOneWidget);
      final aspectRatio = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatio.aspectRatio, 1.0);
    });

    testWidgets('should call onTap when image is tapped', (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShopImageGallery(
              images: ['image1.jpg', 'image2.jpg'],
              onImageTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      expect(tappedIndex, 0);
    });
  });
}
