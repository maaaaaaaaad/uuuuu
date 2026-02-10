import 'package:flutter/material.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class CurrentReservationBar extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onTap;

  const CurrentReservationBar({
    super.key,
    required this.reservation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: SemanticColors.icon.accent,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                    '${reservation.startTime} - ${reservation.endTime}  ${reservation.shopName ?? ''}',
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
}
