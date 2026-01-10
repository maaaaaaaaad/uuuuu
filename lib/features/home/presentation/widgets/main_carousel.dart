import 'package:flutter/material.dart';

class CarouselItem {
  final String id;
  final String imageUrl;
  final String title;

  const CarouselItem({
    required this.id,
    required this.imageUrl,
    required this.title,
  });
}

class MainCarousel extends StatefulWidget {
  final List<CarouselItem> items;

  const MainCarousel({super.key, required this.items});

  @override
  State<MainCarousel> createState() => _MainCarouselState();
}

class _MainCarouselState extends State<MainCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[200],
                ),
                child: Center(child: Text(item.title)),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        PageIndicator(
          itemCount: widget.items.length,
          currentIndex: _currentIndex,
        ),
      ],
    );
  }
}

class PageIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;

  const PageIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentIndex ? Colors.pink[200] : Colors.grey[300],
          ),
        ),
      ),
    );
  }
}
