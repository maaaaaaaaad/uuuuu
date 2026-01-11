import 'package:equatable/equatable.dart';

class ServiceMenu extends Equatable {
  final String id;
  final String name;
  final int price;
  final int? durationMinutes;
  final String? description;
  final String? category;
  final int? discountPrice;

  const ServiceMenu({
    required this.id,
    required this.name,
    required this.price,
    this.durationMinutes,
    this.description,
    this.category,
    this.discountPrice,
  });

  bool get hasDiscount => discountPrice != null;

  String get formattedPrice {
    return '${_formatNumber(price)}원';
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  String? get formattedDuration {
    if (durationMinutes == null) return null;

    final hours = durationMinutes! ~/ 60;
    final minutes = durationMinutes! % 60;

    if (hours == 0) {
      return '$minutes분';
    } else if (minutes == 0) {
      return '$hours시간';
    } else {
      return '$hours시간 $minutes분';
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        durationMinutes,
        description,
        category,
        discountPrice,
      ];
}
