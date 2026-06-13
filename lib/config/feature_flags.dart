/// Apple Guideline 5.1.1(v) 준수를 위한 게스트 모드 활성화 플래그.
///
/// `true`: 로그인 없이 홈·매장·시술·후기 열람 가능. 예약·후기 작성·즐겨찾기 시점에만
/// 로그인 prompt를 띄움. App Store 심사 통과에 필요.
///
/// `false`: 모든 화면 진입 전 로그인 강제. App Store 가이드라인 위반으로 거부 사유.
const bool kGuestModeEnabled = true;
