class ErrorMapper {
  static const defaultMessage = '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요';

  static const _messages = <String, String>{
    'AUTHENTICATION_FAILED': '이메일 또는 비밀번호가 올바르지 않습니다',
    'DUPLICATE_AUTH_EMAIL': '이미 사용 중인 이메일입니다',
    'INVALID_AUTH_EMAIL': '올바른 이메일 형식이 아닙니다',
    'INVALID_RAW_PASSWORD': '비밀번호 형식이 올바르지 않습니다',
    'INVALID_TOKEN': '인증이 만료되었습니다. 다시 로그인해주세요',
    'INVALID_KAKAO_TOKEN': '카카오 로그인에 실패했습니다. 다시 시도해주세요',
    'KAKAO_API': '카카오 서비스에 일시적인 문제가 발생했습니다',

    'DUPLICATE_OWNER_EMAIL': '이미 사용 중인 이메일입니다',
    'DUPLICATE_OWNER_NICKNAME': '이미 사용 중인 닉네임입니다',
    'DUPLICATE_OWNER_BUSINESS_NUMBER': '이미 등록된 사업자번호입니다',
    'DUPLICATE_OWNER_PHONE_NUMBER': '이미 사용 중인 전화번호입니다',
    'INVALID_OWNER_EMAIL': '올바른 이메일 형식이 아닙니다',
    'INVALID_OWNER_NICKNAME': '올바른 닉네임을 입력해주세요',
    'INVALID_OWNER_BUSINESS_NUMBER': '올바른 사업자번호를 입력해주세요',
    'INVALID_OWNER_PHONE_NUMBER': '올바른 전화번호를 입력해주세요',
    'OWNER_NOT_FOUND': '사장님 정보를 찾을 수 없습니다',

    'DUPLICATE_MEMBER_NICKNAME': '이미 사용 중인 닉네임입니다',
    'DUPLICATE_SOCIAL_ACCOUNT': '이미 연결된 소셜 계정입니다',
    'INVALID_MEMBER_NICKNAME': '올바른 닉네임을 입력해주세요',
    'INVALID_SOCIAL_ID': '소셜 로그인 정보가 올바르지 않습니다',
    'MEMBER_NOT_FOUND': '회원 정보를 찾을 수 없습니다',

    'INVALID_SHOP_NAME': '올바른 샵 이름을 입력해주세요',
    'INVALID_SHOP_REG_NUM': '올바른 사업자등록번호를 입력해주세요',
    'DUPLICATE_SHOP_REG_NUM': '이미 등록된 사업자등록번호입니다',
    'INVALID_SHOP_PHONE_NUMBER': '올바른 전화번호를 입력해주세요',
    'INVALID_SHOP_ADDRESS': '올바른 주소를 입력해주세요',
    'INVALID_SHOP_GPS': '위치 정보가 올바르지 않습니다',
    'INVALID_OPERATING_TIME': '올바른 영업 시간을 입력해주세요',
    'INVALID_SHOP_DESCRIPTION': '샵 소개를 확인해주세요',
    'INVALID_SHOP_IMAGE': '올바른 이미지를 등록해주세요',
    'BEAUTISHOP_NOT_FOUND': '샵 정보를 찾을 수 없습니다',
    'UNAUTHORIZED_BEAUTISHOP_ACCESS': '해당 샵에 대한 권한이 없습니다',

    'CATEGORY_NOT_FOUND': '카테고리를 찾을 수 없습니다',
    'INVALID_CATEGORY_NAME': '올바른 카테고리 이름을 입력해주세요',
    'UNAUTHORIZED_SHOP_ACCESS': '해당 샵에 대한 권한이 없습니다',

    'INVALID_TREATMENT_NAME': '올바른 시술 이름을 입력해주세요',
    'INVALID_TREATMENT_PRICE': '올바른 가격을 입력해주세요',
    'INVALID_TREATMENT_DURATION': '올바른 시술 시간을 입력해주세요',
    'INVALID_TREATMENT_DESCRIPTION': '시술 설명을 확인해주세요',
    'TREATMENT_NOT_FOUND': '시술 정보를 찾을 수 없습니다',
    'UNAUTHORIZED_TREATMENT_ACCESS': '해당 시술에 대한 권한이 없습니다',

    'RESERVATION_NOT_FOUND': '예약 정보를 찾을 수 없습니다',
    'RESERVATION_TIME_CONFLICT': '해당 시간에 이미 예약이 있습니다',
    'INVALID_RESERVATION_STATUS_TRANSITION': '해당 상태로 변경할 수 없습니다',
    'PAST_RESERVATION': '지난 날짜에는 예약할 수 없습니다',
    'TREATMENT_NOT_IN_SHOP': '해당 시술은 이 샵에서 제공하지 않습니다',
    'UNAUTHORIZED_RESERVATION_ACCESS': '해당 예약에 대한 권한이 없습니다',
    'INVALID_RESERVATION_MEMO': '올바른 메모를 입력해주세요 (1~200자)',
    'INVALID_REJECTION_REASON': '올바른 거절 사유를 입력해주세요 (1~200자)',

    'DUPLICATE_REVIEW': '이미 리뷰를 작성했습니다',
    'EMPTY_REVIEW': '평점 또는 내용을 입력해주세요',
    'INVALID_REVIEW_RATING': '평점은 1~5점 사이로 선택해주세요',
    'INVALID_REVIEW_CONTENT': '리뷰 내용은 10~500자로 작성해주세요',
    'INVALID_REVIEW_IMAGES': '이미지는 최대 5장까지 첨부할 수 있습니다',
    'INVALID_REPLY_CONTENT': '답글은 1~500자로 작성해주세요',
    'REVIEW_NOT_FOUND': '리뷰를 찾을 수 없습니다',
    'UNAUTHORIZED_REVIEW_ACCESS': '해당 리뷰에 대한 권한이 없습니다',

    'DUPLICATE_FAVORITE': '이미 즐겨찾기에 추가된 샵입니다',
    'FAVORITE_NOT_FOUND': '즐겨찾기 정보를 찾을 수 없습니다',

    'INVALID_VERIFICATION_CODE': '인증코드가 올바르지 않습니다',
    'VERIFICATION_CODE_EXPIRED': '인증코드가 만료되었습니다. 다시 요청해주세요',
    'VERIFICATION_CODE_NOT_FOUND': '인증코드를 먼저 요청해주세요',
    'INVALID_VERIFICATION_TOKEN': '이메일 인증이 필요합니다',
    'VERIFICATION_RATE_LIMIT': '인증코드 요청이 너무 많습니다. 잠시 후 다시 시도해주세요',

    'INVALID_IMAGE_FORMAT': '지원하지 않는 이미지 형식입니다 (JPG, PNG만 가능)',
    'IMAGE_TOO_LARGE': '이미지 크기가 너무 큽니다 (최대 5MB)',
    'IMAGE_UPLOAD_FAILED': '이미지 업로드에 실패했습니다',

    'INTERNAL_SERVER_ERROR': '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요',
  };

  static String toUserMessage(String? code, {String? fallback}) {
    if (code != null && _messages.containsKey(code)) {
      return _messages[code]!;
    }
    return fallback ?? defaultMessage;
  }
}
