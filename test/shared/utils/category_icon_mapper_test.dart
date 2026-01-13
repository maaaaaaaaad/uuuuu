import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/utils/category_icon_mapper.dart';

void main() {
  group('CategoryIconMapper', () {
    test('should return brush icon for 네일', () {
      expect(CategoryIconMapper.getIcon('네일'), Icons.brush);
    });

    test('should return visibility icon for 속눈썹', () {
      expect(CategoryIconMapper.getIcon('속눈썹'), Icons.visibility);
    });

    test('should return spa icon for 왁싱', () {
      expect(CategoryIconMapper.getIcon('왁싱'), Icons.spa);
    });

    test('should return face icon for 피부관리', () {
      expect(CategoryIconMapper.getIcon('피부관리'), Icons.face);
    });

    test('should return sunny icon for 태닝', () {
      expect(CategoryIconMapper.getIcon('태닝'), Icons.wb_sunny);
    });

    test('should return walk icon for 발관리', () {
      expect(CategoryIconMapper.getIcon('발관리'), Icons.directions_walk);
    });

    test('should return content_cut icon for 헤어', () {
      expect(CategoryIconMapper.getIcon('헤어'), Icons.content_cut);
    });

    test('should return palette icon for 메이크업', () {
      expect(CategoryIconMapper.getIcon('메이크업'), Icons.palette);
    });

    test('should return remove_red_eye icon for 눈썹', () {
      expect(CategoryIconMapper.getIcon('눈썹'), Icons.remove_red_eye);
    });

    test('should return self_improvement icon for 마사지', () {
      expect(CategoryIconMapper.getIcon('마사지'), Icons.self_improvement);
    });

    test('should return default icon for unknown category', () {
      expect(CategoryIconMapper.getIcon('알수없는카테고리'), Icons.category);
    });

    test('should handle case with spaces in category name', () {
      expect(CategoryIconMapper.getIcon('  네일  '), Icons.brush);
    });

    test('should handle partial match for category containing keyword', () {
      expect(CategoryIconMapper.getIcon('젤네일'), Icons.brush);
    });
  });
}
