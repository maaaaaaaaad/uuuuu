import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool showMore;
  final String moreText;
  final VoidCallback? onMoreTap;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.showMore = false,
    this.moreText = '더보기',
    this.onMoreTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: SemanticColors.text.primary,
            ),
          ),
          if (showMore)
            GestureDetector(
              onTap: onMoreTap,
              child: Text(
                moreText,
                style: TextStyle(fontSize: 14, color: SemanticColors.text.secondary),
              ),
            ),
        ],
      ),
    );
  }
}
