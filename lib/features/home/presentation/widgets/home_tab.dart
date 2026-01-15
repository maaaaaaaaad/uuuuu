import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/presentation/pages/shop_detail_screen.dart';
import 'package:jellomark/features/home/presentation/pages/recommended_shops_page.dart';
import 'package:jellomark/features/home/presentation/providers/home_provider.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/utils/category_icon_mapper.dart';
import 'package:jellomark/shared/widgets/gradient_card.dart';
import 'package:jellomark/shared/widgets/sections/category_section.dart';
import 'package:jellomark/shared/widgets/sections/search_section.dart';
import 'package:jellomark/shared/widgets/sections/shop_section.dart';
import 'package:jellomark/shared/widgets/units/shop_card.dart';

class HomeTab extends ConsumerStatefulWidget {
  final VoidCallback? onSearchTap;

  const HomeTab({super.key, this.onSearchTap});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingSearchIcon = false;
  static const double _scrollThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeNotifierProvider.notifier).loadData();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > _scrollThreshold;
    if (shouldShow != _showFloatingSearchIcon) {
      setState(() {
        _showFloatingSearchIcon = shouldShow;
      });
    }
  }

  void _navigateToShopDetail(String shopId, List<BeautyShop> shops) {
    final shop = shops.firstWhere((s) => s.id == shopId);

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ShopDetailScreen(shop: shop)));
  }

  void _navigateToRecommendedShops() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RecommendedShopsPage()));
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);

    if (homeState.isLoading && homeState.recommendedShops.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: SemanticColors.indicator.loading,
        ),
      );
    }

    final categories = homeState.categories
        .map(
          (c) => CategoryData(
            id: c.id,
            label: c.name,
            icon: CategoryIconMapper.getIcon(c.name),
          ),
        )
        .toList();

    return SafeArea(
      child: Stack(
        children: [
          RefreshIndicator(
            color: SemanticColors.indicator.loading,
            onRefresh: () => ref.read(homeNotifierProvider.notifier).refresh(),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                _onScrollNotification(notification);
                return false;
              },
              child: SingleChildScrollView(
                key: const Key('home_tab_scroll_view'),
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    SearchSection(
                      locationText: '현재 위치',
                      onSearchTap: widget.onSearchTap,
                    ),
                    const SizedBox(height: 20),
                    _buildHeroSection(),
                    const SizedBox(height: 20),
                    if (categories.isNotEmpty)
                      CategorySection(categories: categories),
                    const SizedBox(height: 24),
                    if (homeState.nearbyShops.isNotEmpty)
                      HorizontalShopSection(
                        title: '내 주변 인기 샵',
                        shops: homeState.nearbyShops,
                        showMore: true,
                        onShopTap: (id) =>
                            _navigateToShopDetail(id, homeState.nearbyShops),
                      ),
                    if (homeState.nearbyShops.isNotEmpty)
                      const SizedBox(height: 24),
                    VerticalShopSection(
                      title: '추천 샵',
                      shops: homeState.displayedRecommendedShops,
                      showMore: homeState.hasMoreRecommended,
                      onMoreTap: () => _navigateToRecommendedShops(),
                      onShopTap: (id) =>
                          _navigateToShopDetail(id, homeState.recommendedShops),
                    ),
                    const SizedBox(height: 24),
                    _NewShopsSection(
                      shops: homeState.newShops,
                      isLoadingMore: homeState.isLoadingMoreNewShops,
                      onShopTap: (id) =>
                          _navigateToShopDetail(id, homeState.newShops),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          if (_showFloatingSearchIcon)
            Positioned(
              top: 8,
              right: 16,
              child: _FloatingSearchButton(
                key: const Key('floating_search_icon'),
                onTap: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GradientCard(
        gradientType: GradientType.mint,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

  void _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification ||
        notification is ScrollEndNotification) {
      final metrics = notification.metrics;
      if (metrics.extentAfter < 300) {
        final homeState = ref.read(homeNotifierProvider);
        if (homeState.hasMoreNewShops && !homeState.isLoadingMoreNewShops) {
          ref.read(homeNotifierProvider.notifier).loadMoreNewShops();
        }
      }
    }
  }
}

class _NewShopsSection extends StatelessWidget {
  final List<BeautyShop> shops;
  final bool isLoadingMore;
  final void Function(String id)? onShopTap;

  const _NewShopsSection({
    required this.shops,
    required this.isLoadingMore,
    this.onShopTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '새로 입점한 샵',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: shops.length,
          itemBuilder: (context, index) {
            final shop = shops[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ShopCard(
                shop: shop,
                width: double.infinity,
                onTap: () => onShopTap?.call(shop.id),
              ),
            );
          },
        ),
        if (isLoadingMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                key: const Key('new_shops_loading_indicator'),
                color: SemanticColors.indicator.loading,
              ),
            ),
          ),
      ],
    );
  }
}

class _FloatingSearchButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _FloatingSearchButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: SemanticColors.background.card,
              shape: BoxShape.circle,
              border: Border.all(color: SemanticColors.border.glass, width: 1),
              boxShadow: [
                BoxShadow(
                  color: SemanticColors.icon.accent.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.search,
              color: SemanticColors.icon.accent,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
