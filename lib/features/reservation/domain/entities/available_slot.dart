import 'package:equatable/equatable.dart';

class AvailableSlot extends Equatable {
  final String startTime;
  final bool available;

  const AvailableSlot({
    required this.startTime,
    required this.available,
  });

  @override
  List<Object?> get props => [startTime, available];
}
