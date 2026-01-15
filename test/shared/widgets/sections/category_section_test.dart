import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/widgets/pill_chip.dart';
import 'package:jellomark/shared/widgets/sections/category_section.dart';

void main() {
  final testCategories = [
    const CategoryData(id: '1', label: '네일', icon: Icons.brush),
    const CategoryData(id: '2', label: '속눈썹', icon: Icons.visibility),
    const CategoryData(id: '3', label: '왁싱', icon: Icons.spa),
    const CategoryData(id: '4', label: '피부관리', icon: Icons.face),
  ];

  group('CategorySection', () {
    testWidgets('renders horizontal scrollable list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySection(categories: testCategories),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('renders all category chips as PillChips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySection(categories: testCategories),
          ),
        ),
      );

      expect(find.byType(PillChip), findsNWidgets(4));
    });

    testWidgets('displays category labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySection(categories: testCategories),
          ),
        ),
      );

      expect(find.text('네일'), findsOneWidget);
      expect(find.text('속눈썹'), findsOneWidget);
      expect(find.text('왁싱'), findsOneWidget);
      expect(find.text('피부관리'), findsOneWidget);
    });

    testWidgets('calls onCategoryTap when category is tapped', (tester) async {
      String? tappedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySection(
              categories: testCategories,
              onCategoryTap: (id) => tappedId = id,
            ),
          ),
        ),
      );

      await tester.tap(find.text('네일'));
      await tester.pumpAndSettle();

      expect(tappedId, '1');
    });

    testWidgets('highlights selected category', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySection(
              categories: testCategories,
              selectedCategoryId: '2',
            ),
          ),
        ),
      );

      final chips = tester.widgetList<PillChip>(find.byType(PillChip));
      final selectedChip = chips.firstWhere((chip) => chip.isSelected);
      expect(selectedChip.label, '속눈썹');
    });

    testWidgets('scrolls horizontally', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySection(categories: testCategories),
          ),
        ),
      );

      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollView.scrollDirection, Axis.horizontal);
    });
  });

  group('CategoryData', () {
    test('creates instance with required fields', () {
      const data = CategoryData(
        id: '1',
        label: '네일',
        icon: Icons.brush,
      );

      expect(data.id, '1');
      expect(data.label, '네일');
      expect(data.icon, Icons.brush);
    });
  });
}
