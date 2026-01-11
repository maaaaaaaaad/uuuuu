import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/auth/presentation/pages/login_page.dart';

void main() {
  group('LoginPage', () {
    Widget createLoginPage() {
      return MaterialApp(
        home: const LoginPage(),
        routes: {'/home': (context) => const Scaffold(body: Text('Home'))},
      );
    }

    testWidgets('should render login page with app logo', (tester) async {
      await tester.pumpWidget(createLoginPage());

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should display Kakao login button', (tester) async {
      await tester.pumpWidget(createLoginPage());

      expect(find.text('카카오로 시작하기'), findsOneWidget);
    });

    testWidgets('should navigate to home when button is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createLoginPage());

      await tester.tap(find.text('카카오로 시작하기'));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });
  });
}
