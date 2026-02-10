import 'package:flutter/material.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';

class ReservationStatusBadge extends StatelessWidget {
  final ReservationStatus status;

  const ReservationStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }

  Color get _backgroundColor => switch (status) {
        ReservationStatus.pending => const Color(0xFFFFF8E1),
        ReservationStatus.confirmed => const Color(0xFFE8F5E9),
        ReservationStatus.rejected => const Color(0xFFFFEBEE),
        ReservationStatus.cancelled => const Color(0xFFEEEEEE),
        ReservationStatus.completed => const Color(0xFFE3F2FD),
        ReservationStatus.noShow => const Color(0xFFFCE4EC),
      };

  Color get _borderColor => switch (status) {
        ReservationStatus.pending => const Color(0xFFFFE082),
        ReservationStatus.confirmed => const Color(0xFFA5D6A7),
        ReservationStatus.rejected => const Color(0xFFEF9A9A),
        ReservationStatus.cancelled => const Color(0xFFBDBDBD),
        ReservationStatus.completed => const Color(0xFF90CAF9),
        ReservationStatus.noShow => const Color(0xFFF48FB1),
      };

  Color get _textColor => switch (status) {
        ReservationStatus.pending => const Color(0xFFF57F17),
        ReservationStatus.confirmed => const Color(0xFF2E7D32),
        ReservationStatus.rejected => const Color(0xFFC62828),
        ReservationStatus.cancelled => const Color(0xFF616161),
        ReservationStatus.completed => const Color(0xFF1565C0),
        ReservationStatus.noShow => const Color(0xFFAD1457),
      };
}
