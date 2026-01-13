import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String shopId;
  final String memberId;
  final int rating;
  final String content;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Review({
    required this.id,
    required this.shopId,
    required this.memberId,
    required this.rating,
    required this.content,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasImages => images.isNotEmpty;

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inHours < 1) {
      return '방금 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      final year = createdAt.year;
      final month = createdAt.month.toString().padLeft(2, '0');
      final day = createdAt.day.toString().padLeft(2, '0');
      return '$year.$month.$day';
    }
  }

  @override
  List<Object?> get props => [
        id,
        shopId,
        memberId,
        rating,
        content,
        images,
        createdAt,
        updatedAt,
      ];
}
