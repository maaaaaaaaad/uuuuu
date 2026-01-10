import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/app.dart';

void main() {
  group('JelloMarkApp', () {
    testWidgets('should force light mode only (no dark theme)', (tester) async {
      await tester.pumpWidget(const JelloMarkApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(materialApp.darkTheme, isNull);
      expect(materialApp.themeMode, ThemeMode.light);
    });

    testWidgets('should have MaterialApp with correct title', (tester) async {
      await tester.pumpWidget(const JelloMarkApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(materialApp.title, '젤로마크');
      expect(materialApp.debugShowCheckedModeBanner, false);
    });
  });
}
