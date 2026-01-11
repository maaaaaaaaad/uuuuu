import 'dart:ui';

import 'package:flutter/material.dart';

class GlassSearchBar extends StatelessWidget {
  final String hintText;
  final String? locationText;
  final VoidCallback? onTap;

  const GlassSearchBar({
    super.key,
    this.hintText = '검색',
    this.locationText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hintText,
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ),
                if (locationText != null) ...[
                  Icon(Icons.location_on, color: Colors.grey[600], size: 18),
                  const SizedBox(width: 4),
                  Text(
                    locationText!,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
