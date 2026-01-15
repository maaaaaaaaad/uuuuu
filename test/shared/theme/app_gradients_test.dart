import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/theme/app_colors.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';

void main() {
  group('AppGradients', () {
    group('lavenderGradient', () {
      test('should be a LinearGradient', () {
        expect(AppGradients.lavenderGradient, isA<LinearGradient>());
      });

      test('should use lavender colors', () {
        final gradient = AppGradients.lavenderGradient;
        expect(gradient.colors, contains(AppColors.lavenderLight));
        expect(gradient.colors, contains(AppColors.lavenderDark));
      });

      test('should flow from top to bottom', () {
        final gradient = AppGradients.lavenderGradient;
        expect(gradient.begin, Alignment.topCenter);
        expect(gradient.end, Alignment.bottomCenter);
      });
    });

    group('mintGradient', () {
      test('should be a LinearGradient', () {
        expect(AppGradients.mintGradient, isA<LinearGradient>());
      });

      test('should use teal and mint colors', () {
        final gradient = AppGradients.mintGradient;
        expect(gradient.colors, contains(AppColors.teal));
        expect(gradient.colors, contains(AppColors.mint));
      });

      test('should flow from left to right', () {
        final gradient = AppGradients.mintGradient;
        expect(gradient.begin, Alignment.centerLeft);
        expect(gradient.end, Alignment.centerRight);
      });
    });

    group('pinkGradient', () {
      test('should be a LinearGradient', () {
        expect(AppGradients.pinkGradient, isA<LinearGradient>());
      });

      test('should use pastel pink color', () {
        final gradient = AppGradients.pinkGradient;
        expect(gradient.colors, contains(AppColors.pastelPink));
      });

      test('should flow from left to right', () {
        final gradient = AppGradients.pinkGradient;
        expect(gradient.begin, Alignment.centerLeft);
        expect(gradient.end, Alignment.centerRight);
      });
    });
  });
}
