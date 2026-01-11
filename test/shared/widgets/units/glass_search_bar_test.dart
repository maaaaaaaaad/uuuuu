import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/widgets/units/glass_search_bar.dart';

void main() {
  group('GlassSearchBar', () {
    testWidgets('renders search icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GlassSearchBar())),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('renders hint text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GlassSearchBar(hintText: '검색어를 입력하세요')),
        ),
      );

      expect(find.text('검색어를 입력하세요'), findsOneWidget);
    });

    testWidgets('renders default hint text when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GlassSearchBar())),
      );

      expect(find.text('검색'), findsOneWidget);
    });

    testWidgets('has blur effect with BackdropFilter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GlassSearchBar())),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('has semi-transparent white background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GlassSearchBar())),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(GlassSearchBar),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color?.opacity, lessThan(1.0));
    });

    testWidgets('has rounded corners', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GlassSearchBar())),
      );

      final clippedContainer = tester.widget<ClipRRect>(find.byType(ClipRRect));

      expect(clippedContainer.borderRadius, isNotNull);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GlassSearchBar(onTap: () => tapped = true)),
        ),
      );

      await tester.tap(find.byType(GlassSearchBar));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('displays location text when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GlassSearchBar(locationText: '서울시 강남구')),
        ),
      );

      expect(find.text('서울시 강남구'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('does not show location when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GlassSearchBar())),
      );

      expect(find.byIcon(Icons.location_on), findsNothing);
    });
  });
}
