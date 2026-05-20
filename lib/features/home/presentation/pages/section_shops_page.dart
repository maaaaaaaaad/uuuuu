import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/presentation/pages/shop_detail_screen.dart';
import 'package:jellomark/features/home/domain/entities/home_section.dart';
import 'package:jellomark/features/home/presentation/providers/section_shops_provider.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/widgets/units/shop_card.dart';

class SectionShopsPage extends ConsumerStatefulWidget {
  final HomeSection section;

  const SectionShopsPage({super.key, required this.section});

  @override
  ConsumerState<SectionShopsPage> createState() => _SectionShopsPageState();
}

class _SectionShopsPageState extends ConsumerState<SectionShopsPage> {
  final ScrollController _scrollController = ScrollController();

  HomeSection get _section => widget.section;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sectionShopsNotifierProvider(_section).notifier).loadInitial();
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
      ref.read(sectionShopsNotifierProvider(_section).notifier).loadMore();
    }
  }

  void _onSortChanged(ShopSortOption sort) {
    ref.read(sectionShopsNotifierProvider(_section).notifier).changeSort(sort);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _navigateToShopDetail(BeautyShop shop) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ShopDetailScreen(shop: shop)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sectionShopsNotifierProvider(_section));

    return Scaffold(
      appBar: AppBar(
        title: Text(_section.title),
        backgroundColor: SemanticColors.background.input,
        foregroundColor: SemanticColors.text.primary,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _SortChipBar(selected: state.sort, onChanged: _onSortChanged),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(SectionShopsState state) {
    if (state.isLoading && state.shops.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: SemanticColors.indicator.loadingPink,
        ),
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
              onPressed: () => ref
                  .read(sectionShopsNotifierProvider(_section).notifier)
                  .loadInitial(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.shops.isEmpty) {
      return const Center(child: Text('표시할 샵이 없습니다'));
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
              child: CircularProgressIndicator(
                color: SemanticColors.indicator.loadingPink,
              ),
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

class _SortChipBar extends StatelessWidget {
  final ShopSortOption selected;
  final ValueChanged<ShopSortOption> onChanged;

  const _SortChipBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: ShopSortOption.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = ShopSortOption.values[index];
          return _SortChip(
            label: option.label,
            isSelected: option == selected,
            onTap: () => onChanged(option),
          );
        },
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? SemanticColors.button.primary
              : SemanticColors.background.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? SemanticColors.button.primary
                : SemanticColors.border.glass,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? SemanticColors.text.onDark
                : SemanticColors.text.primary,
          ),
        ),
      ),
    );
  }
}
