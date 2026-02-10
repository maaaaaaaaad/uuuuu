import 'package:flutter/material.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class ConfirmedReservationToast extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const ConfirmedReservationToast({
    super.key,
    required this.reservation,
    required this.onTap,
    required this.onDismiss,
  });

  String _formatDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return dateStr;

    final date = DateTime(year, month, day);
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];

    return '$month/$day($weekday)';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA5D6A7)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_available,
              size: 18,
              color: Color(0xFF2E7D32),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${_formatDate(reservation.reservationDate)} ${reservation.startTime} ${reservation.treatmentName ?? ''} 예약이 확정되었습니다',
                style: TextStyle(
                  fontSize: 13,
                  color: SemanticColors.text.primary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: Icon(
                Icons.close,
                size: 18,
                color: SemanticColors.icon.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
