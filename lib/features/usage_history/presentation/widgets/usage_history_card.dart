import 'package:flutter/material.dart';
import 'package:jellomark/features/usage_history/domain/entities/usage_history.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class UsageHistoryCard extends StatelessWidget {
  final UsageHistory history;
  final VoidCallback onRebook;

  const UsageHistoryCard({
    super.key,
    required this.history,
    required this.onRebook,
  });

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
              Expanded(
                child: Text(
                  history.shopName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: SemanticColors.text.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatDate(history.completedAt),
                style: TextStyle(
                  fontSize: 12,
                  color: SemanticColors.text.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            history.treatmentName,
            style: TextStyle(
              fontSize: 14,
              color: SemanticColors.text.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatPrice(history.treatmentPrice)}원 | ${history.treatmentDuration}분',
            style: TextStyle(
              fontSize: 13,
              color: SemanticColors.text.secondary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onRebook,
              style: OutlinedButton.styleFrom(
                foregroundColor: SemanticColors.button.textButtonPink,
                side: BorderSide(color: SemanticColors.button.textButtonPink),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text(
                '또 예약하기',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
