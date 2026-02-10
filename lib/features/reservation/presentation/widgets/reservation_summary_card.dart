import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class ReservationSummaryCard extends StatelessWidget {
  final String treatmentName;
  final int treatmentPrice;
  final int? durationMinutes;
  final String date;
  final String time;

  const ReservationSummaryCard({
    super.key,
    required this.treatmentName,
    required this.treatmentPrice,
    this.durationMinutes,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SemanticColors.border.glass),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '예약 정보',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: SemanticColors.text.primary,
            ),
          ),
          const SizedBox(height: 12),
          _buildRow(Icons.content_cut, '시술', treatmentName),
          const SizedBox(height: 8),
          _buildRow(Icons.monetization_on_outlined, '가격',
              '${_formatPrice(treatmentPrice)}원'),
          if (durationMinutes != null) ...[
            const SizedBox(height: 8),
            _buildRow(
                Icons.timer_outlined, '소요시간', _formatDuration(durationMinutes!)),
          ],
          const SizedBox(height: 8),
          _buildRow(Icons.calendar_today_outlined, '날짜', _formatDisplayDate(date)),
          const SizedBox(height: 8),
          _buildRow(Icons.access_time, '시간', time),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: SemanticColors.icon.secondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: SemanticColors.text.secondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: SemanticColors.text.primary,
          ),
        ),
      ],
    );
  }

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

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '$mins분';
    if (mins == 0) return '$hours시간';
    return '$hours시간 $mins분';
  }

  String _formatDisplayDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;
    return '${parts[0]}년 ${int.parse(parts[1])}월 ${int.parse(parts[2])}일';
  }
}
