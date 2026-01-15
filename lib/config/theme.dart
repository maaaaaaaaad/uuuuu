import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jellomark/shared/theme/app_colors.dart';

class AppTheme {
  static const double _buttonRadius = 16.0;

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.pastelPink,
      brightness: Brightness.light,
    ).copyWith(primary: AppColors.pastelPink);

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_buttonRadius),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Esamanru',
      colorScheme: colorScheme,
      textTheme: const TextTheme().apply(fontFamily: 'Esamanru'),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: buttonShape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: buttonShape),
      ),
    );
  }
}
