import 'package:flutter/material.dart';

class WriteReviewBottomSheet extends StatefulWidget {
  final String shopName;
  final Future<bool> Function({int? rating, String? content}) onSubmit;

  const WriteReviewBottomSheet({
    super.key,
    required this.shopName,
    required this.onSubmit,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String shopName,
    required Future<bool> Function({int? rating, String? content}) onSubmit,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          WriteReviewBottomSheet(shopName: shopName, onSubmit: onSubmit),
    );
  }

  @override
  State<WriteReviewBottomSheet> createState() => _WriteReviewBottomSheetState();
}

class _WriteReviewBottomSheetState extends State<WriteReviewBottomSheet> {
  int? _selectedRating;
  final _contentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  static const int _minContentLength = 10;
  static const int _maxContentLength = 500;

  bool get _canSubmit {
    if (_isSubmitting) return false;
    final content = _contentController.text.trim();
    if (content.isNotEmpty) {
      return content.length >= _minContentLength;
    }
    return _selectedRating != null;
  }

  int get _remainingCharacters {
    final content = _contentController.text.trim();
    if (content.isEmpty) return 0;
    return _minContentLength - content.length;
  }

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    final content = _contentController.text.trim();
    final success = await widget.onSubmit(
      rating: _selectedRating,
      content: content.isNotEmpty ? content : null,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('리뷰 작성에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHandle(),
            _buildHeader(),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRatingSection(),
                  const SizedBox(height: 24),
                  _buildContentSection(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '리뷰 작성',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.shopName,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '평점',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text(
              '(선택)',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(5, (index) {
            final rating = index + 1;
            final isSelected =
                _selectedRating != null && rating <= _selectedRating!;
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (_selectedRating == rating) {
                    _selectedRating = null;
                  } else {
                    _selectedRating = rating;
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 40,
                  color: isSelected
                      ? const Color(0xFFFFB5BA)
                      : Colors.grey[300],
                ),
              ),
            );
          }),
        ),
        if (_selectedRating != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _getRatingText(_selectedRating!),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFFFB5BA),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return '별로예요';
      case 2:
        return '그냥 그래요';
      case 3:
        return '보통이에요';
      case 4:
        return '좋아요';
      case 5:
        return '최고예요!';
      default:
        return '';
    }
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '리뷰 내용',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text(
              '(선택)',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _contentController,
          maxLines: 4,
          maxLength: _maxContentLength,
          decoration: InputDecoration(
            hintText: '이용 경험을 자유롭게 작성해주세요 (최소 $_minContentLength자)',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFFB5BA)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (_remainingCharacters > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '$_remainingCharacters자 더 입력해주세요',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _canSubmit ? _handleSubmit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFB5BA),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[200],
          disabledForegroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                '작성 완료',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
