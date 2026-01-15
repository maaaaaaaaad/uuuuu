import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class BottomNavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

class GlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  const GlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: SemanticColors.background.navigation,
            border: Border(
              top: BorderSide(
                color: SemanticColors.border.glass,
                width: 1.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  items.length,
                  (index) => _buildNavItem(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = items[index];
    final isSelected = index == currentIndex;
    final icon = isSelected ? (item.selectedIcon ?? item.icon) : item.icon;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? SemanticColors.icon.selected : SemanticColors.icon.unselected,
              size: 26,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  color: SemanticColors.icon.selected,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
