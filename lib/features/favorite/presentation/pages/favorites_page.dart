import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/presentation/pages/shop_detail_screen.dart';
import 'package:jellomark/features/favorite/presentation/providers/favorites_provider.dart';
import 'package:jellomark/shared/theme/app_colors.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/widgets/units/shop_card.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesNotifierProvider.notifier).loadFavorites();
    });
  }

  void _onShopTap(BeautyShop shop) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ShopDetailScreen(shop: shop)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoritesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundMedium,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.softWhiteGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildContent(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            '즐겨찾기',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: SemanticColors.text.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(FavoritesState state) {
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
      onRefresh: () => ref.read(favoritesNotifierProvider.notifier).loadFavorites(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            final metrics = notification.metrics;
            if (metrics.pixels >= metrics.maxScrollExtent - 200) {
              ref.read(favoritesNotifierProvider.notifier).loadMore();
            }
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.items.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    color: SemanticColors.indicator.loading,
                  ),
                ),
              );
            }

            final favorite = state.items[index];
            final shop = favorite.shop;
            if (shop == null) {
              return const SizedBox.shrink();
            }

            return Dismissible(
              key: ValueKey(favorite.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: SemanticColors.state.error,
                child: Icon(
                  Icons.delete,
                  color: SemanticColors.text.onDark,
                ),
              ),
              onDismissed: (_) {
                ref
                    .read(favoritesNotifierProvider.notifier)
                    .removeFavorite(favorite.shopId);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ShopCard(
                  shop: shop,
                  width: double.infinity,
                  onTap: () => _onShopTap(shop),
                ),
              ),
            );
          },
        ),
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
                      Icons.favorite_border,
                      size: 48,
                      color: SemanticColors.icon.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '즐겨찾기한 샵이 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: SemanticColors.text.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '마음에 드는 샵을 즐겨찾기에 추가해보세요',
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
                          .read(favoritesNotifierProvider.notifier)
                          .loadFavorites();
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
