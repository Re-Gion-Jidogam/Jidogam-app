import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import 'app.dart';
import 'core/config/app_config.dart';

void main() {
  // 키가 주입돼 있을 때만 카카오맵 SDK를 초기화한다(없으면 정적 플레이스홀더로
  // 폴백 — [KakaoMapView] 참고). 키는 `--dart-define=KAKAO_MAP_KEY=...`.
  if (AppConfig.hasKakaoMapKey) {
    // baseUrl은 WebView가 카카오 JS SDK에 넘기는 referer가 된다. 카카오 개발자센터
    // [플랫폼]에 Web 플랫폼 `http://localhost`를 등록해두면 도메인 검사를 통과한다.
    AuthRepository.initialize(
      appKey: AppConfig.kakaoMapKey,
      baseUrl: 'http://localhost',
    );
  }

  runApp(
    const ProviderScope(
      child: JidogamApp(),
    ),
  );
}
