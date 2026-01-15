import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/app_dimensions.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class PillChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;

  const PillChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? SemanticColors.background.chipSelected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? effectiveSelectedColor : SemanticColors.special.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          border: isSelected
              ? Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1)
              : Border.all(color: SemanticColors.border.secondary, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? SemanticColors.icon.onDark : SemanticColors.icon.secondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? SemanticColors.text.onDark : SemanticColors.icon.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
