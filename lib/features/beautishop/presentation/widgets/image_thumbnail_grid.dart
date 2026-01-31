import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/widgets/units/app_cached_image.dart';

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

    final SliverGridDelegate gridDelegate = imageSize != null
        ? SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: imageSize!,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.0,
          )
        : SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.0,
          );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: gridDelegate,
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
      child: AppCachedImage(
        imageUrl: imageUrls[index],
        borderRadius: BorderRadius.circular(12),
        errorWidget: _buildPlaceholder(index),
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
