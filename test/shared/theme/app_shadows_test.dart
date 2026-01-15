import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/theme/app_shadows.dart';

void main() {
  group('AppShadows', () {
    group('shadowSoft', () {
      test('should be a BoxShadow', () {
        expect(AppShadows.shadowSoft, isA<BoxShadow>());
      });

      test('should have blurRadius 10', () {
        expect(AppShadows.shadowSoft.blurRadius, 10.0);
      });

      test('should have opacity 0.1', () {
        expect(AppShadows.shadowSoft.color.a, closeTo(0.1, 0.01));
      });
    });

    group('shadowMedium', () {
      test('should be a BoxShadow', () {
        expect(AppShadows.shadowMedium, isA<BoxShadow>());
      });

      test('should have blurRadius 20', () {
        expect(AppShadows.shadowMedium.blurRadius, 20.0);
      });

      test('should have opacity 0.15', () {
        expect(AppShadows.shadowMedium.color.a, closeTo(0.15, 0.01));
      });
    });

    group('shadowFloat', () {
      test('should be a BoxShadow', () {
        expect(AppShadows.shadowFloat, isA<BoxShadow>());
      });

      test('should have blurRadius 30', () {
        expect(AppShadows.shadowFloat.blurRadius, 30.0);
      });

      test('should have offset 10', () {
        expect(AppShadows.shadowFloat.offset.dy, 10.0);
      });

      test('should have opacity 0.2', () {
        expect(AppShadows.shadowFloat.color.a, closeTo(0.2, 0.01));
      });
    });
  });
}
