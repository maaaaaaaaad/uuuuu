import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/error_mapper.dart';

void main() {
  group('ErrorMapper', () {
    test('should return Korean message for known error code', () {
      expect(
        ErrorMapper.toUserMessage('DUPLICATE_AUTH_EMAIL'),
        '이미 사용 중인 이메일입니다',
      );
    });

    test('should return Korean message for reservation conflict', () {
      expect(
        ErrorMapper.toUserMessage('RESERVATION_TIME_CONFLICT'),
        '해당 시간에 이미 예약이 있습니다',
      );
    });

    test('should return Korean message for duplicate review', () {
      expect(
        ErrorMapper.toUserMessage('DUPLICATE_REVIEW'),
        '이미 리뷰를 작성했습니다',
      );
    });

    test('should return fallback for unknown error code', () {
      expect(
        ErrorMapper.toUserMessage('UNKNOWN_CODE'),
        ErrorMapper.defaultMessage,
      );
    });

    test('should return custom fallback when provided', () {
      expect(
        ErrorMapper.toUserMessage('UNKNOWN_CODE', fallback: '커스텀 오류'),
        '커스텀 오류',
      );
    });

    test('should return fallback for null code', () {
      expect(
        ErrorMapper.toUserMessage(null),
        ErrorMapper.defaultMessage,
      );
    });

    test('should map all auth error codes', () {
      final authCodes = [
        'AUTHENTICATION_FAILED',
        'DUPLICATE_AUTH_EMAIL',
        'INVALID_AUTH_EMAIL',
        'INVALID_RAW_PASSWORD',
        'INVALID_TOKEN',
      ];
      for (final code in authCodes) {
        expect(
          ErrorMapper.toUserMessage(code),
          isNot(ErrorMapper.defaultMessage),
          reason: '$code should have a Korean mapping',
        );
      }
    });

    test('should map all owner error codes', () {
      final ownerCodes = [
        'DUPLICATE_OWNER_EMAIL',
        'DUPLICATE_OWNER_NICKNAME',
        'DUPLICATE_OWNER_BUSINESS_NUMBER',
        'DUPLICATE_OWNER_PHONE_NUMBER',
        'INVALID_OWNER_EMAIL',
        'INVALID_OWNER_NICKNAME',
        'INVALID_OWNER_BUSINESS_NUMBER',
        'INVALID_OWNER_PHONE_NUMBER',
        'OWNER_NOT_FOUND',
      ];
      for (final code in ownerCodes) {
        expect(
          ErrorMapper.toUserMessage(code),
          isNot(ErrorMapper.defaultMessage),
          reason: '$code should have a Korean mapping',
        );
      }
    });

    test('should map all shop error codes', () {
      final shopCodes = [
        'INVALID_SHOP_NAME',
        'INVALID_SHOP_REG_NUM',
        'DUPLICATE_SHOP_REG_NUM',
        'INVALID_SHOP_PHONE_NUMBER',
        'INVALID_SHOP_ADDRESS',
        'INVALID_SHOP_GPS',
        'INVALID_OPERATING_TIME',
        'INVALID_SHOP_DESCRIPTION',
        'INVALID_SHOP_IMAGE',
        'BEAUTISHOP_NOT_FOUND',
        'UNAUTHORIZED_BEAUTISHOP_ACCESS',
      ];
      for (final code in shopCodes) {
        expect(
          ErrorMapper.toUserMessage(code),
          isNot(ErrorMapper.defaultMessage),
          reason: '$code should have a Korean mapping',
        );
      }
    });

    test('should map all treatment error codes', () {
      final treatmentCodes = [
        'INVALID_TREATMENT_NAME',
        'INVALID_TREATMENT_PRICE',
        'INVALID_TREATMENT_DURATION',
        'INVALID_TREATMENT_DESCRIPTION',
        'TREATMENT_NOT_FOUND',
        'UNAUTHORIZED_TREATMENT_ACCESS',
      ];
      for (final code in treatmentCodes) {
        expect(
          ErrorMapper.toUserMessage(code),
          isNot(ErrorMapper.defaultMessage),
          reason: '$code should have a Korean mapping',
        );
      }
    });

    test('should map all reservation error codes', () {
      final reservationCodes = [
        'RESERVATION_NOT_FOUND',
        'RESERVATION_TIME_CONFLICT',
        'INVALID_RESERVATION_STATUS_TRANSITION',
        'PAST_RESERVATION',
        'TREATMENT_NOT_IN_SHOP',
        'UNAUTHORIZED_RESERVATION_ACCESS',
        'INVALID_RESERVATION_MEMO',
        'INVALID_REJECTION_REASON',
      ];
      for (final code in reservationCodes) {
        expect(
          ErrorMapper.toUserMessage(code),
          isNot(ErrorMapper.defaultMessage),
          reason: '$code should have a Korean mapping',
        );
      }
    });

    test('should map all review error codes', () {
      final reviewCodes = [
        'DUPLICATE_REVIEW',
        'EMPTY_REVIEW',
        'INVALID_REVIEW_RATING',
        'INVALID_REVIEW_CONTENT',
        'INVALID_REVIEW_IMAGES',
        'INVALID_REPLY_CONTENT',
        'REVIEW_NOT_FOUND',
        'UNAUTHORIZED_REVIEW_ACCESS',
      ];
      for (final code in reviewCodes) {
        expect(
          ErrorMapper.toUserMessage(code),
          isNot(ErrorMapper.defaultMessage),
          reason: '$code should have a Korean mapping',
        );
      }
    });
  });
}
