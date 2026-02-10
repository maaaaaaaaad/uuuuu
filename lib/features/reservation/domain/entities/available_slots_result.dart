import 'package:equatable/equatable.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slot.dart';

class AvailableSlotsResult extends Equatable {
  final String date;
  final String openTime;
  final String closeTime;
  final List<AvailableSlot> slots;

  const AvailableSlotsResult({
    required this.date,
    required this.openTime,
    required this.closeTime,
    required this.slots,
  });

  @override
  List<Object?> get props => [date, openTime, closeTime, slots];
}
