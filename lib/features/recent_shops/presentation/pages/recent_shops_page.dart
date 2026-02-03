import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/presentation/pages/shop_detail_screen.dart';
import 'package:jellomark/features/recent_shops/domain/entities/recent_shop.dart';
import 'package:jellomark/features/recent_shops/presentation/providers/recent_shops_provider.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/widgets/glass_card.dart';
import 'package:jellomark/shared/widgets/units/app_cached_image.dart';

class RecentShopsPage extends ConsumerStatefulWidget {
  const RecentShopsPage({super.key});

  @override
  ConsumerState<RecentShopsPage> createState() => _RecentShopsPageState();
}

class _RecentShopsPageState extends ConsumerState<RecentShopsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recentShopsNotifierProvider.notifier).loadRecentShops();
    });
  }

  void _onShopTap(RecentShop recentShop) {
    final shop = BeautyShop(
      id: recentShop.shopId,
      name: recentShop.shopName,
      address: recentShop.address ?? '',
      images: recentShop.thumbnailUrl != null ? [recentShop.thumbnailUrl!] : [],
      rating: recentShop.rating ?? 0.0,
      latitude: recentShop.latitude,
      longitude: recentShop.longitude,
      distance: recentShop.distance,
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ShopDetailScreen(shop: shop)),
    );
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SemanticColors.background.card,
        title: Text(
          '최근 본 샵 삭제',
          style: TextStyle(color: SemanticColors.text.primary),
        ),
        content: Text(
          '최근 본 샵 기록을 모두 삭제하시겠습니까?',
          style: TextStyle(color: SemanticColors.text.secondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '취소',
              style: TextStyle(color: SemanticColors.button.textButton),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(recentShopsNotifierProvider.notifier).clearRecentShops();
            },
            child: Text(
              '삭제',
              style: TextStyle(color: SemanticColors.state.error),
            ),
          ),
        ],
      ),
    );
  }

  String _formatViewedAt(DateTime viewedAt) {
    final now = DateTime.now();
    final diff = now.difference(viewedAt);

    if (diff.inMinutes < 1) {
      return '방금 전';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${viewedAt.month}/${viewedAt.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recentShopsNotifierProvider);

    return Scaffold(
      backgroundColor: SemanticColors.special.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.softWhiteGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(state),
              Expanded(child: _buildContent(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(RecentShopsState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.arrow_back_ios,
              color: SemanticColors.icon.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '최근 본 샵',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: SemanticColors.text.primary,
            ),
          ),
          const Spacer(),
          if (state.items.isNotEmpty)
            TextButton(
              onPressed: _showClearConfirmDialog,
              child: Text(
                '전체 삭제',
                style: TextStyle(
                  color: SemanticColors.state.error,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(RecentShopsState state) {
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: SemanticColors.indicator.loading,
        ),
      );
    }

    if (state.error != null) {
      return _buildErrorState(state.error!);
    }

    if (state.items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(recentShopsNotifierProvider.notifier).loadRecentShops(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: state.items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final shop = state.items[index];
          return _buildShopItem(shop);
        },
      ),
    );
  }

  Widget _buildShopItem(RecentShop shop) {
    return GlassCard(
      onTap: () => _onShopTap(shop),
      padding: EdgeInsets.zero,
      borderRadius: 16,
      backgroundColor: SemanticColors.background.cardAccent,
      child: Row(
        children: [
          AppCachedImage(
            imageUrl: shop.thumbnailUrl,
            width: 100,
            height: 100,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            errorWidget: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                color: SemanticColors.background.imagePlaceholder,
              ),
              child: Center(
                child: Icon(
                  Icons.storefront,
                  size: 32,
                  color: SemanticColors.icon.disabled,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.shopName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: SemanticColors.text.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (shop.address != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      shop.address!,
                      style: TextStyle(
                        fontSize: 12,
                        color: SemanticColors.text.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (shop.rating != null) ...[
                        Icon(
                          Icons.star,
                          size: 14,
                          color: SemanticColors.icon.starSelectable,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          shop.rating!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: SemanticColors.text.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (shop.formattedDistance != null) ...[
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: SemanticColors.icon.disabled,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          shop.formattedDistance!,
                          style: TextStyle(
                            fontSize: 12,
                            color: SemanticColors.text.hint,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: SemanticColors.icon.disabled,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _formatViewedAt(shop.viewedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: SemanticColors.text.hint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.chevron_right,
              color: SemanticColors.icon.disabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: SemanticColors.background.card,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history,
                      size: 48,
                      color: SemanticColors.icon.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '최근 본 샵이 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: SemanticColors.text.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '샵을 둘러보면 여기에 기록됩니다',
                    style: TextStyle(
                      fontSize: 14,
                      color: SemanticColors.text.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: SemanticColors.background.card,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 48,
                      color: SemanticColors.icon.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error,
                    style: TextStyle(
                      fontSize: 16,
                      color: SemanticColors.text.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      ref
                          .read(recentShopsNotifierProvider.notifier)
                          .loadRecentShops();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: SemanticColors.button.textButton,
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
