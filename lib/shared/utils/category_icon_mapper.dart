import 'package:flutter/material.dart';

class CategoryIconMapper {
  static const Map<String, IconData> _exactMapping = {
    '네일': Icons.brush,
    '속눈썹': Icons.visibility,
    '왁싱': Icons.spa,
    '피부관리': Icons.face,
    '태닝': Icons.wb_sunny,
    '발관리': Icons.directions_walk,
    '헤어': Icons.content_cut,
    '메이크업': Icons.palette,
    '눈썹': Icons.remove_red_eye,
    '마사지': Icons.self_improvement,
  };

  static const List<MapEntry<String, IconData>> _containsMapping = [
    MapEntry('네일', Icons.brush),
    MapEntry('래쉬', Icons.visibility),
    MapEntry('눈썹', Icons.remove_red_eye),
    MapEntry('왁싱', Icons.spa),
    MapEntry('피부', Icons.face),
    MapEntry('태닝', Icons.wb_sunny),
    MapEntry('발', Icons.directions_walk),
    MapEntry('헤어', Icons.content_cut),
    MapEntry('메이크업', Icons.palette),
    MapEntry('마사지', Icons.self_improvement),
  ];

  static IconData getIcon(String categoryName) {
    final trimmed = categoryName.trim();

    if (_exactMapping.containsKey(trimmed)) {
      return _exactMapping[trimmed]!;
    }

    for (final entry in _containsMapping) {
      if (trimmed.contains(entry.key)) {
        return entry.value;
      }
    }

    return Icons.category;
  }
}
