import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/widgets/units/section_header.dart';

void main() {
  group('SectionHeader', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SectionHeader(title: '내 주변 인기 샵')),
        ),
      );

      expect(find.text('내 주변 인기 샵'), findsOneWidget);
    });

    testWidgets('renders "더보기" button when showMore is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SectionHeader(title: '추천 샵', showMore: true)),
        ),
      );

      expect(find.text('더보기'), findsOneWidget);
    });

    testWidgets('does not render "더보기" button when showMore is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SectionHeader(title: '추천 샵', showMore: false)),
        ),
      );

      expect(find.text('더보기'), findsNothing);
    });

    testWidgets('calls onMoreTap when "더보기" is tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionHeader(
              title: '추천 샵',
              showMore: true,
              onMoreTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('더보기'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('title uses bold font weight', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SectionHeader(title: '테스트')),
        ),
      );

      final text = tester.widget<Text>(find.text('테스트'));
      expect(text.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('title uses size 22', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SectionHeader(title: '테스트')),
        ),
      );

      final text = tester.widget<Text>(find.text('테스트'));
      expect(text.style?.fontSize, 22);
    });

    testWidgets('renders with custom more button text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeader(title: '테스트', showMore: true, moreText: '전체보기'),
          ),
        ),
      );

      expect(find.text('전체보기'), findsOneWidget);
    });

    testWidgets('applies horizontal padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SectionHeader(title: '테스트')),
        ),
      );

      final sectionHeader = tester.widget<SectionHeader>(
        find.byType(SectionHeader),
      );
      expect(sectionHeader.padding, isNotNull);
    });
  });
}
