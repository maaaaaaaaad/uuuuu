import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? iconImagePath;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.label,
    this.icon,
    this.iconImagePath,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? SemanticColors.background.chipSelected
        : SemanticColors.background.chip;

    final iconColor = isSelected ? SemanticColors.icon.onDark : SemanticColors.text.primary;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(3, 3),
                  blurRadius: 6,
                  color: SemanticColors.overlay.neumorphicDark,
                ),
                BoxShadow(
                  offset: const Offset(-2, -2),
                  blurRadius: 6,
                  color: SemanticColors.overlay.neumorphicLight,
                ),
              ],
            ),
            child: Center(
              child: iconImagePath != null
                  ? Image.asset(iconImagePath!, width: 32, height: 32)
                  : Icon(icon ?? Icons.category, size: 28, color: iconColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? SemanticColors.text.accent
                  : SemanticColors.text.primary,
            ),
          ),
        ],
      ),
    );
  }
}
