import 'package:equatable/equatable.dart';
import 'package:jellomark/features/reservation/data/models/available_slot_model.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slots_result.dart';

class AvailableSlotsResultModel extends Equatable {
  final String date;
  final String openTime;
  final String closeTime;
  final List<AvailableSlotModel> slots;

  const AvailableSlotsResultModel({
    required this.date,
    required this.openTime,
    required this.closeTime,
    required this.slots,
  });

  factory AvailableSlotsResultModel.fromJson(Map<String, dynamic> json) {
    return AvailableSlotsResultModel(
      date: json['date'] as String,
      openTime: json['openTime'] as String,
      closeTime: json['closeTime'] as String,
      slots: (json['slots'] as List<dynamic>)
          .map((e) => AvailableSlotModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  AvailableSlotsResult toEntity() {
    return AvailableSlotsResult(
      date: date,
      openTime: openTime,
      closeTime: closeTime,
      slots: slots.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  List<Object?> get props => [date, openTime, closeTime, slots];
}
