import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    group('Primary Colors', () {
      test('pastelPink should be #FFB5BA', () {
        expect(AppColors.pastelPink, const Color(0xFFFFB5BA));
      });
    });

    group('Lavender Colors', () {
      test('lavenderLight should be #E8E0F0', () {
        expect(AppColors.lavenderLight, const Color(0xFFE8E0F0));
      });

      test('lavenderDark should be #B8A9E8', () {
        expect(AppColors.lavenderDark, const Color(0xFFB8A9E8));
      });
    });

    group('Mint/Teal Colors', () {
      test('mint should be alias of pastelPink', () {
        expect(AppColors.mint, AppColors.pastelPink);
      });

      test('teal should be alias of pastelPink', () {
        expect(AppColors.teal, AppColors.pastelPink);
      });
    });

    group('Glass Colors', () {
      test('glassWhite should be white with 60% opacity', () {
        expect(AppColors.glassWhite, Colors.white.withValues(alpha: 0.6));
      });

      test('glassBorder should be white with 30% opacity', () {
        expect(AppColors.glassBorder, Colors.white.withValues(alpha: 0.3));
      });
    });
  });
}
