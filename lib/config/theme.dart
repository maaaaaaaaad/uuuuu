import 'package:flutter/material.dart';

class AppTheme {
  static const Color pastelPink = Color(0xFFFFB6C1);
  static const double _buttonRadius = 16.0;

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: pastelPink,
      brightness: Brightness.light,
    ).copyWith(
      primary: pastelPink,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_buttonRadius),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Esamanru',
      colorScheme: colorScheme,
      textTheme: const TextTheme().apply(fontFamily: 'Esamanru'),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: buttonShape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: buttonShape),
      ),
    );
  }
}
