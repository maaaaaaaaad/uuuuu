import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/category/domain/entities/category.dart';
import 'package:jellomark/features/search/presentation/widgets/shop_filter_bottom_sheet.dart';

void main() {
  group('ShopFilterBottomSheet', () {
    final testCategories = [
      const Category(id: 'cat-1', name: '네일'),
      const Category(id: 'cat-2', name: '헤어'),
      const Category(id: 'cat-3', name: '피부관리'),
    ];

    Widget createTestWidget({
      List<Category> categories = const [],
      String? selectedCategoryId,
      double? minRating,
      String sortBy = 'RATING',
      void Function(String?)? onCategoryChanged,
      void Function(double?)? onRatingChanged,
      void Function(String)? onSortChanged,
      VoidCallback? onApply,
      VoidCallback? onReset,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ShopFilterBottomSheet(
              categories: categories,
              selectedCategoryId: selectedCategoryId,
              minRating: minRating,
              sortBy: sortBy,
              onCategoryChanged: onCategoryChanged ?? (_) {},
              onRatingChanged: onRatingChanged ?? (_) {},
              onSortChanged: onSortChanged ?? (_) {},
              onApply: onApply ?? () {},
              onReset: onReset ?? () {},
            ),
          ),
        ),
      );
    }

    testWidgets('should display section headers', (tester) async {
      await tester.pumpWidget(createTestWidget(categories: testCategories));

      expect(find.text('카테고리'), findsOneWidget);
      expect(find.text('최소 평점'), findsOneWidget);
      expect(find.text('정렬'), findsOneWidget);
    });

    testWidgets('should display all categories as chips', (tester) async {
      await tester.pumpWidget(createTestWidget(categories: testCategories));

      expect(find.text('전체'), findsWidgets);
      expect(find.text('네일'), findsOneWidget);
      expect(find.text('헤어'), findsOneWidget);
      expect(find.text('피부관리'), findsOneWidget);
    });

    testWidgets('should display rating filter options', (tester) async {
      await tester.pumpWidget(createTestWidget(categories: testCategories));

      expect(find.text('전체'), findsWidgets);
      expect(find.text('4.0+'), findsOneWidget);
      expect(find.text('3.0+'), findsOneWidget);
    });

    testWidgets('should display sort options', (tester) async {
      await tester.pumpWidget(createTestWidget(categories: testCategories));

      expect(find.text('평점순'), findsOneWidget);
      expect(find.text('리뷰 많은순'), findsOneWidget);
      expect(find.text('최신순'), findsOneWidget);
    });

    testWidgets('should display apply and reset buttons', (tester) async {
      await tester.pumpWidget(createTestWidget(categories: testCategories));

      expect(find.text('초기화'), findsOneWidget);
      expect(find.text('적용'), findsOneWidget);
    });

    testWidgets('should call onCategoryChanged when category tapped', (tester) async {
      String? selectedCategory;

      await tester.pumpWidget(createTestWidget(
        categories: testCategories,
        onCategoryChanged: (id) => selectedCategory = id,
      ));

      await tester.tap(find.text('네일'));
      await tester.pumpAndSettle();

      expect(selectedCategory, equals('cat-1'));
    });

    testWidgets('should call onRatingChanged when rating tapped', (tester) async {
      double? selectedRating;

      await tester.pumpWidget(createTestWidget(
        categories: testCategories,
        onRatingChanged: (rating) => selectedRating = rating,
      ));

      await tester.tap(find.text('4.0+'));
      await tester.pumpAndSettle();

      expect(selectedRating, equals(4.0));
    });

    testWidgets('should call onSortChanged when sort option tapped', (tester) async {
      String? selectedSort;

      await tester.pumpWidget(createTestWidget(
        categories: testCategories,
        onSortChanged: (sort) => selectedSort = sort,
      ));

      await tester.tap(find.text('리뷰 많은순'));
      await tester.pumpAndSettle();

      expect(selectedSort, equals('REVIEW_COUNT'));
    });

    testWidgets('should call onApply when apply button tapped', (tester) async {
      bool applyCalled = false;

      await tester.pumpWidget(createTestWidget(
        categories: testCategories,
        onApply: () => applyCalled = true,
      ));

      await tester.tap(find.text('적용'));
      await tester.pumpAndSettle();

      expect(applyCalled, isTrue);
    });

    testWidgets('should call onReset when reset button tapped', (tester) async {
      bool resetCalled = false;

      await tester.pumpWidget(createTestWidget(
        categories: testCategories,
        onReset: () => resetCalled = true,
      ));

      await tester.tap(find.text('초기화'));
      await tester.pumpAndSettle();

      expect(resetCalled, isTrue);
    });

    testWidgets('should highlight selected category', (tester) async {
      await tester.pumpWidget(createTestWidget(
        categories: testCategories,
        selectedCategoryId: 'cat-2',
      ));

      final hairChip = find.ancestor(
        of: find.text('헤어'),
        matching: find.byKey(const Key('category_chip_cat-2')),
      );

      expect(hairChip, findsOneWidget);
    });

    testWidgets('should highlight selected sort option', (tester) async {
      await tester.pumpWidget(createTestWidget(
        categories: testCategories,
        sortBy: 'REVIEW_COUNT',
      ));

      final sortChip = find.byKey(const Key('sort_chip_REVIEW_COUNT'));
      expect(sortChip, findsOneWidget);
    });
  });
}
