import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/app_colors.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class WriteReviewPage extends StatefulWidget {
  final String shopName;
  final Future<bool> Function({int? rating, String? content}) onSubmit;

  const WriteReviewPage({
    super.key,
    required this.shopName,
    required this.onSubmit,
  });

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  int? _selectedRating;
  final _contentController = TextEditingController();
  bool _isSubmitting = false;

  static const int _minContentLength = 10;
  static const int _maxContentLength = 500;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_isSubmitting) return false;
    final content = _contentController.text.trim();
    final hasValidContent = content.length >= _minContentLength;
    return _selectedRating != null || hasValidContent;
  }

  int get _remainingCharacters {
    final content = _contentController.text.trim();
    if (content.isEmpty) return 0;
    return _minContentLength - content.length;
  }

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    try {
      final content = _contentController.text.trim();
      final validContent =
          content.length >= _minContentLength ? content : null;
      final success = await widget.onSubmit(
        rating: _selectedRating,
        content: validContent,
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
        } else {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('리뷰 작성에 실패했습니다. 다시 시도해주세요.'),
              backgroundColor: SemanticColors.state.error,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('리뷰 작성 중 오류가 발생했습니다.'),
            backgroundColor: SemanticColors.state.error,
          ),
        );
      }
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        backgroundColor: AppColors.backgroundMedium,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(widget.shopName),
          centerTitle: true,
          elevation: 0,
          backgroundColor: SemanticColors.special.transparent,
          foregroundColor: SemanticColors.text.primary,
        ),
        body: SizedBox.expand(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: AppGradients.softWhiteGradient,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRatingSection(),
                    const SizedBox(height: 32),
                    _buildContentSection(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
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
                style: TextStyle(
                  fontSize: 14,
                  color: SemanticColors.text.disabled,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    isSelected
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 48,
                    color: isSelected
                        ? SemanticColors.icon.starSelectable
                        : SemanticColors.icon.starSelectableEmpty,
                  ),
                ),
              );
            }),
          ),
          if (_selectedRating != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: Text(
                  _getRatingText(_selectedRating!),
                  style: TextStyle(
                    fontSize: 15,
                    color: SemanticColors.text.linkPink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
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
                style: TextStyle(
                  fontSize: 14,
                  color: SemanticColors.text.disabled,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            maxLines: 5,
            maxLength: _maxContentLength,
            decoration: InputDecoration(
              hintText: '이용 경험을 자유롭게 작성해주세요 (최소 $_minContentLength자)',
              hintStyle: TextStyle(color: SemanticColors.text.hint),
              filled: true,
              fillColor: SemanticColors.background.inputTranslucent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: SemanticColors.border.input),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: SemanticColors.border.input),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: SemanticColors.border.focus),
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
                style: TextStyle(
                  fontSize: 12,
                  color: SemanticColors.text.disabled,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _canSubmit ? _handleSubmit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: SemanticColors.button.primary,
          foregroundColor: SemanticColors.button.primaryText,
          disabledBackgroundColor: SemanticColors.button.disabled,
          disabledForegroundColor: SemanticColors.button.disabledText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: SemanticColors.indicator.loadingOnDark,
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
