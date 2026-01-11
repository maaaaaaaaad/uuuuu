import 'package:flutter/material.dart';
import 'package:jellomark/shared/widgets/units/glass_search_bar.dart';

class SearchSection extends StatelessWidget {
  final String? locationText;
  final VoidCallback? onSearchTap;

  const SearchSection({
    super.key,
    this.locationText,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassSearchBar(
        hintText: '뷰티샵 검색',
        locationText: locationText,
        onTap: onSearchTap,
      ),
    );
  }
}
