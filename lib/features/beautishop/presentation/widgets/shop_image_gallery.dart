import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class ShopImageGallery extends StatefulWidget {
  final List<String> images;
  final double height;
  final void Function(int index)? onImageTap;

  const ShopImageGallery({
    super.key,
    required this.images,
    this.height = 250,
    this.onImageTap,
  });

  @override
  State<ShopImageGallery> createState() => _ShopImageGalleryState();
}

class _ShopImageGalleryState extends State<ShopImageGallery> {
  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Container(
          color: SemanticColors.background.placeholder,
          child: Center(
            child: Icon(
              Icons.store,
              size: 64,
              color: SemanticColors.icon.disabled,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => widget.onImageTap?.call(index),
                child: CachedNetworkImage(
                  imageUrl: widget.images[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: SemanticColors.background.avatar,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: SemanticColors.indicator.loading,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: SemanticColors.background.avatar,
                    child: Center(
                      child: Icon(Icons.image, size: 48, color: SemanticColors.icon.disabled),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Container(
              key: const Key('page_indicator'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (index) => _buildIndicatorDot(index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorDot(int index) {
    final isActive = index == _currentPage;
    return Container(
      key: Key('indicator_dot_${index}_${isActive ? 'active' : 'inactive'}'),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? SemanticColors.indicator.loadingOnDark : SemanticColors.text.onDarkSecondary,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
