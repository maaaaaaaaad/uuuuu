import 'package:equatable/equatable.dart';

class ShopReview extends Equatable {
  final String id;
  final String authorName;
  final double rating;
  final String content;
  final DateTime createdAt;
  final List<String> images;
  final String? authorProfileImage;
  final String? serviceName;

  const ShopReview({
    required this.id,
    required this.authorName,
    required this.rating,
    required this.content,
    required this.createdAt,
    this.images = const [],
    this.authorProfileImage,
    this.serviceName,
  });

  bool get hasImages => images.isNotEmpty;

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inHours < 24) {
      if (difference.inHours == 0) {
        return '방금 전';
      }
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
        authorName,
        rating,
        content,
        createdAt,
        images,
        authorProfileImage,
        serviceName,
      ];
}
