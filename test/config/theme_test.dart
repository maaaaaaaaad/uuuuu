import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/config/theme.dart';

void main() {
  group('AppTheme', () {
    group('lightTheme', () {
      test('should have pastel pink as primary color', () {
        final theme = AppTheme.lightTheme;

        expect(theme.colorScheme.primary, AppTheme.pastelPink);
      });

      test('should use Esamanru font family', () {
        final theme = AppTheme.lightTheme;

        expect(theme.textTheme.bodyMedium?.fontFamily, 'Esamanru');
      });

      test('should use Material3', () {
        final theme = AppTheme.lightTheme;

        expect(theme.useMaterial3, true);
      });

      test('should have rounded FilledButton style', () {
        final theme = AppTheme.lightTheme;
        final buttonStyle = theme.filledButtonTheme.style;

        expect(buttonStyle, isNotNull);
        final shape = buttonStyle!.shape?.resolve({});
        expect(shape, isA<RoundedRectangleBorder>());
      });

      test('should have rounded OutlinedButton style', () {
        final theme = AppTheme.lightTheme;
        final buttonStyle = theme.outlinedButtonTheme.style;

        expect(buttonStyle, isNotNull);
        final shape = buttonStyle!.shape?.resolve({});
        expect(shape, isA<RoundedRectangleBorder>());
      });

      test('should have consistent text styles with Esamanru font', () {
        final theme = AppTheme.lightTheme;

        expect(theme.textTheme.headlineLarge?.fontFamily, 'Esamanru');
        expect(theme.textTheme.titleMedium?.fontFamily, 'Esamanru');
        expect(theme.textTheme.labelLarge?.fontFamily, 'Esamanru');
      });
    });
  });
}
