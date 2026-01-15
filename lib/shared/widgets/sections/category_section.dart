import 'package:flutter/material.dart';
import 'package:jellomark/shared/widgets/pill_chip.dart';

class CategoryData {
  final String id;
  final String label;
  final IconData icon;
  final String? iconImagePath;

  const CategoryData({
    required this.id,
    required this.label,
    required this.icon,
    this.iconImagePath,
  });
}

class CategorySection extends StatelessWidget {
  final List<CategoryData> categories;
  final String? selectedCategoryId;
  final void Function(String id)? onCategoryTap;

  const CategorySection({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PillChip(
              label: category.label,
              icon: category.icon,
              isSelected: category.id == selectedCategoryId,
              onTap: () => onCategoryTap?.call(category.id),
            ),
          );
        }).toList(),
      ),
    );
  }
}
