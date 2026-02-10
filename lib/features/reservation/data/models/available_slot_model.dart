import 'package:equatable/equatable.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slot.dart';

class AvailableSlotModel extends Equatable {
  final String startTime;
  final bool available;

  const AvailableSlotModel({
    required this.startTime,
    required this.available,
  });

  factory AvailableSlotModel.fromJson(Map<String, dynamic> json) {
    return AvailableSlotModel(
      startTime: json['startTime'] as String,
      available: json['available'] as bool,
    );
  }

  AvailableSlot toEntity() {
    return AvailableSlot(
      startTime: startTime,
      available: available,
    );
  }

  @override
  List<Object?> get props => [startTime, available];
}
