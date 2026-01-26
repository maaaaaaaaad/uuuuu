import 'package:flutter/material.dart';
import 'package:jellomark/features/category/domain/entities/category.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class ShopFilterBottomSheet extends StatefulWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final double? minRating;
  final String sortBy;
  final void Function(String?) onCategoryChanged;
  final void Function(double?) onRatingChanged;
  final void Function(String) onSortChanged;
  final VoidCallback onApply;
  final VoidCallback onReset;

  const ShopFilterBottomSheet({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.minRating,
    required this.sortBy,
    required this.onCategoryChanged,
    required this.onRatingChanged,
    required this.onSortChanged,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<ShopFilterBottomSheet> createState() => _ShopFilterBottomSheetState();
}

class _ShopFilterBottomSheetState extends State<ShopFilterBottomSheet> {
  late String? _selectedCategoryId;
  late double? _minRating;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
    _minRating = widget.minRating;
    _sortBy = widget.sortBy;
  }

  void _onCategoryTap(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    widget.onCategoryChanged(categoryId);
  }

  void _onRatingTap(double? rating) {
    setState(() {
      _minRating = rating;
    });
    widget.onRatingChanged(rating);
  }

  void _onSortTap(String sort) {
    setState(() {
      _sortBy = sort;
    });
    widget.onSortChanged(sort);
  }

  void _onReset() {
    setState(() {
      _selectedCategoryId = null;
      _minRating = null;
      _sortBy = 'RATING';
    });
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SemanticColors.background.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHandle(),
          const SizedBox(height: 16),
          _buildCategorySection(),
          const SizedBox(height: 20),
          _buildRatingSection(),
          const SizedBox(height: 20),
          _buildSortSection(),
          const SizedBox(height: 24),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: SemanticColors.border.glass,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('카테고리'),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                key: const Key('category_chip_all'),
                label: '전체',
                isSelected: _selectedCategoryId == null,
                onTap: () => _onCategoryTap(null),
              ),
              const SizedBox(width: 8),
              ...widget.categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  key: Key('category_chip_${category.id}'),
                  label: category.name,
                  isSelected: _selectedCategoryId == category.id,
                  onTap: () => _onCategoryTap(category.id),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('최소 평점'),
        const SizedBox(height: 12),
        Row(
          children: [
            _FilterChip(
              key: const Key('rating_chip_all'),
              label: '전체',
              isSelected: _minRating == null,
              onTap: () => _onRatingTap(null),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              key: const Key('rating_chip_4'),
              label: '4.0+',
              isSelected: _minRating == 4.0,
              onTap: () => _onRatingTap(4.0),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              key: const Key('rating_chip_3'),
              label: '3.0+',
              isSelected: _minRating == 3.0,
              onTap: () => _onRatingTap(3.0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('정렬'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChip(
              key: const Key('sort_chip_RATING'),
              label: '평점순',
              isSelected: _sortBy == 'RATING',
              onTap: () => _onSortTap('RATING'),
            ),
            _FilterChip(
              key: const Key('sort_chip_DISTANCE'),
              label: '거리순',
              isSelected: _sortBy == 'DISTANCE',
              onTap: () => _onSortTap('DISTANCE'),
            ),
            _FilterChip(
              key: const Key('sort_chip_REVIEW_COUNT'),
              label: '리뷰 많은순',
              isSelected: _sortBy == 'REVIEW_COUNT',
              onTap: () => _onSortTap('REVIEW_COUNT'),
            ),
            _FilterChip(
              key: const Key('sort_chip_CREATED_AT'),
              label: '최신순',
              isSelected: _sortBy == 'CREATED_AT',
              onTap: () => _onSortTap('CREATED_AT'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: SemanticColors.text.primary,
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _onReset,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: SemanticColors.border.glass),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '초기화',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: SemanticColors.text.secondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: widget.onApply,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: SemanticColors.button.primary,
              foregroundColor: SemanticColors.text.onDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '적용',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    super.key,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
