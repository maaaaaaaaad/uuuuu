import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/presentation/pages/shop_detail_screen.dart';
import 'package:jellomark/features/home/presentation/providers/home_provider.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/widgets/units/shop_card.dart';

class RecommendedShopsState {
  final List<BeautyShop> shops;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;

  const RecommendedShopsState({
    this.shops = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 0,
    this.error,
  });

  RecommendedShopsState copyWith({
    List<BeautyShop>? shops,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return RecommendedShopsState(
      shops: shops ?? this.shops,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}

class RecommendedShopsNotifier extends StateNotifier<RecommendedShopsState> {
  final Ref _ref;

  RecommendedShopsNotifier(this._ref) : super(const RecommendedShopsState());

  Future<void> loadInitial() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    const filter = BeautyShopFilter(
      sortBy: 'RATING',
      sortOrder: 'DESC',
      size: 20,
      page: 0,
    );

    final useCase = _ref.read(getFilteredShopsUseCaseProvider);
    final result = await useCase(filter);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (pagedShops) {
        state = state.copyWith(
          shops: pagedShops.items,
          hasMore: pagedShops.hasNext,
          page: 0,
          isLoading: false,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.page + 1;
    final filter = BeautyShopFilter(
      sortBy: 'RATING',
      sortOrder: 'DESC',
      size: 20,
      page: nextPage,
    );

    final useCase = _ref.read(getFilteredShopsUseCaseProvider);
    final result = await useCase(filter);

    result.fold(
      (failure) {
        state = state.copyWith(isLoadingMore: false, error: failure.message);
      },
      (pagedShops) {
        state = state.copyWith(
          shops: [...state.shops, ...pagedShops.items],
          hasMore: pagedShops.hasNext,
          page: nextPage,
          isLoadingMore: false,
        );
      },
    );
  }
}

final recommendedShopsNotifierProvider =
    StateNotifierProvider.autoDispose<RecommendedShopsNotifier, RecommendedShopsState>(
  (ref) => RecommendedShopsNotifier(ref),
);

class RecommendedShopsPage extends ConsumerStatefulWidget {
  const RecommendedShopsPage({super.key});

  @override
  ConsumerState<RecommendedShopsPage> createState() =>
      _RecommendedShopsPageState();
}

class _RecommendedShopsPageState extends ConsumerState<RecommendedShopsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recommendedShopsNotifierProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 300) {
      ref.read(recommendedShopsNotifierProvider.notifier).loadMore();
    }
  }

  void _navigateToShopDetail(BeautyShop shop) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShopDetailScreen(shop: shop),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recommendedShopsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('추천 샵'),
        backgroundColor: SemanticColors.background.input,
        foregroundColor: SemanticColors.text.primary,
        elevation: 0,
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(RecommendedShopsState state) {
    if (state.isLoading && state.shops.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: SemanticColors.indicator.loadingPink),
      );
    }

    if (state.error != null && state.shops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(recommendedShopsNotifierProvider.notifier).loadInitial();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.shops.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.shops.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(color: SemanticColors.indicator.loadingPink),
            ),
          );
        }

        final shop = state.shops[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShopCard(
            shop: shop,
            width: double.infinity,
            onTap: () => _navigateToShopDetail(shop),
          ),
        );
      },
    );
  }
}
