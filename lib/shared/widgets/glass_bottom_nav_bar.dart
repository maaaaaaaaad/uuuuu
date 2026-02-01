import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/app_colors.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class BottomNavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool isFloating;

  const BottomNavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.isFloating = false,
  });
}

class GlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  static const double _floatingButtonSize = 56.0;
  static const double _notchMargin = 6.0;
  static const double _barHeight = 70.0;
  static const double _buttonTopOffset = 16.0;

  const GlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  int? get _floatingIndex {
    for (int i = 0; i < items.length; i++) {
      if (items[i].isFloating) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final floatingIndex = _floatingIndex;
    final hasFloating = floatingIndex != null;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final floatingButtonTop = hasFloating ? (_floatingButtonSize / 2) - _buttonTopOffset : 0.0;

    return SizedBox(
      height: _barHeight + bottomPadding + floatingButtonTop,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipPath(
              clipper: hasFloating
                  ? _NotchedNavBarClipper(
                      notchIndex: floatingIndex,
                      itemCount: items.length,
                      notchRadius: (_floatingButtonSize / 2) + _notchMargin,
                      buttonTopOffset: _buttonTopOffset,
                    )
                  : null,
              child: Container(
                height: _barHeight + bottomPadding,
                padding: EdgeInsets.only(bottom: bottomPadding),
                decoration: BoxDecoration(
                  color: SemanticColors.background.navigation,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    items.length,
                    (index) => items[index].isFloating
                        ? const Expanded(child: SizedBox())
                        : _buildNavItem(index),
                  ),
                ),
              ),
            ),
          ),
          if (hasFloating) _buildFloatingButton(context, floatingIndex),
        ],
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
              color: isSelected
                  ? SemanticColors.icon.selected
                  : SemanticColors.icon.unselected,
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

  Widget _buildFloatingButton(BuildContext context, int index) {
    final item = items[index];
    final isSelected = index == currentIndex;
    final icon = isSelected ? (item.selectedIcon ?? item.icon) : item.icon;

    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / items.length;
    final centerX = itemWidth * index + itemWidth / 2;

    final defaultGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.pastelPink, AppColors.accentPink],
    );

    final selectedGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.lavenderLight, AppColors.lavenderDark],
    );

    return Positioned(
      left: centerX - (_floatingButtonSize / 2),
      top: (_floatingButtonSize / 2) - _buttonTopOffset,
      child: GestureDetector(
        key: Key('floating_nav_item_$index'),
        onTap: () => onTap(index),
        child: Container(
          width: _floatingButtonSize,
          height: _floatingButtonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isSelected ? selectedGradient : defaultGradient,
            boxShadow: [
              BoxShadow(
                color: (isSelected ? AppColors.lavenderDark : AppColors.accentPink)
                    .withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: SemanticColors.text.onDark,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _NotchedNavBarClipper extends CustomClipper<Path> {
  final int notchIndex;
  final int itemCount;
  final double notchRadius;
  final double buttonTopOffset;

  _NotchedNavBarClipper({
    required this.notchIndex,
    required this.itemCount,
    required this.notchRadius,
    required this.buttonTopOffset,
  });

  @override
  Path getClip(Size size) {
    const cornerRadius = 20.0;
    final notchWidth = notchRadius * 2 + 24;

    final itemWidth = size.width / itemCount;
    final notchCenterX = itemWidth * notchIndex + itemWidth / 2;

    final notchStartX = notchCenterX - notchWidth / 2;
    final notchEndX = notchCenterX + notchWidth / 2;

    final path = Path();

    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    path.lineTo(notchStartX, 0);

    path.quadraticBezierTo(
      notchStartX + 12,
      0,
      notchStartX + 18,
      buttonTopOffset - 4,
    );

    path.arcToPoint(
      Offset(notchEndX - 18, buttonTopOffset - 4),
      radius: Radius.circular(notchRadius + 2),
      clockwise: false,
    );

    path.quadraticBezierTo(
      notchEndX - 12,
      0,
      notchEndX,
      0,
    );

    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant _NotchedNavBarClipper oldClipper) {
    return notchIndex != oldClipper.notchIndex ||
        itemCount != oldClipper.itemCount ||
        notchRadius != oldClipper.notchRadius ||
        buttonTopOffset != oldClipper.buttonTopOffset;
  }
}
