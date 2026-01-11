import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_detail.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';

void main() {
  group('ShopDetail', () {
    test('should create ShopDetail with all required fields', () {
      const shopDetail = ShopDetail(
        id: '1',
        name: '블루밍 네일',
        address: '서울시 강남구 역삼동 123-45',
        description: '강남 최고의 네일샵입니다.',
        phoneNumber: '02-1234-5678',
      );

      expect(shopDetail.id, '1');
      expect(shopDetail.name, '블루밍 네일');
      expect(shopDetail.address, '서울시 강남구 역삼동 123-45');
      expect(shopDetail.description, '강남 최고의 네일샵입니다.');
      expect(shopDetail.phoneNumber, '02-1234-5678');
    });

    test('should extend BeautyShop', () {
      const shopDetail = ShopDetail(
        id: '1',
        name: '블루밍 네일',
        address: '서울시 강남구',
        description: '설명',
        phoneNumber: '02-1234-5678',
      );

      expect(shopDetail, isA<BeautyShop>());
    });

    test('should have images list', () {
      const shopDetail = ShopDetail(
        id: '1',
        name: '블루밍 네일',
        address: '서울시 강남구',
        description: '설명',
        phoneNumber: '02-1234-5678',
        images: ['image1.jpg', 'image2.jpg', 'image3.jpg'],
      );

      expect(shopDetail.images.length, 3);
      expect(shopDetail.images[0], 'image1.jpg');
    });

    test('should have operating hours map by day', () {
      const shopDetail = ShopDetail(
        id: '1',
        name: '블루밍 네일',
        address: '서울시 강남구',
        description: '설명',
        phoneNumber: '02-1234-5678',
        operatingHoursMap: {
          '월': '10:00 - 20:00',
          '화': '10:00 - 20:00',
          '수': '10:00 - 20:00',
          '목': '10:00 - 20:00',
          '금': '10:00 - 21:00',
          '토': '11:00 - 18:00',
          '일': '휴무',
        },
      );

      expect(shopDetail.operatingHoursMap!['월'], '10:00 - 20:00');
      expect(shopDetail.operatingHoursMap!['일'], '휴무');
    });

    test('should have optional notice field', () {
      const shopDetail = ShopDetail(
        id: '1',
        name: '블루밍 네일',
        address: '서울시 강남구',
        description: '설명',
        phoneNumber: '02-1234-5678',
        notice: '설 연휴 1월 28일 ~ 30일 휴무',
      );

      expect(shopDetail.notice, '설 연휴 1월 28일 ~ 30일 휴무');
    });

    test('should inherit BeautyShop properties', () {
      const shopDetail = ShopDetail(
        id: '1',
        name: '블루밍 네일',
        address: '서울시 강남구',
        description: '설명',
        phoneNumber: '02-1234-5678',
        rating: 4.8,
        reviewCount: 234,
        distance: 0.3,
        tags: ['네일', '젤네일'],
        discountRate: 10,
      );

      expect(shopDetail.rating, 4.8);
      expect(shopDetail.reviewCount, 234);
      expect(shopDetail.formattedDistance, '300m');
      expect(shopDetail.tags, ['네일', '젤네일']);
      expect(shopDetail.discountRate, 10);
    });

    test('should support equality comparison', () {
      const shopDetail1 = ShopDetail(
        id: '1',
        name: '블루밍 네일',
        address: '서울시 강남구',
        description: '설명',
        phoneNumber: '02-1234-5678',
      );

      const shopDetail2 = ShopDetail(
        id: '1',
        name: '블루밍 네일',
        address: '서울시 강남구',
        description: '설명',
        phoneNumber: '02-1234-5678',
      );

      expect(shopDetail1, equals(shopDetail2));
    });
  });
}
