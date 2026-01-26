import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/widgets/gradient_card.dart';

class HeroCarousel extends StatefulWidget {
  final Duration autoSlideDuration;
  final bool enableAutoSlide;

  const HeroCarousel({
    super.key,
    this.autoSlideDuration = const Duration(seconds: 4),
    this.enableAutoSlide = true,
  });

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  static const int _pageCount = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.enableAutoSlide) {
      _startAutoSlide();
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(widget.autoSlideDuration, (_) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _pageCount;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _resetAutoSlide() {
    _autoSlideTimer?.cancel();
    if (widget.enableAutoSlide) {
      _startAutoSlide();
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              _buildWelcomeCard(),
              _buildAppIntroCard(),
              _buildFeatureCard(),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GradientCard(
        gradientType: GradientType.mint,
        padding: const EdgeInsets.all(20),
        onTap: _resetAutoSlide,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '환영합니다! 👋',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: SemanticColors.text.onDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '오늘도 예뻐지는 하루 되세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: SemanticColors.text.onDarkSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.spa, size: 48, color: SemanticColors.icon.onDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIntroCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GradientCard(
        gradientType: GradientType.pink,
        padding: const EdgeInsets.all(20),
        onTap: _resetAutoSlide,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '젤로마크',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: SemanticColors.text.onDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '내 주변 뷰티샵을 한눈에 찾아보세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: SemanticColors.text.onDarkSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.storefront, size: 48, color: SemanticColors.icon.onDark),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GradientCard(
        gradientType: GradientType.lavender,
        padding: const EdgeInsets.all(20),
        onTap: _resetAutoSlide,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '편리한 기능',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: SemanticColors.text.onDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '리뷰 확인 · 즐겨찾기 · 위치 기반 검색',
                    style: TextStyle(
                      fontSize: 14,
                      color: SemanticColors.text.onDarkSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.star, size: 48, color: SemanticColors.icon.onDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      key: const Key('hero_carousel_indicator'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pageCount, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? SemanticColors.indicator.carouselActive
                : SemanticColors.indicator.carouselInactive,
          ),
        );
      }),
    );
  }
}
