import 'package:flutter/material.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class ServiceMenuItem extends StatelessWidget {
  final ServiceMenu menu;
  final VoidCallback? onTap;

  const ServiceMenuItem({
    super.key,
    required this.menu,
    this.onTap,
  });

  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (menu.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      menu.description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: SemanticColors.text.secondary,
                      ),
                    ),
                  ],
                  if (menu.durationMinutes != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: SemanticColors.icon.disabled),
                        const SizedBox(width: 4),
                        Text(
                          menu.formattedDuration!,
                          style: TextStyle(
                            fontSize: 12,
                            color: SemanticColors.text.disabled,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (menu.hasDiscount) ...[
                  Text(
                    '${_formatNumber(menu.price)}원',
                    style: TextStyle(
                      fontSize: 13,
                      color: SemanticColors.icon.disabled,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatNumber(menu.discountPrice!)}원',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: SemanticColors.text.price,
                    ),
                  ),
                ] else
                  Text(
                    '${_formatNumber(menu.price)}원',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
