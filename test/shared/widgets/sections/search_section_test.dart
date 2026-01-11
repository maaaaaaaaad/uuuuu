import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/widgets/sections/search_section.dart';
import 'package:jellomark/shared/widgets/units/glass_search_bar.dart';

void main() {
  group('SearchSection', () {
    testWidgets('renders GlassSearchBar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchSection(),
          ),
        ),
      );

      expect(find.byType(GlassSearchBar), findsOneWidget);
    });

    testWidgets('displays location text when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchSection(locationText: '서울시 강남구'),
          ),
        ),
      );

      expect(find.text('서울시 강남구'), findsOneWidget);
    });

    testWidgets('calls onSearchTap when search bar is tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchSection(
              onSearchTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GlassSearchBar));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('has horizontal padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchSection(),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find.ancestor(
          of: find.byType(GlassSearchBar),
          matching: find.byType(Padding),
        ).first,
      );

      expect(padding.padding, isNotNull);
    });
  });
}
