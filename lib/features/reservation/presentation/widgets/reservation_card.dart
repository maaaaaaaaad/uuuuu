import 'package:flutter/material.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/presentation/widgets/reservation_status_badge.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onTap;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        reservation.treatmentName ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: SemanticColors.text.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ReservationStatusBadge(status: reservation.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.storefront,
                      size: 14,
                      color: SemanticColors.icon.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      reservation.shopName ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: SemanticColors.text.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: SemanticColors.icon.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      reservation.reservationDate,
                      style: TextStyle(
                        fontSize: 13,
                        color: SemanticColors.text.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: SemanticColors.icon.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${reservation.startTime} - ${reservation.endTime}',
                      style: TextStyle(
                        fontSize: 13,
                        color: SemanticColors.text.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
