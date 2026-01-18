import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class ImageThumbnailGrid extends StatelessWidget {
  final List<String> imageUrls;
  final void Function(int index)? onImageTap;
  final int crossAxisCount;
  final double? imageSize;

  const ImageThumbnailGrid({
    super.key,
    required this.imageUrls,
    this.onImageTap,
    this.crossAxisCount = 2,
    this.imageSize,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: imageSize != null
          ? SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              mainAxisExtent: imageSize,
            )
          : SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1.0,
            ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) => _buildThumbnail(index),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      key: const Key('empty_state'),
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: SemanticColors.icon.disabled,
            ),
            const SizedBox(height: 8),
            Text(
              '이미지가 없습니다',
              style: TextStyle(
                color: SemanticColors.text.hint,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(int index) {
    return GestureDetector(
      key: Key('thumbnail_$index'),
      onTap: () => onImageTap?.call(index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: SemanticColors.background.placeholder,
          child: Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(index),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildPlaceholder(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(int index) {
    return Center(
      key: Key('placeholder_icon_$index'),
      child: Icon(
        Icons.image_outlined,
        size: 32,
        color: SemanticColors.icon.disabled,
      ),
    );
  }
}
