import 'package:equatable/equatable.dart';

class AvailableDatesModel extends Equatable {
  final List<String> availableDates;

  const AvailableDatesModel({required this.availableDates});

  factory AvailableDatesModel.fromJson(Map<String, dynamic> json) {
    return AvailableDatesModel(
      availableDates: (json['availableDates'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [availableDates];
}
