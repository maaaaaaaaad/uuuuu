import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/presentation/pages/shop_detail_screen.dart';
import 'package:jellomark/features/search/presentation/providers/search_provider.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/widgets/pill_chip.dart';
import 'package:jellomark/shared/widgets/units/glass_search_bar.dart';
import 'package:jellomark/shared/widgets/units/shop_card.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchNotifierProvider.notifier).loadSearchHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(searchNotifierProvider.notifier).search(query.trim());
    }
  }

  void _onClear() {
    _searchController.clear();
    ref.read(searchNotifierProvider.notifier).clearSearch();
  }

  void _onHistoryTap(String keyword) {
    _searchController.text = keyword;
    _onSearch(keyword);
  }

  void _onHistoryDelete(String keyword) {
    ref.read(searchNotifierProvider.notifier).deleteHistory(keyword);
  }

  void _onClearHistory() {
    ref.read(searchNotifierProvider.notifier).clearHistory();
  }

  void _onShopTap(BeautyShop shop) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ShopDetailScreen(shop: shop)),
    );
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchNotifierProvider);

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        backgroundColor: SemanticColors.special.transparent,
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.softWhiteGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildSearchHeader(),
                Expanded(
                  child: state.query.isEmpty
                      ? _buildHistoryView(state)
                      : _buildResultsView(state),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GlassSearchBar(
              controller: _searchController,
              hintText: '이름 또는 위치로 샵을 검색 하세요',
              onChanged: (_) {},
              onSubmitted: _onSearch,
              onClear: _onClear,
              autofocus: false,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _onClear,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: SemanticColors.background.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: SemanticColors.border.glass),
              ),
              child: Text(
                '취소',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: SemanticColors.button.textButton,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryView(SearchState state) {
    if (state.searchHistory.isEmpty) {
      return _buildEmptyHistory();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최근 검색어',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: SemanticColors.text.primary,
                ),
              ),
              GestureDetector(
                onTap: _onClearHistory,
                child: Text(
                  '전체 삭제',
                  style: TextStyle(
                    fontSize: 12,
                    color: SemanticColors.text.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.searchHistory.map((history) {
              return _HistoryPillChip(
                keyword: history.keyword,
                onTap: () => _onHistoryTap(history.keyword),
                onDelete: () => _onHistoryDelete(history.keyword),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
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
                      Icons.search,
                      size: 48,
                      color: SemanticColors.icon.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '검색어를 입력해주세요',
                    style: TextStyle(
                      fontSize: 16,
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

  Widget _buildResultsView(SearchState state) {
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

    if (state.results.isEmpty) {
      return _buildNoResults();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            ref.read(searchNotifierProvider.notifier).loadMore();
          }
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.results.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.results.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: SemanticColors.indicator.loading,
                ),
              ),
            );
          }

          final shop = state.results[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ShopCard(
              shop: shop,
              width: double.infinity,
              onTap: () => _onShopTap(shop),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoResults() {
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
                      Icons.search_off,
                      size: 48,
                      color: SemanticColors.icon.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '검색 결과가 없습니다',
                    style: TextStyle(
                      fontSize: 16,
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
                      final query = _searchController.text.trim();
                      if (query.isNotEmpty) {
                        ref.read(searchNotifierProvider.notifier).search(query);
                      }
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

class _HistoryPillChip extends StatelessWidget {
  final String keyword;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryPillChip({
    required this.keyword,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PillChip(label: keyword, icon: Icons.history, onTap: onTap);
  }
}
