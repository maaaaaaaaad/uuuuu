import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/service_menu_item.dart';

void main() {
  group('ServiceMenuItem', () {
    testWidgets('should display service name', (tester) async {
      const menu = ServiceMenu(id: '1', name: '젤네일 기본', price: 50000);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ServiceMenuItem(menu: menu),
          ),
        ),
      );

      expect(find.text('젤네일 기본'), findsOneWidget);
    });

    testWidgets('should display formatted price', (tester) async {
      const menu = ServiceMenu(id: '1', name: '젤네일 기본', price: 50000);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ServiceMenuItem(menu: menu),
          ),
        ),
      );

      expect(find.text('50,000원'), findsOneWidget);
    });

    testWidgets('should display duration when provided', (tester) async {
      const menu = ServiceMenu(
        id: '1',
        name: '젤네일 기본',
        price: 50000,
        durationMinutes: 60,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ServiceMenuItem(menu: menu),
          ),
        ),
      );

      expect(find.text('1시간'), findsOneWidget);
    });

    testWidgets('should display description when provided', (tester) async {
      const menu = ServiceMenu(
        id: '1',
        name: '젤네일 기본',
        price: 50000,
        description: '기본 단색 컬러 포함',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ServiceMenuItem(menu: menu),
          ),
        ),
      );

      expect(find.text('기본 단색 컬러 포함'), findsOneWidget);
    });

    testWidgets('should show discount price with strikethrough', (tester) async {
      const menu = ServiceMenu(
        id: '1',
        name: '젤네일 기본',
        price: 50000,
        discountPrice: 40000,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ServiceMenuItem(menu: menu),
          ),
        ),
      );

      expect(find.text('40,000원'), findsOneWidget);
      expect(find.text('50,000원'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      const menu = ServiceMenu(id: '1', name: '젤네일 기본', price: 50000);
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceMenuItem(
              menu: menu,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ServiceMenuItem));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
