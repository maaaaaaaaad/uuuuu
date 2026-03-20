import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/presentation/pages/reservation_detail_page.dart';
import 'package:jellomark/features/reservation/presentation/providers/current_reservation_provider.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class UpcomingReservationBanner extends ConsumerWidget {
  const UpcomingReservationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(currentReservationNotifierProvider);
    final reservation = state.todayReservation ?? state.upcomingReservation;

    if (reservation == null) return const SizedBox.shrink();

    final isToday = state.todayReservation != null;

    return GestureDetector(
      onTap: () => _navigateToDetail(context, reservation),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SemanticColors.background.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: SemanticColors.border.glass),
          boxShadow: [
            BoxShadow(
              color: SemanticColors.icon.accent.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SemanticColors.background.cardPink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isToday ? Icons.access_time : Icons.event_available,
                size: 20,
                color: SemanticColors.icon.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? '오늘 예약' : '다가오는 예약',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: SemanticColors.icon.accent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reservation.treatmentName ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: SemanticColors.text.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatDate(reservation.reservationDate)} ${reservation.startTime}  ${reservation.shopName ?? ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: SemanticColors.text.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: SemanticColors.icon.secondary,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Reservation reservation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReservationDetailPage(reservationId: reservation.id),
      ),
    );
  }

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
}
