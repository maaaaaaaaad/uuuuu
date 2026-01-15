import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/presentation/pages/shop_detail_screen.dart';
import 'package:jellomark/features/search/presentation/providers/search_provider.dart';
import 'package:jellomark/shared/widgets/units/shop_card.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  static const Color _primaryColor = Color(0xFFFFB5BA);
  static const Color _textSecondary = Color(0xFF666666);
  static const Color _backgroundLight = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchNotifierProvider.notifier).loadSearchHistory();
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(searchNotifierProvider.notifier).search(query.trim());
    }
  }

  void _onCancel() {
    _searchController.clear();
    _searchFocusNode.unfocus();
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: state.query.isEmpty
          ? _buildHistoryView(state)
          : _buildResultsView(state),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: _backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: '이름 또는 위치로 샵을 검색 하세요',
                  hintStyle: TextStyle(fontSize: 14, color: _textSecondary),
                  prefixIcon: Icon(
                    Icons.search,
                    color: _textSecondary,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
                textInputAction: TextInputAction.search,
                onSubmitted: _onSearch,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _onCancel,
            child: const Text(
              '취소',
              style: TextStyle(fontSize: 14, color: _primaryColor),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '최근 검색어',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: _onClearHistory,
                child: Text(
                  '전체 삭제',
                  style: TextStyle(fontSize: 12, color: _textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.searchHistory.map((history) {
              return _buildHistoryChip(history.keyword);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryChip(String keyword) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _backgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _onHistoryTap(keyword),
            child: Text(keyword, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _onHistoryDelete(keyword),
            child: Icon(Icons.close, size: 16, color: _textSecondary),
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
                  Icon(
                    Icons.search,
                    size: 64,
                    color: _textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '검색어를 입력해주세요',
                    style: TextStyle(fontSize: 16, color: _textSecondary),
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
      return const Center(
        child: CircularProgressIndicator(color: _primaryColor),
      );
    }

    if (state.error != null) {
      return Center(
        child: Text(
          state.error!,
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
      );
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
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: _primaryColor),
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
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: _textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '검색 결과가 없습니다',
                    style: TextStyle(fontSize: 16, color: _textSecondary),
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
