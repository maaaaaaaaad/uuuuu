import 'package:flutter/material.dart';

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
        ? const Color(0xFFFFB5BA)
        : Colors.grey[100];

    final iconColor = isSelected ? Colors.white : const Color(0xFF2D2D2D);

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
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                BoxShadow(
                  offset: const Offset(-2, -2),
                  blurRadius: 6,
                  color: Colors.white.withValues(alpha: 0.9),
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
                  ? const Color(0xFFFF8A94)
                  : const Color(0xFF2D2D2D),
            ),
          ),
        ],
      ),
    );
  }
}
