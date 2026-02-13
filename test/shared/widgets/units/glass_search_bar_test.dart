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

    testWidgets('has container with border decoration', (tester) async {
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
      expect(decoration?.border, isNotNull);
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
      expect(decoration?.color?.a, lessThan(1.0));
    });

    testWidgets('has rounded corners', (tester) async {
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
      expect(decoration?.borderRadius, isNotNull);
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

    group('Input Mode (with controller)', () {
      testWidgets('renders TextField when controller is provided', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassSearchBar(controller: controller),
            ),
          ),
        );

        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('calls onChanged when text changes', (tester) async {
        final controller = TextEditingController();
        String? changedText;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassSearchBar(
                controller: controller,
                onChanged: (text) => changedText = text,
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'test');
        expect(changedText, 'test');
      });

      testWidgets('calls onSubmitted when submitted', (tester) async {
        final controller = TextEditingController();
        String? submittedText;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassSearchBar(
                controller: controller,
                onSubmitted: (text) => submittedText = text,
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'search query');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();

        expect(submittedText, 'search query');
      });

      testWidgets('shows clear button when text is not empty', (tester) async {
        final controller = TextEditingController(text: 'some text');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassSearchBar(controller: controller),
            ),
          ),
        );

        expect(find.byIcon(Icons.clear), findsOneWidget);
      });

      testWidgets('hides clear button when text is empty', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassSearchBar(controller: controller),
            ),
          ),
        );

        expect(find.byIcon(Icons.clear), findsNothing);
      });

      testWidgets('calls onClear and clears text when clear button tapped', (tester) async {
        final controller = TextEditingController(text: 'some text');
        var clearCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassSearchBar(
                controller: controller,
                onClear: () => clearCalled = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.clear));
        await tester.pump();

        expect(clearCalled, isTrue);
        expect(controller.text, isEmpty);
      });
    });
  });
}
