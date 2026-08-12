/// 앱 전역 설정/시크릿.
abstract final class AppConfig {
  /// 카카오맵 SDK 키. 빌드 시 `--dart-define=KAKAO_MAP_KEY=...`로 주입.
  /// 비어 있으면 지도는 정적 플레이스홀더로 폴백한다.
  static const String kakaoMapKey =
      String.fromEnvironment('KAKAO_MAP_KEY');

  static bool get hasKakaoMapKey => kakaoMapKey.isNotEmpty;
}
